import 'package:flutter/material.dart';

class ActiveDeliveryCard extends StatelessWidget {
  const ActiveDeliveryCard({
    super.key,
    required this.remainingKm,
    required this.pickup,
    required this.dropoff,
  });

  final double remainingKm;
  final String pickup;
  final String dropoff;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Map placeholder
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFDCE5D3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'On route · ${remainingKm.toStringAsFixed(1)} km remaining',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.inventory_2),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      pickup,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.home),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      dropoff,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}