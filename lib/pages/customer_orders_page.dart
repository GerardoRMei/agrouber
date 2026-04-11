import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../models/auth_session.dart';
import '../models/order_summary.dart';

class CustomerOrdersPage extends StatefulWidget {
  const CustomerOrdersPage({
    super.key,
    required this.session,
  });

  final AuthSession session;

  @override
  State<CustomerOrdersPage> createState() => _CustomerOrdersPageState();
}

class _CustomerOrdersPageState extends State<CustomerOrdersPage> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  String? _errorMessage;
  List<OrderSummary> _orders = <OrderSummary>[];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orders = await _apiClient.fetchCustomerOrders(
        authToken: widget.session.jwt,
        userId: widget.session.userId,
      );
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis compras'),
        backgroundColor: const Color(0xFF1F1209),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (_isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF4A7A4D)),
              );
            }

            if (_errorMessage != null && _orders.isEmpty) {
              return _StateMessage(
                title: 'No se pudieron cargar tus ordenes',
                message: _errorMessage!,
                buttonLabel: 'Reintentar',
                onPressed: _loadOrders,
              );
            }

            if (_orders.isEmpty) {
              return _StateMessage(
                title: 'Aun no tienes ordenes',
                message: 'Tus compras apareceran aqui cuando completes tu primer pedido.',
                buttonLabel: 'Actualizar',
                onPressed: _loadOrders,
              );
            }

            return RefreshIndicator(
              onRefresh: _loadOrders,
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _OrderTile(order: _orders[index], forSeller: false);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({
    required this.order,
    required this.forSeller,
  });

  final OrderSummary order;
  final bool forSeller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.reference,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusChip(status: order.statusLabel),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(
                status: 'Pago: ${order.paymentStatusLabel}',
                isPayment: true,
              ),
              _StatusChip(status: '${order.itemCount} item${order.itemCount == 1 ? '' : 's'}'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${forSeller ? 'Cliente' : 'Vendedor'}: ${order.counterpartyName}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(order.itemsDescription),
          if (order.deliveryAddress != null) ...[
            const SizedBox(height: 6),
            Text(
              'Entrega: ${order.deliveryAddress}',
              style: const TextStyle(color: Color(0xFF6B6B6B)),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                order.totalLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF284826),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                order.createdAtLabel,
                style: const TextStyle(color: Color(0xFF6B6B6B)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    this.isPayment = false,
  });

  final String status;
  final bool isPayment;

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    final isComplete = normalized.contains('entreg') ||
        normalized.contains('paid') ||
        normalized.contains('complete');
    final isCancelled = normalized.contains('cancel');

    final color = isPayment
        ? const Color(0xFFF0EFE9)
        : isComplete
        ? const Color(0xFFE0F0E2)
        : isCancelled
            ? const Color(0xFFF0E3E0)
            : const Color(0xFFEAF0F8);
    final textColor = isPayment
        ? const Color(0xFF5F564D)
        : isComplete
        ? const Color(0xFF284826)
        : isCancelled
            ? const Color(0xFF8A2E1B)
            : const Color(0xFF1D4B7A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 42,
                  color: Color(0xFF284826),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(height: 1.5, color: Color(0xFF6B6B6B)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF284826),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(buttonLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
