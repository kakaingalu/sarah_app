import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../core/api_client.dart';

class PesapalWebView extends StatefulWidget {
  final String redirectUrl;
  final String orderTrackingId;
  final int listingId;

  const PesapalWebView({
    required this.redirectUrl,
    required this.orderTrackingId,
    required this.listingId,
  });

  @override
  State<PesapalWebView> createState() => _PesapalWebViewState();
}

class _PesapalWebViewState extends State<PesapalWebView> {
  late WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            _checkPaymentStatus();
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('Web resource error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  Future<void> _checkPaymentStatus() async {
    try {
      final result = await ApiClient.verifyPayment(widget.orderTrackingId);
      if (result['status'] == 'COMPLETED') {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      print('Error checking payment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        centerTitle: true,
        backgroundColor: const Color(0xFFC1652F),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
