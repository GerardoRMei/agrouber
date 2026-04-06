class SellerRegistrationRequest {
  const SellerRegistrationRequest({
    required this.firstName,
    required this.username,
    required this.email,
    required this.password,
    required this.phone,
    required this.storeName,
    this.contactPhone,
    this.description,
  });

  final String firstName;
  final String username;
  final String email;
  final String password;
  final String phone;
  final String storeName;
  final String? contactPhone;
  final String? description;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'firstName': firstName,
      'username': username,
      'email': email,
      'password': password,
      'phone': phone,
      'storeName': storeName,
      if (contactPhone != null && contactPhone!.trim().isNotEmpty)
        'contactPhone': contactPhone!.trim(),
      if (description != null && description!.trim().isNotEmpty)
        'description': description!.trim(),
    };
  }
}
