import 'package:flutter/material.dart';

class RiderStatusCard extends StatelessWidget {
  const RiderStatusCard({
    super.key,
    required this.isOnline,
    required this.riderName,
    required this.earningsToday,
    required this.tripsToday,
  });

  final bool isOnline;
  final String riderName;
  final double earningsToday;
  final int tripsToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E140A), // café oscuro
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Left
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isOnline
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: isOnline ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: isOnline ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Rider · $riderName',
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Right
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${earningsToday.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Today · $tripsToday trips',
                style: const TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }
}