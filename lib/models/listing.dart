class Listing {
  final int id;
  final String title;
  final double price;
  final int? bedrooms;
  final String? address;
  final List<String> imageUrls;

  Listing({
    required this.id,
    required this.title,
    required this.price,
    this.bedrooms,
    this.address,
    required this.imageUrls,
  });

  factory Listing.fromJson(Map<String, dynamic> json) => Listing(
        id: json['id'] as int,
        title: json['title'] as String,
        price: (json['price'] as num).toDouble(),
        bedrooms: json['bedrooms'] as int?,
        address: json['address'] as String?,
        imageUrls: (json['image_urls'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
      );
}
