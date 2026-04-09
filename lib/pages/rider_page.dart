import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../widgets/RiderHeader.dart';
import '../widgets/RiderStatusCard.dart';
import '../widgets/ActiveDeliveryCard.dart';
import '../widgets/OrderCard_UI.dart';
import '../widgets/OrderCard_data.dart';

class RiderPage extends StatelessWidget {
  const RiderPage({
    super.key,
    required this.session,
    required this.onLogout,
  });

  final AuthSession session;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0EA),
      body: Column(
        children: [
          RiderHeader(session: session, onLogout: onLogout),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // STATUS
                  RiderStatusCard(
                    isOnline: true,
                    riderName: session.displayName,
                    earningsToday: 482,
                    tripsToday: 12,
                  ),

                  const SizedBox(height: 20),

                  // INCOMING DELIVERIES
                  const Text(
                    'Incoming deliveries',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final int crossAxisCount = isDesktop ? 2 : 1;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: incomingOrders.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: isDesktop ? 1.45 : 1.18,
                        ),
                        itemBuilder: (context, index) {
                          final order = incomingOrders[index];

                          return OrderCardAlert(
                            order: order,
                            onAccept: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Orden ${order.orderId} aceptada por ${session.displayName}',
                                  ),
                                ),
                              );
                            },
                            onDecline: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Orden ${order.orderId} rechazada',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // ACTIVE DELIVERY
                  const Text(
                    'Active delivery',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const ActiveDeliveryCard(
                    remainingKm: 0.8,
                    pickup: 'Pickup – Rancho Los Alamos',
                    dropoff: 'Drop-off – María García',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final List<DeliveryOrderCard> incomingOrders = [
  DeliveryOrderCard(
    orderId: 'ORD-001',
    pickupLocation: 'CEDA, Iztapalapa',
    dropoffLocation: 'Roma Norte',
    distance: 3.2,
    estimatedTime: 18,
    price: 48,
    packages: 3,
    secondsToAccept: 18,
  ),
  DeliveryOrderCard(
    orderId: 'ORD-002',
    pickupLocation: 'Mercado de Abastos',
    dropoffLocation: 'Del Valle',
    distance: 5.4,
    estimatedTime: 22,
    price: 61,
    packages: 4,
    secondsToAccept: 15,
  ),
  DeliveryOrderCard(
    orderId: 'ORD-003',
    pickupLocation: 'Rancho Los Álamos',
    dropoffLocation: 'Narvarte',
    distance: 2.8,
    estimatedTime: 14,
    price: 39,
    packages: 2,
    secondsToAccept: 12,
  ),
];
