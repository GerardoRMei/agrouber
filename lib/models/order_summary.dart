class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.reference,
    required this.status,
    required this.paymentStatus,
    required this.total,
    required this.createdAt,
    required this.counterpartyName,
    required this.itemsDescription,
    required this.itemCount,
    this.deliveryAddress,
  });

  final int id;
  final String reference;
  final String status;
  final String paymentStatus;
  final double total;
  final DateTime? createdAt;
  final String counterpartyName;
  final String itemsDescription;
  final int itemCount;
  final String? deliveryAddress;

  String get totalLabel => '\$${total.toStringAsFixed(2)}';
  String get statusLabel => _toDisplayLabel(status, fallback: 'Pendiente');
  String get paymentStatusLabel =>
      _toDisplayLabel(paymentStatus, fallback: 'Pendiente');

  String get createdAtLabel {
    if (createdAt == null) {
      return 'Sin fecha';
    }

    final date = createdAt!;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} $hour:$minute';
  }

  factory OrderSummary.fromJson(
    Map<String, dynamic> json, {
    required bool forSeller,
  }) {
    final attributes =
        json['attributes'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final source = attributes.isNotEmpty ? attributes : json;

    final id = (json['id'] as num?)?.toInt() ?? (source['id'] as num?)?.toInt() ?? 0;
    final reference = _str(
      source['reference'] ??
          source['code'] ??
          source['orderNumber'] ??
          (id > 0 ? '#$id' : ''),
    );

    final statusRaw = _str(source['statusOrder'] ?? source['status']);
    final status = statusRaw.isEmpty ? 'pending' : statusRaw;
    final paymentStatus = _str(
      source['payment_status'] ?? source['paymentStatus'],
    );
    final total = _asDouble(
      source['total'] ?? source['subtotal'] ?? source['totalAmount'] ?? source['amount'],
    );
    final createdAt = _parseDate(
      source['createdAt'] ?? source['created_at'] ?? source['date'],
    );

    final itemsRaw = source['items'] ?? source['orderItems'];
    final counterpartyRaw = forSeller
        ? (source['customer'] ?? source['buyer'] ?? source['user'])
        : (source['seller'] ?? source['store'] ?? _firstItemSeller(itemsRaw));
    final counterpartyName = _relationName(
      counterpartyRaw,
      fallback: forSeller ? 'Cliente' : 'Vendedor',
    );

    final itemsDescription = _itemsLabel(itemsRaw);
    final itemCount = _itemsCount(itemsRaw);
    final deliveryAddress = _addressLabel(source['adress'] ?? source['address']);

    return OrderSummary(
      id: id,
      reference: reference.isEmpty ? (id > 0 ? '#$id' : 'Sin referencia') : reference,
      status: status,
      paymentStatus: paymentStatus,
      total: total,
      createdAt: createdAt,
      counterpartyName: counterpartyName,
      itemsDescription: itemsDescription,
      itemCount: itemCount,
      deliveryAddress: deliveryAddress,
    );
  }

  static String _itemsLabel(dynamic rawItems) {
    if (rawItems is List<dynamic>) {
      final names = <String>[];
      for (final item in rawItems.whereType<Map<String, dynamic>>()) {
        final attributes =
            item['attributes'] as Map<String, dynamic>? ?? <String, dynamic>{};
        final source = attributes.isNotEmpty ? attributes : item;
        final quantityValue = _asDouble(source['quantity']);
        final quantity = quantityValue > 0 ? quantityValue.toInt() : 0;
        final name = _itemName(source);
        if (name.isNotEmpty) {
          names.add(quantity > 0 ? '$name x$quantity' : name);
        }
      }

      if (names.isNotEmpty) {
        return names.join(', ');
      }
      return '${rawItems.length} producto${rawItems.length == 1 ? '' : 's'}';
    }

    return 'Sin detalle de productos';
  }

  static int _itemsCount(dynamic rawItems) {
    if (rawItems is List<dynamic>) {
      return rawItems.length;
    }
    return 0;
  }

  static dynamic _firstItemSeller(dynamic rawItems) {
    if (rawItems is! List<dynamic> || rawItems.isEmpty) {
      return null;
    }
    final first = rawItems.first;
    if (first is! Map<String, dynamic>) {
      return null;
    }
    final attributes =
        first['attributes'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final source = attributes.isNotEmpty ? attributes : first;
    return source['seller'];
  }

  static String _itemName(Map<String, dynamic> source) {
    final direct = _str(
      source['productName'] ??
          source['product_name'] ??
          source['name'] ??
          source['title'],
    );
    if (direct.isNotEmpty) {
      return direct;
    }
    return _relationName(source['product'], fallback: '');
  }

  static String _relationName(dynamic raw, {required String fallback}) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) {
        final attributes =
            data['attributes'] as Map<String, dynamic>? ?? <String, dynamic>{};
        final source = attributes.isNotEmpty ? attributes : data;
        final candidate = _str(
          source['name'] ?? source['storeName'] ?? source['username'] ?? source['email'],
        );
        if (candidate.isNotEmpty) {
          return candidate;
        }
      }

      final candidate = _str(
        raw['name'] ??
            raw['storeName'] ??
            raw['username'] ??
            raw['firstName'] ??
            raw['email'],
      );
      if (candidate.isNotEmpty) {
        return candidate;
      }
    }

    return fallback;
  }

  static String? _addressLabel(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      return null;
    }

    final parts = <String>[
      _str(raw['addressLine1']),
      _str(raw['addressLine2']),
      _str(raw['city']),
      _str(raw['state']),
      _str(raw['postalCode']),
      _str(raw['reference']),
    ].where((part) => part.isNotEmpty).toList();

    if (parts.isEmpty) {
      return null;
    }
    return parts.join(', ');
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }

  static String _str(dynamic value) => (value ?? '').toString().trim();

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _toDisplayLabel(String value, {required String fallback}) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return fallback;
    }

    const known = <String, String>{
      'pending': 'Pendiente',
      'confirmed': 'Confirmada',
      'preparing': 'Preparando',
      'out_for_delivery': 'En camino',
      'delivered': 'Entregada',
      'cancelled': 'Cancelada',
      'paid': 'Pagado',
      'failed': 'Fallido',
      'refunded': 'Reembolsado',
    };

    final mapped = known[normalized];
    if (mapped != null) {
      return mapped;
    }

    final words = normalized.split('_').where((word) => word.isNotEmpty);
    if (words.isEmpty) {
      return fallback;
    }

    return words
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
