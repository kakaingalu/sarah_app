import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/listing.dart';
import '../payments/payment_modal.dart';

class ListingDetailSheet extends StatefulWidget {
  final Listing listing;
  const ListingDetailSheet({super.key, required this.listing});

  @override
  State<ListingDetailSheet> createState() => _ListingDetailSheetState();
}

class _ListingDetailSheetState extends State<ListingDetailSheet> {
  late PageController _pageCtrl;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _openPaymentModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => PaymentModal(
        listingId: widget.listing.id,
        listingTitle: widget.listing.title,
        isAgent: widget.listing.isAgent,
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
    final listing = widget.listing;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          controller: scrollCtrl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Image carousel
              if (listing.imageUrls.isNotEmpty)
                Column(
                  children: [
                    SizedBox(
                      height: 280,
                      child: PageView.builder(
                        controller: _pageCtrl,
                        onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                        itemCount: listing.imageUrls.length,
                        itemBuilder: (context, idx) => Image.network(
                          listing.imageUrls[idx],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Image counter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        listing.imageUrls.length,
                        (idx) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: idx == _currentImageIndex ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              // Title & price
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ksh ${listing.price.toStringAsFixed(0)} per month',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Details row: bedrooms
              if (listing.bedrooms != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.assistantBubble,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.bed_outlined, size: 20, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Bedrooms', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text('${listing.bedrooms}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              // Address
              if (listing.address != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Location', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(listing.address!, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4)),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              // Map placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.assistantBubble,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 32, color: AppColors.primary),
                        const SizedBox(height: 8),
                        const Text('Map view (coming soon)', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Apply button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _openPaymentModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Apply to Contact Owner',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
