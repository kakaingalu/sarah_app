import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/api_client.dart';
import '../core/app_theme.dart';

class UpdateListingBottomSheet extends StatefulWidget {
  final int listingId;

  const UpdateListingBottomSheet({
    super.key,
    required this.listingId,
  });

  @override
  State<UpdateListingBottomSheet> createState() => _UpdateListingBottomSheetState();
}

class _UpdateListingBottomSheetState extends State<UpdateListingBottomSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _bedroomsCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final List<File> _newImages = [];
  bool _loading = false;
  String? _error;

  Future<void> _pickImages() async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    setState(() {
      _newImages.addAll(picked.map((x) => File(x.path)));
    });
  }

  Future<void> _submit() async {
    // At least one field must be provided
    final hasChanges = _titleCtrl.text.isNotEmpty ||
        _descCtrl.text.isNotEmpty ||
        _priceCtrl.text.isNotEmpty ||
        _bedroomsCtrl.text.isNotEmpty ||
        _addressCtrl.text.isNotEmpty ||
        _newImages.isNotEmpty;

    if (!hasChanges) {
      setState(() => _error = 'Make at least one change to update your listing.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ApiClient.updateListing(
        listingId: widget.listingId,
        title: _titleCtrl.text.isEmpty ? null : _titleCtrl.text.trim(),
        description: _descCtrl.text.isEmpty ? null : _descCtrl.text.trim(),
        price: _priceCtrl.text.isEmpty ? null : double.tryParse(_priceCtrl.text.trim()),
        bedrooms: _bedroomsCtrl.text.isEmpty ? null : int.tryParse(_bedroomsCtrl.text.trim()),
        address: _addressCtrl.text.isEmpty ? null : _addressCtrl.text.trim(),
        images: _newImages,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = "Couldn't update your listing. Try again?");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Update your listing',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Change what renters will see',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title (leave empty to keep current)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Price (Ksh/mo)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _bedroomsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Bedrooms'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(labelText: 'Address (optional)'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: const BorderSide(color: AppColors.border),
              ),
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
              label: Text(
                _newImages.isEmpty ? 'Add new photos' : '${_newImages.length} photo(s) to add',
              ),
            ),
            if (_newImages.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _newImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _newImages[i],
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Update listing'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _bedroomsCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }
}
