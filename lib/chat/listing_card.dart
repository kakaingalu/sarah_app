import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/listing.dart';
import '../payments/payment_modal.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  const ListingCard({super.key, required this.listing});

  void _openPaymentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => PaymentModal(
        listingId: listing.id,
        listingTitle: listing.title,
        isAgent: listing.isAgent,
        onPaymentSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment successful! Contact info unlocked.')),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 11,
                child: listing.imageUrls.isNotEmpty
                    ? Image.network(listing.imageUrls.first, fit: BoxFit.cover)
                    : Container(color: AppColors.assistantBubble, child: const Icon(Icons.home_outlined, size: 30, color: AppColors.textSecondary)),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(20)),
                  child: Text('Ksh ${listing.price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(listing.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                if (listing.bedrooms != null)
                  Row(children: [
                    const Icon(Icons.bed_outlined, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text('${listing.bedrooms} bed', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ]),
                if (listing.address != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(listing.address!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _openPaymentModal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC1652F),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Apply', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
