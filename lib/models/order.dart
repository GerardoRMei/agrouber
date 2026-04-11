import 'address.dart';
import 'order_status.dart';

class OrderItem {
  final int? id;
  final String productName;
  final String sellerName;
  final double quantity;
  final String unitLabel;
  final double unitPrice;
  final double finalPrice;

  const OrderItem({
    this.id,
    required this.productName,
    required this.sellerName,
    required this.quantity,
    required this.unitLabel,
    required this.unitPrice,
    required this.finalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: (json['id'] as num?)?.toInt(),
      productName: (json['productName'] ?? '').toString(),
      sellerName: (json['sellerName'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unitLabel: (json['unitLabel'] ?? '').toString(),
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      finalPrice: (json['finalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Order {
  final int id;
  final String orderId;
  final OrderStatus statusOrder;
  final PaymentStatus paymentStatus;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String? notes;
  final Address address;
  final int customerId;
  final int? deliveryAssignmentId;
  final List<OrderItem> items;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.orderId,
    required this.statusOrder,
    required this.paymentStatus,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    this.notes,
    required this.address,
    required this.customerId,
    this.deliveryAssignmentId,
    required this.items,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] ?? json;
    
    final itemsData = attributes['items'] is List 
        ? attributes['items'] as List 
        : (attributes['items']?['data'] as List? ?? []);
        
    final List<OrderItem> parsedItems = itemsData
        .whereType<Map<String, dynamic>>()
        .map((itemJson) => OrderItem.fromJson(itemJson['attributes'] ?? itemJson))
        .toList();

    return Order(
      id: (json['id'] as num).toInt(),
      orderId: (attributes['orderId'] ?? '').toString(),
      statusOrder: OrderStatus.fromString(attributes['statusOrder']?.toString() ?? ''),
      paymentStatus: PaymentStatus.fromString(attributes['paymentStatus']?.toString() ?? ''),
      subtotal: (attributes['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (attributes['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      total: (attributes['total'] as num?)?.toDouble() ?? 0.0,
      notes: attributes['notes']?.toString(),
      address: Address.fromJson(attributes['address']?['data'] ?? attributes['address'] ?? {}),
      customerId: (attributes['customer']?['data']?['id'] as num?)?.toInt() ?? 0,
      deliveryAssignmentId: (attributes['deliveryAssignment']?['data']?['id'] as num?)?.toInt(),
      items: parsedItems,
      createdAt: DateTime.tryParse(attributes['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}