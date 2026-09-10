import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/listing.dart';
import 'listing_card.dart';

class MessageBubble extends StatelessWidget {
  final String role;
  final String content;
  final List<Listing>? listings;
  final String? userName;

  const MessageBubble({super.key, required this.role, required this.content, this.listings, this.userName});

  @override
  Widget build(BuildContext context) {
    final isUser = role == 'user';
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 8), child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUser)
              Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 8, top: 2),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  'https://api.dicebear.com/9.x/avataaars/png?seed=SarahHouseHunter&top=longHairStraight,longHairCurly,longHairBun&facialHairType=blank&clothesType=blazerShirt,shirtScoopNeck&skinColor=light,brown,tanned',
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Icon(Icons.home_rounded, size: 16, color: Colors.white);
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.home_rounded, size: 16, color: Colors.white),
                ),
              ),
            Flexible(
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primary : AppColors.assistantBubble,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isUser ? 18 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 18),
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Text(
                      content,
                      style: TextStyle(color: isUser ? Colors.white : AppColors.textPrimary, fontSize: 15, height: 1.35),
                    ),
                  ),
                  if (listings != null && listings!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        height: 200,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: listings!.map((l) => ListingCard(listing: l)).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isUser)
              Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(left: 8, top: 2),
                decoration: const BoxDecoration(color: AppColors.primaryDark, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  (userName != null && userName!.trim().isNotEmpty) ? userName!.trim()[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
