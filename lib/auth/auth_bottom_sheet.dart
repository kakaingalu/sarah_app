import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/app_theme.dart';
import '../core/token_store.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthBottomSheet extends StatefulWidget {
  final bool startOnSignup;
  const AuthBottomSheet({super.key, this.startOnSignup = false});

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet> {
  late bool _isSignup = widget.startOnSignup;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = _isSignup
          ? await ApiClient.signup(name: _nameCtrl.text.trim(), email: _emailCtrl.text.trim(), password: _passwordCtrl.text)
          : await ApiClient.login(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
      await TokenStore.save(result['access_token'] as String);
      final name = result['name'] as String?;
      if (name != null && name.isNotEmpty) await TokenStore.saveName(name);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = 'Something went wrong. Check your details and try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        serverClientId: '434465452860-rvs2q5k5g3tn0gv0tua41rd87ucujok0.apps.googleusercontent.com',
      );
      final account = await googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw Exception('No ID token returned from Google');
      }
      final result = await ApiClient.googleLogin(idToken: idToken);
      await TokenStore.save(result['access_token'] as String);
      final name = result['name'] as String?;
      if (name != null && name.isNotEmpty) await TokenStore.saveName(name);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = 'Google sign-in failed. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.only(left: 24, right: 24, top: 14, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text(_isSignup ? 'Create your account' : 'Welcome back', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(_isSignup ? 'Just a few details to get started' : 'Log in to continue with Sarah', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 20),
          if (_isSignup) ...[
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
          ],
          TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 12),
          TextField(controller: _passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(_isSignup ? 'Sign up' : 'Log in'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: const BorderSide(color: AppColors.border),
            ),
            onPressed: _loading ? null : _handleGoogleSignIn,
            icon: const Icon(Icons.g_mobiledata_rounded, size: 22),
            label: const Text('Continue with Google'),
          ),
          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _isSignup = !_isSignup),
              child: Text(_isSignup ? 'Already have an account? Log in' : "Don't have an account? Sign up"),
            ),
          ),
        ],
      ),
    );
  }
}
