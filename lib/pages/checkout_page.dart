import 'package:agrouber/data/api_client.dart';
import 'package:agrouber/models/auth_session.dart';
import 'package:flutter/material.dart';
import '../models/cart_state.dart';

class CheckoutPage extends StatefulWidget {
  final CartState cartState;
  final AuthSession session;

  const CheckoutPage({
    super.key, 
    required this.cartState,
    required this.session,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final ApiClient _apiClient = ApiClient();
  int _selectedPaymentMethod = 0;
  final double _deliveryFee = 45.00;
  bool _isEditingAddress = false;

  final TextEditingController _savedCvvController = TextEditingController();
  final TextEditingController _newCardNumberController = TextEditingController();
  final TextEditingController _newCardNameController = TextEditingController();
  final TextEditingController _newCardExpiryController = TextEditingController();
  final TextEditingController _newCardCvvController = TextEditingController();
  final TextEditingController _newCardZipController = TextEditingController();

  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _streetNameController = TextEditingController();
  final TextEditingController _extNumberController = TextEditingController();
  final TextEditingController _intNumberController = TextEditingController();
  final TextEditingController _neighborhoodController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _referencesController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  @override
  void dispose() {
    _savedCvvController.dispose();
    _newCardNumberController.dispose();
    _newCardNameController.dispose();
    _newCardExpiryController.dispose();
    _newCardCvvController.dispose();
    _newCardZipController.dispose();

    _receiverNameController.dispose();
    _streetNameController.dispose();
    _extNumberController.dispose();
    _intNumberController.dispose();
    _neighborhoodController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _referencesController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _processOrder() async {
    // 1. Mostrar loader de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF4A7A4D)),
      ),
    );

    try {
      // Calcular totales
      double subtotal = 0.0;
      for (var item in widget.cartState.items) {
        subtotal += item.finalPrice;
      }
      final double total = subtotal + _deliveryFee;

      // 2. Manejar la dirección (Si está editando, guardamos la nueva en Strapi)
      int? addressId;
      if (_isEditingAddress) {
        addressId = await _apiClient.createAddress(
          authToken: widget.session.jwt,
          addressData: {
            'label': 'Nueva Dirección',
            'recipientName': _receiverNameController.text.trim(),
            'street': _streetNameController.text.trim(),
            'externalNumber': _extNumberController.text.trim(),
            'internalNumber': _intNumberController.text.trim(),
            'neighborhood': _neighborhoodController.text.trim(),
            'city': _cityController.text.trim(),
            'state': _stateController.text.trim(),
            'zipCode': _zipCodeController.text.trim(),
            'phone': _phoneController.text.trim(),
            'references': _referencesController.text.trim(),
            // Strapi normalmente relaciona automáticamente al usuario creador si la API está protegida, 
            // pero si tu backend requiere el ID manual, puedes pasarlo así:
            // 'user': widget.session.user?.id, 
          },
        );
      }

      // 3. Crear cada OrderItem en el backend y recolectar sus IDs
      List<int> orderItemIds = [];
      
      for (var item in widget.cartState.items) {
        final itemId = await _apiClient.createOrderItem(
          authToken: widget.session.jwt,
          itemData: {
            'productNameSnapshot': item.product.name,
            'seller': item.option.sellerId,
            'quantity': item.quantity,
            'unitSnapshot': item.unitLabel,
            'unit_price': item.option.price,
            'subtotal': item.finalPrice,
          },
        );
        orderItemIds.add(itemId); // Guardamos el ID que Strapi nos devolvió
      }

      // 4. Crear la Orden vinculando los IDs recolectados
      await _apiClient.createOrder(
        authToken: widget.session.jwt,
        orderData: {
          'statusOrder': 'pending', 
          'payment_status': _selectedPaymentMethod == 0 ? 'pending' : 'paid',
          'subtotal': subtotal,
          'deliveryFee': _deliveryFee,
          'total': total,
          // Strapi ahora recibirá un arreglo de IDs: ej. [12, 13, 14]
          'items': orderItemIds, 
          
          if (addressId != null) 'address': addressId,
        },
      );

      if (!mounted) return;
      Navigator.pop(context); // Cierra el loader

      // 5. Éxito: Vaciar carrito y mostrar mensaje final
      widget.cartState.clearCart();
      _showSuccessDialog();

    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Cierra el loader en caso de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No pudimos procesar tu orden: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Extraje el diálogo de éxito a su propia función para mantener limpio el código
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.check_circle, color: Color(0xFF4A7A4D), size: 64),
        title: const Text('¡Pedido Confirmado!', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Tu pedido ha sido recibido por los productores y está siendo preparado para su envío.',
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E4F2F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
                Navigator.pop(context); // Regresa al Home
              },
              child: const Text('Volver al inicio', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  bool get _isPaymentValid {
    if (_selectedPaymentMethod == 0) {
      return true;
    } 
    else if (_selectedPaymentMethod == 1) {
      return _savedCvvController.text.length >= 3;
    } 
    else if (_selectedPaymentMethod == 2) {
      return _newCardNumberController.text.length >= 15 &&
             _newCardNameController.text.trim().isNotEmpty &&
             _newCardExpiryController.text.length >= 4 &&
             _newCardCvvController.text.length >= 3 &&
             _newCardZipController.text.length >= 4;
    }
    return false;
  }

  bool get _isAddressValid {
    if (!_isEditingAddress) return true;

    return _receiverNameController.text.trim().isNotEmpty &&
           _streetNameController.text.trim().isNotEmpty &&
           _extNumberController.text.trim().isNotEmpty &&
           _neighborhoodController.text.trim().isNotEmpty &&
           _stateController.text.trim().isNotEmpty &&
           _zipCodeController.text.trim().isNotEmpty &&
           _phoneController.text.trim().isNotEmpty &&
           _cityController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos el subtotal de los items
    double subtotal = 0.0;
    for (var item in widget.cartState.items) {
      subtotal += item.finalPrice;
    }
    final double total = subtotal + _deliveryFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0EA), // Fondo crema
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1209),
        title: const Text('Checkout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth > 800;

            if (isDesktop) {
              // ==========================================
              // VISTA DE ESCRITORIO (2 COLUMNAS)
              // ==========================================
              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200), 
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0), 
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildAddressSection(),
                                const SizedBox(height: 32),
                                _buildPaymentMethodSection(),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                        // Columna Derecha: Resumen (Toma el 40% del espacio)
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildSummarySection(subtotal, total),
                                const SizedBox(height: 32),
                                _buildConfirmButton(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // ==========================================
            // VISTA MÓVIL (1 COLUMNA)
            // ==========================================
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAddressSection(),
                      const SizedBox(height: 32),
                      _buildPaymentMethodSection(),
                      const SizedBox(height: 32),
                      _buildSummarySection(subtotal, total, wrapInContainer: true),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -4), blurRadius: 10),
                      ],
                    ),
                    child: _buildConfirmButton(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // WIDGETS AUXILIARES (Para reusar en ambos layouts)
  // ==========================================

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dirección de entrega', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          // Mostramos el formulario o la dirección guardada según el estado
          child: _isEditingAddress ? _buildAddressForm() : _buildSavedAddress(),
        ),
      ],
    );
  }

  // VISTA: DIRECCIÓN GUARDADA
  Widget _buildSavedAddress() {
    return Row(
      children: [
        const CircleAvatar(
          backgroundColor: Color(0xFFE9EFE3),
          child: Icon(Icons.location_on, color: Color(0xFF4A7A4D)),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Casa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Av. Universidad 123, Col. Centro\nAguascalientes, Ags.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isEditingAddress = true; // Abre el formulario
            });
          }, 
          child: const Text('Cambiar', style: TextStyle(color: Color(0xFF4A7A4D), fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  // VISTA: FORMULARIO DE NUEVA DIRECCIÓN
  Widget _buildAddressForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Nueva Dirección', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditingAddress = false; // Regresa a la dirección guardada
                });
              },
              child: const Text('Cancelar', style: TextStyle(color: Colors.redAccent)),
            )
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(_receiverNameController, 'Nombre del receptor*'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(flex: 2, child: _buildTextField(_streetNameController, 'Calle*')),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(_extNumberController, 'No. Ext*')),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(_intNumberController, 'No. Int')),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(_neighborhoodController, 'Colonia / Vecindario*'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextField(_cityController, 'Ciudad*')),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(_stateController, 'Estado*')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextField(_zipCodeController, 'Código Postal*', keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: _buildTextField(_phoneController, 'Teléfono*', keyboardType: TextInputType.phone)),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(_referencesController, 'Referencias (opcional)', maxLines: 2),
      ],
    );
  }

  // Widget auxiliar para crear TextFields más rápido y limpios
  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (_) => setState(() {}), // Refresca para la validación del botón
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Método de pago', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              // 1. EFECTIVO
              RadioListTile<int>(
                value: 0,
                groupValue: _selectedPaymentMethod,
                activeColor: const Color(0xFF4A7A4D),
                onChanged: (val) => setState(() {
                  _selectedPaymentMethod = val!;
                }),
                title: const Text('Efectivo al recibir', style: TextStyle(fontWeight: FontWeight.w600)),
                secondary: const Icon(Icons.payments_outlined, color: Colors.green),
              ),
              const Divider(height: 1),

              // 2. TARJETA GUARDADA
              RadioListTile<int>(
                value: 1,
                groupValue: _selectedPaymentMethod,
                activeColor: const Color(0xFF4A7A4D),
                onChanged: (val) => setState(() {
                  _selectedPaymentMethod = val!;
                }),
                title: const Text('Tarjeta terminada en •••• 4242', style: TextStyle(fontWeight: FontWeight.w600)),
                secondary: const Icon(Icons.credit_card, color: Colors.blueGrey),
              ),
              // Pide CVV si selecciona la tarjeta guardada
              if (_selectedPaymentMethod == 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(72, 0, 24, 16),
                  child: TextField(
                    controller: _savedCvvController,
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Código de seguridad (CVV)',
                      counterText: '', // Oculta el contador de caracteres
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}), // Refresca para habilitar/deshabilitar botón
                  ),
                ),
              const Divider(height: 1),

              // 3. AGREGAR NUEVA TARJETA
              RadioListTile<int>(
                value: 2,
                groupValue: _selectedPaymentMethod,
                activeColor: const Color(0xFF4A7A4D),
                onChanged: (val) => setState(() {
                  _selectedPaymentMethod = val!;
                }),
                title: const Text('Agregar nueva tarjeta', style: TextStyle(fontWeight: FontWeight.w600)),
                secondary: const Icon(Icons.add_card, color: Colors.black87),
              ),
              // Formulario de nueva tarjeta
              if (_selectedPaymentMethod == 2)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      TextField(
                        controller: _newCardNumberController,
                        keyboardType: TextInputType.number,
                        maxLength: 16,
                        decoration: const InputDecoration(
                          labelText: 'Número de tarjeta',
                          counterText: '',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _newCardNameController,
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          labelText: 'Nombre en la tarjeta',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _newCardExpiryController,
                              keyboardType: TextInputType.datetime,
                              maxLength: 5,
                              decoration: const InputDecoration(
                                labelText: 'MM/AA',
                                counterText: '',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _newCardCvvController,
                              keyboardType: TextInputType.number,
                              maxLength: 3,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'CVV',
                                counterText: '',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _newCardZipController,
                              keyboardType: TextInputType.number,
                              maxLength: 5,
                              decoration: const InputDecoration(
                                labelText: 'C.P.',
                                counterText: '',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(double subtotal, double total, {bool wrapInContainer = false}) {
    final items = widget.cartState.items;

    final summaryContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (wrapInContainer) ...[
           const Text('Resumen del pedido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
           const SizedBox(height: 16),
        ],
        if (!wrapInContainer)
           const Padding(
             padding: EdgeInsets.only(bottom: 24),
             child: Text('Resumen del pedido', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
           ),
           
        ...items.map((item) {
          final qtyDisplay = item.quantity.truncateToDouble() == item.quantity 
              ? item.quantity.toStringAsFixed(0) 
              : item.quantity.toStringAsFixed(1);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$qtyDisplay ${item.unitLabel} • de ${item.option.sellerName}',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${item.finalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ],
            ),
          );
        }),

        const Divider(height: 24, thickness: 1),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Subtotal', style: TextStyle(color: Colors.grey, fontSize: 15)),
            Text('\$${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Costo de envío', style: TextStyle(color: Colors.grey, fontSize: 15)),
            Text('\$${_deliveryFee.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Divider(height: 1),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text(
              '\$${total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF1F1209)),
            ),
          ],
        ),
      ],
    );

    if (wrapInContainer) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: summaryContent,
      );
    }

    return summaryContent;
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E4F2F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: (widget.cartState.items.isEmpty || !_isPaymentValid || !_isAddressValid) 
          ? null 
          : _processOrder,
        child: const Text(
          'Confirmar Pedido',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}