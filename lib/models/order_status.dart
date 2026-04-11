enum OrderStatus {
  pending('Pendiente', 'pending'),
  confirmed('Confirmado', 'confirmed'),
  preparing('Preparando', 'preparing'),
  outForDelivery('En camino', 'out_for_delivery'),
  delivered('Entregado', 'delivered'),
  cancelled('Cancelado', 'cancelled');

  final String displayName;
  final String apiValue;

  const OrderStatus(this.displayName, this.apiValue);

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.apiValue == value.toLowerCase(),
      orElse: () => OrderStatus.pending,
    );
  }
}

enum PaymentStatus {
  pending('Pago Pendiente', 'pending'),
  paid('Pagado', 'paid'),
  failed('Pago Fallido', 'failed'),
  refunded('Reembolsado', 'refunded');

  final String displayName;
  final String apiValue;

  const PaymentStatus(this.displayName, this.apiValue);

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.apiValue == value.toLowerCase(),
      orElse: () => PaymentStatus.pending,
    );
  }
}