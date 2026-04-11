class Address {
  final int? id;
  final String label;
  final String recipientName;
  final String street;
  final String externalNumber;
  final String? internalNumber;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String phone;
  final String? references;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final int? userId;

  const Address({
    this.id,
    required this.label,
    required this.recipientName,
    required this.street,
    required this.externalNumber,
    this.internalNumber,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    this.country = 'México',
    required this.phone,
    this.references,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.userId,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] ?? json;
    return Address(
      id: (json['id'] as num?)?.toInt(),
      label: (attributes['label'] ?? '').toString(),
      recipientName: (attributes['recipientName'] ?? '').toString(),
      street: (attributes['street'] ?? '').toString(),
      externalNumber: (attributes['externalNumber'] ?? '').toString(),
      internalNumber: attributes['internalNumber']?.toString(),
      neighborhood: (attributes['neighborhood'] ?? '').toString(),
      city: (attributes['city'] ?? '').toString(),
      state: (attributes['state'] ?? '').toString(),
      zipCode: (attributes['zipCode'] ?? '').toString(),
      country: (attributes['country'] ?? 'México').toString(),
      phone: (attributes['phone'] ?? '').toString(),
      references: attributes['references']?.toString(),
      latitude: (attributes['latitude'] as num?)?.toDouble(),
      longitude: (attributes['longitude'] as num?)?.toDouble(),
      isDefault: attributes['isDefault'] as bool? ?? false,
      userId: (attributes['user']?['data']?['id'] as num?)?.toInt() ?? 
              (attributes['userId'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'recipientName': recipientName,
      'street': street,
      'externalNumber': externalNumber,
      'internalNumber': internalNumber,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'phone': phone,
      'references': references,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
      if (userId != null) 'user': userId,
    };
  }
}