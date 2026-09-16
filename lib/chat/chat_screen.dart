import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/token_store.dart';
import '../core/app_theme.dart';
import '../models/chat_message.dart';
import '../models/listing.dart';
import '../auth/auth_bottom_sheet.dart';
import 'post_listing_bottom_sheet.dart';
import 'update_listing_bottom_sheet.dart';
import 'message_bubble.dart';
import 'typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final Map<int, List<Listing>> _listingsByMessageIndex = {};
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;
  String? _userName;

  @override
  void initState() {
    super.initState();
    TokenStore.readName().then((name) {
      if (mounted) setState(() => _userName = name);
    });
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _messages.add(ChatMessage(role: 'user', content: text));
      _sending = true;
    });
    _inputCtrl.clear();
    _scrollToBottom();
    try {
      final res = await ApiClient.chat(messages: _messages.map((m) => m.toJson()).toList());
      final assistantIndex = _messages.length;
      setState(() {
        _messages.add(ChatMessage(role: 'assistant', content: res['content'] as String? ?? ''));
        final rawListings = res['listings'] as List<dynamic>?;
        if (rawListings != null) {
          _listingsByMessageIndex[assistantIndex] = rawListings.map((l) => Listing.fromJson(l as Map<String, dynamic>)).toList();
        }
      });
      final action = res['action'] as String?;
      if (action == 'open_auth' || action == 'open_google_auth') _openAuthSheet();
      if (action == 'open_post_listing') _openPostListingSheet();
      if (action == 'open_update_listing') _openUpdateListingSheet();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(role: 'assistant', content: "Sorry, I couldn't reach the server. Try again?"));
      });
    } finally {
      setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  Future<void> _openAuthSheet() async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AuthBottomSheet(),
    );
  }

  Future<void> _openPostListingSheet() async {
    final posted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PostListingBottomSheet(),
    );
    if (posted == true && mounted) {
      setState(() {
        _messages.add(ChatMessage(role: 'assistant', content: "Your listing is live! Renters can find it now."));
      });
      _scrollToBottom();
    }
  }

  Future<void> _openUpdateListingSheet() async {
    final listingId = await TokenStore.readListingId();
    if (listingId == null) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(role: 'assistant', content: "I couldn't find your listing. Try posting one first."));
        });
        _scrollToBottom();
      }
      return;
    }

    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UpdateListingBottomSheet(listingId: listingId),
    );
    if (updated == true && mounted) {
      setState(() {
        _messages.add(ChatMessage(role: 'assistant', content: "Your listing is updated! Changes are live now."));
      });
      _scrollToBottom();
    }
  }

  Future<void> _logout() async {
    await TokenStore.clear();
    if (mounted) {
      setState(() {
        _messages.clear();
        _openAuthSheet();
      });
    }
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.home_rounded, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sarah', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                Text(_sending ? 'typing…' : 'online', style: TextStyle(fontSize: 12, color: _sending ? AppColors.primary : AppColors.textSecondary)),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) => MessageBubble(
                      role: _messages[i].role,
                      content: _messages[i].content,
                      listings: _listingsByMessageIndex[i],
                      userName: _userName,
                    ),
                  ),
          ),
          if (_sending)
            const Padding(
              padding: EdgeInsets.only(left: 54, bottom: 8),
              child: Align(alignment: Alignment.centerLeft, child: TypingIndicator()),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: TextField(
                        controller: _inputCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Message Sarah…',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sending ? null : _send,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: AppColors.assistantBubble, shape: BoxShape.circle),
              child: const Icon(Icons.chat_bubble_outline_rounded, size: 30, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text("Hey, I'm Sarah 👋", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text(
              "Tell me what you're looking for, or if you've got a place to rent out.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
