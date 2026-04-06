class DeliveryOrderCard{
  final String orderId;
  final String pickupLocation;
  final String dropoffLocation;
  final double distance;
  final int estimatedTime;
  final double price;
  final int packages;
  final int secondsToAccept;


  const DeliveryOrderCard({
    required this.orderId,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.distance,
    required this.estimatedTime,
    required this.price,
    required this.packages,
    required this.secondsToAccept,
  });

  DeliveryOrderCard copyWith({
    String? orderId,
    String? pickupLocation,
    String? dropoffLocation,
    double? distance,
    int? estimatedTime,
    double? price,
    int? packages,
    int? secondsToAccept,
  }) {
    return DeliveryOrderCard(
      orderId: orderId ?? this.orderId,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      distance: distance ?? this.distance,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      price: price ?? this.price,
      packages: packages ?? this.packages,
      secondsToAccept: secondsToAccept ?? this.secondsToAccept,
    );
  }
}

