class SellerSalesMetrics {
  const SellerSalesMetrics({
    required this.ordersCount,
    required this.revenue,
    required this.itemsSold,
    required this.averageTicket,
    this.from,
    this.to,
  });

  final int ordersCount;
  final double revenue;
  final int itemsSold;
  final double averageTicket;
  final String? from;
  final String? to;

  static SellerSalesMetrics fromJson(Map<String, dynamic> json) {
    final totals = _asMap(json['totals']);
    final metrics = _asMap(json['metrics']);
    final data = _asMap(json['data']);

    final ordersCount = _firstInt(<dynamic>[
      totals['ordersCount'],
      totals['orders'],
      metrics['ordersCount'],
      metrics['orders'],
      data['ordersCount'],
      data['orders'],
      json['ordersCount'],
      json['orders'],
    ]);

    final revenue = _firstDouble(<dynamic>[
      totals['revenue'],
      totals['grossRevenue'],
      totals['total'],
      metrics['revenue'],
      metrics['grossRevenue'],
      data['revenue'],
      json['revenue'],
      json['total'],
    ]);

    final itemsSold = _firstInt(<dynamic>[
      totals['itemsSold'],
      totals['items'],
      metrics['itemsSold'],
      metrics['items'],
      data['itemsSold'],
      data['items'],
      json['itemsSold'],
      json['items'],
    ]);

    final averageTicket = _firstDouble(<dynamic>[
      totals['averageTicket'],
      totals['avgTicket'],
      metrics['averageTicket'],
      metrics['avgTicket'],
      data['averageTicket'],
      data['avgTicket'],
      json['averageTicket'],
      json['avgTicket'],
    ]);

    final range = _asMap(json['range']);
    final from = _optionalString(range['from'] ?? json['from']);
    final to = _optionalString(range['to'] ?? json['to']);

    return SellerSalesMetrics(
      ordersCount: ordersCount,
      revenue: revenue,
      itemsSold: itemsSold,
      averageTicket: averageTicket,
      from: from,
      to: to,
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    return <String, dynamic>{};
  }

  static int _firstInt(List<dynamic> candidates) {
    for (final candidate in candidates) {
      if (candidate is int) {
        return candidate;
      }
      if (candidate is num) {
        return candidate.toInt();
      }
      final parsed = int.tryParse(candidate?.toString() ?? '');
      if (parsed != null) {
        return parsed;
      }
    }
    return 0;
  }

  static double _firstDouble(List<dynamic> candidates) {
    for (final candidate in candidates) {
      if (candidate is double) {
        return candidate;
      }
      if (candidate is num) {
        return candidate.toDouble();
      }
      final parsed = double.tryParse(candidate?.toString() ?? '');
      if (parsed != null) {
        return parsed;
      }
    }
    return 0;
  }

  static String? _optionalString(dynamic value) {
    final normalized = value?.toString().trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }
}
