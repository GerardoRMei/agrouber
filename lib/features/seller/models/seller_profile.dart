enum SellerStatus {
  none,
  pending,
  approved,
  rejected;

  static SellerStatus fromValue(dynamic value) {
    switch (value?.toString().trim().toLowerCase()) {
      case 'pending':
        return SellerStatus.pending;
      case 'approved':
        return SellerStatus.approved;
      case 'rejected':
        return SellerStatus.rejected;
      default:
        return SellerStatus.none;
    }
  }
}

enum WarehouseAssignmentStatus {
  pending,
  assigned,
  none;

  static WarehouseAssignmentStatus fromValue(dynamic value) {
    switch (value?.toString().trim().toLowerCase()) {
      case 'pending':
        return WarehouseAssignmentStatus.pending;
      case 'assigned':
        return WarehouseAssignmentStatus.assigned;
      default:
        return WarehouseAssignmentStatus.none;
    }
  }
}

class SellerAddress {
  const SellerAddress({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.reference,
  });

  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? reference;

  bool get hasData =>
      addressLine1 != null ||
      addressLine2 != null ||
      city != null ||
      state != null ||
      postalCode != null ||
      reference != null;

  String get shortLabel {
    final parts = <String>[
      if (city != null) city!,
      if (state != null) state!,
    ];
    return parts.isEmpty ? 'Sin direccion registrada' : parts.join(', ');
  }

  String get fullLabel {
    final parts = <String>[
      if (addressLine1 != null) addressLine1!,
      if (addressLine2 != null) addressLine2!,
      if (city != null) city!,
      if (state != null) state!,
      if (postalCode != null) 'CP $postalCode',
      if (reference != null) reference!,
    ];
    return parts.isEmpty ? 'Sin direccion registrada' : parts.join(', ');
  }

  factory SellerAddress.fromJson(dynamic raw) {
    final json = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
    return SellerAddress(
      addressLine1: _optionalString(json['addressLine1']),
      addressLine2: _optionalString(json['addressLine2']),
      city: _optionalString(json['city']),
      state: _optionalString(json['state']),
      postalCode: _optionalString(json['postalCode']),
      reference: _optionalString(json['reference']),
    );
  }
}

class SellerWarehouse {
  const SellerWarehouse({
    this.id,
    this.documentId,
    this.name,
    this.address,
  });

  final int? id;
  final String? documentId;
  final String? name;
  final String? address;

  bool get hasData => id != null || name != null || address != null;

  String get label => name ?? 'Sin almacen asignado';

  String get fullLabel {
    final parts = <String>[
      if (name != null) name!,
      if (address != null) address!,
    ];
    return parts.isEmpty ? 'Sin almacen asignado' : parts.join(', ');
  }

  factory SellerWarehouse.fromJson(dynamic raw) {
    final json = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
    return SellerWarehouse(
      id: (json['id'] as num?)?.toInt(),
      documentId: _optionalString(json['documentId']),
      name: _optionalString(json['name']),
      address: _optionalString(json['address']),
    );
  }
}

class SellerProfile {
  const SellerProfile({
    required this.id,
    required this.storeName,
    required this.status,
    this.documentId,
    this.description,
    this.contactPhone,
    this.message,
    this.isVerified,
    this.address,
    this.productCount,
    this.assignedWarehouse,
    this.warehouseAssignmentStatus = WarehouseAssignmentStatus.none,
    this.deliveryInstructions,
    this.canCreateProducts,
    this.canDeliverToWarehouse,
    this.canEditProfile,
  });

  final int id;
  final String storeName;
  final SellerStatus status;
  final String? documentId;
  final String? description;
  final String? contactPhone;
  final String? message;
  final bool? isVerified;
  final SellerAddress? address;
  final int? productCount;
  final SellerWarehouse? assignedWarehouse;
  final WarehouseAssignmentStatus warehouseAssignmentStatus;
  final String? deliveryInstructions;
  final bool? canCreateProducts;
  final bool? canDeliverToWarehouse;
  final bool? canEditProfile;

  bool get hasData => id > 0 || storeName.isNotEmpty || status != SellerStatus.none;
  bool get isApproved => status == SellerStatus.approved;

