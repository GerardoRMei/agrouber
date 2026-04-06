import 'package:flutter/material.dart';
import 'OrderCard_data.dart';

class OrderCardAlert extends StatelessWidget {
  const OrderCardAlert({
    super.key,
    required this.order,
    required this.onAccept,
    required this.onDecline,

  });

  final DeliveryOrderCard order;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFE89B27);
    const primaryDark = Color(0xFFD98C18);
    const cardLight = Color(0xFFF3B24B);
    const white = Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.notifications_active_rounded, color: white, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'NEW DELIVERY',
                  style: TextStyle(
                    color: white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${order.secondsToAccept}s left',
                  style: const TextStyle(
                    color: white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Route row
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.storefront_rounded, color: white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.pickupLocation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '—',
                    style: TextStyle(
                      color: white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(Icons.home_rounded, color: white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.dropoffLocation,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Stats
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  value: '${order.distance.toStringAsFixed(1)}km',
                  label: 'Distance',
                  color: cardLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatBox(
                  value: '${order.estimatedTime}min',
                  label: 'Est. time',
                  color: cardLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatBox(
                  value: '\$${order.price.toStringAsFixed(0)}',
                  label: 'Earnings',
                  color: cardLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatBox(
                  value: '${order.packages}',
                  label: 'Packages',
                  color: cardLight,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: white,
                      foregroundColor: primaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.check_box_rounded),
                    label: const Text(
                      'Accept Delivery',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 52,
                height: 52,
                child: ElevatedButton(
                  onPressed: onDecline,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: white.withValues(alpha: 0.18),
                    foregroundColor: white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}