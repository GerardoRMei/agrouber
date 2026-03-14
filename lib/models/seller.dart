import 'product.dart';

class SocialMedia {
  final String? facebook;
  final String? instagram;
  final String? tiktok;

  const SocialMedia({
    this.facebook,
    this.instagram,
    this.tiktok,
  });
}

class Seller {
  final String name;
  final String address;
  final List<Product> products;
  final String description;
  final String email;
  final SocialMedia socialMedia;
  final String phone;

  const Seller({
    required this.name,
    required this.address,
    required this.products,
    required this.description,
    required this.email,
    required this.socialMedia,
    required this.phone,
  });
}