  SellerProfile copyWith({
    int? id,
    String? storeName,
    SellerStatus? status,
    String? documentId,
    String? description,
    String? contactPhone,
    String? message,
    bool? isVerified,
    SellerAddress? address,
    int? productCount,
    SellerWarehouse? assignedWarehouse,
    WarehouseAssignmentStatus? warehouseAssignmentStatus,
    String? deliveryInstructions,
    bool? canCreateProducts,
    bool? canDeliverToWarehouse,
    bool? canEditProfile,
  }) {
    return SellerProfile(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      status: status ?? this.status,
      documentId: documentId ?? this.documentId,
      description: description ?? this.description,
      contactPhone: contactPhone ?? this.contactPhone,
      message: message ?? this.message,
      isVerified: isVerified ?? this.isVerified,
      address: address ?? this.address,
      productCount: productCount ?? this.productCount,
      assignedWarehouse: assignedWarehouse ?? this.assignedWarehouse,
      warehouseAssignmentStatus:
          warehouseAssignmentStatus ?? this.warehouseAssignmentStatus,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      canCreateProducts: canCreateProducts ?? this.canCreateProducts,
      canDeliverToWarehouse:
          canDeliverToWarehouse ?? this.canDeliverToWarehouse,
      canEditProfile: canEditProfile ?? this.canEditProfile,
    );
  }

  factory SellerProfile.fromRegistrationResponse(Map<String, dynamic> json) {
    final seller = json['seller'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final approvalValue = seller['approvalStatus'] ?? seller['status'];

    return SellerProfile(
      id: (seller['id'] as num?)?.toInt() ?? 0,
      documentId: _optionalString(seller['documentId']),
      status: SellerStatus.fromValue(approvalValue),
      storeName: (seller['storeName'] ?? '').toString(),
      message: _optionalString(json['message']),
    );
  }

  factory SellerProfile.fromMeResponse(Map<String, dynamic> json) {
    final seller = json['seller'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final approvalValue = seller['approvalStatus'] ?? seller['status'];

    return SellerProfile(
      id: (seller['id'] as num?)?.toInt() ?? 0,
      documentId: _optionalString(seller['documentId']),
      status: SellerStatus.fromValue(approvalValue),
      storeName: (seller['storeName'] ?? '').toString(),
      description: _optionalString(seller['description']),
      contactPhone: _optionalString(seller['contactPhone']),
      isVerified: seller['isVerified'] as bool?,
      address: SellerAddress.fromJson(seller['address']),
      productCount: (seller['productCount'] as num?)?.toInt(),
      assignedWarehouse: SellerWarehouse.fromJson(seller['assignedWarehouse']),
      warehouseAssignmentStatus: WarehouseAssignmentStatus.fromValue(
        seller['warehouseAssignmentStatus'],
      ),
      deliveryInstructions: _optionalString(seller['deliveryInstructions']),
    );
  }

  factory SellerProfile.fromDashboardResponse(Map<String, dynamic> json) {
    final seller = json['seller'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final warehouse =
        json['warehouse'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final actions =
        json['actions'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return SellerProfile(
      id: 0,
      storeName: (seller['storeName'] ?? '').toString(),
      status: SellerStatus.fromValue(
        seller['approvalStatus'] ?? seller['status'],
      ),
      productCount: (seller['productCount'] as num?)?.toInt(),
      assignedWarehouse: warehouse['name'] != null || warehouse['address'] != null
          ? SellerWarehouse.fromJson(warehouse)
          : null,
      warehouseAssignmentStatus: WarehouseAssignmentStatus.fromValue(
        warehouse['assignmentStatus'],
      ),
      deliveryInstructions: _optionalString(
        warehouse['deliveryInstructions'] ?? warehouse['message'],
      ),
      canCreateProducts: actions['canCreateProducts'] as bool?,
      canDeliverToWarehouse: actions['canDeliverToWarehouse'] as bool?,
      canEditProfile: actions['canEditProfile'] as bool?,
    );
  }

  factory SellerProfile.fromWarehouseAssignmentResponse(
    Map<String, dynamic> json,
  ) {
    return SellerProfile(
      id: 0,
      storeName: '',
      status: SellerStatus.none,
      assignedWarehouse: SellerWarehouse.fromJson(json['warehouse']),
      warehouseAssignmentStatus: WarehouseAssignmentStatus.fromValue(
        json['status'],
      ),
      deliveryInstructions: _optionalString(
        json['deliveryInstructions'] ?? json['message'],
      ),
    );
  }
}

String? _optionalString(dynamic value) {
  final normalized = value?.toString().trim() ?? '';
  return normalized.isEmpty ? null : normalized;
}
