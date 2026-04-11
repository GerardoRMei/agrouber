import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../models/address_draft.dart';
import '../models/auth_session.dart';
import '../models/cart_state.dart';
import '../models/product_unit.dart';
import '../widgets/address_form_sheet.dart';

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
  bool _isLoadingAddresses = true;
  bool _isAddressBusy = false;
  bool _isSubmitting = false;
  List<AddressBookEntry> _addressOptions = <AddressBookEntry>[];
  int? _selectedAddressId;

  final TextEditingController _savedCvvController = TextEditingController();
  final TextEditingController _newCardNumberController = TextEditingController();
  final TextEditingController _newCardNameController = TextEditingController();
  final TextEditingController _newCardExpiryController = TextEditingController();
  final TextEditingController _newCardCvvController = TextEditingController();
  final TextEditingController _newCardZipController = TextEditingController();

  final TextEditingController _referencesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    _savedCvvController.dispose();
    _newCardNumberController.dispose();
    _newCardNameController.dispose();
    _newCardExpiryController.dispose();
    _newCardCvvController.dispose();
    _newCardZipController.dispose();

    _referencesController.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses({
    int? preferredId,
    String? preferredDocumentId,
    String? preferredLabel,
  }) async {
    if (mounted) {
      setState(() => _isLoadingAddresses = true);
    }

    try {
      final rawAddresses = await _apiClient.fetchMyAddresses(
        authToken: widget.session.jwt,
      );
      if (!mounted) return;

      final parsed = rawAddresses
          .map((item) {
            try {
              return AddressBookEntry.fromApi(item);
            } catch (_) {
              return null;
            }
          })
          .whereType<AddressBookEntry>()
          .toList();

      int? selected = preferredId ?? _selectedAddressId;
      if (selected == null && preferredDocumentId != null) {
        for (final item in parsed) {
          if (item.documentId == preferredDocumentId) {
            selected = item.id;
            break;
          }
        }
      }
      if (selected == null && preferredLabel != null) {
        for (final item in parsed) {
          if (item.rawLabel == preferredLabel) {
            selected = item.id;
            break;
          }
        }
      }

      final selectedExists = parsed.any((item) => item.id == selected);
      if (!selectedExists) {
        selected = parsed.isEmpty ? null : parsed.first.id;
      }

      setState(() {
        _addressOptions = parsed;
        _selectedAddressId = selected;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _addressOptions = <AddressBookEntry>[];
        _selectedAddressId = null;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingAddresses = false);
      }
    }
  }

  AddressBookEntry? get _selectedAddress {
    for (final address in _addressOptions) {
      if (address.id == _selectedAddressId) {
        return address;
      }
    }
    return null;
  }

  Future<void> _openAddAddressForm() async {
    final draft = await showAddressFormSheet(
      context,
      title: 'Agregar direccion',
      submitLabel: 'Guardar direccion',
      initial: AddressDraft.empty(),
    );
    if (draft == null || !draft.hasRequiredFields) return;

    await _persistAddress(
      successMessage: 'Direccion guardada.',
      action: () async {
        final createdDocumentId = await _apiClient.createMyAddress(
          authToken: widget.session.jwt,
          userId: widget.session.userId,
          draft: draft,
        );
        await _loadAddresses(preferredDocumentId: createdDocumentId);
      },
    );
  }

  Future<void> _openEditAddressForm() async {
    final current = _selectedAddress;
    if (current == null) return;

    final initial = current.draft ?? AddressDraft.fromLegacyLabel(current.rawLabel);
    final draft = await showAddressFormSheet(
      context,
      title: 'Editar direccion',
      submitLabel: 'Guardar cambios',
      initial: initial,
    );
    if (draft == null || !draft.hasRequiredFields) return;

    await _persistAddress(
      successMessage: 'Direccion actualizada.',
      action: () async {
        await _apiClient.updateMyAddress(
          authToken: widget.session.jwt,
          userId: widget.session.userId,
          addressId: current.id,
          addressDocumentId: current.documentId,
          draft: draft,
        );
        await _loadAddresses(preferredId: current.id);
      },
    );
  }

  Future<void> _confirmDeleteAddress() async {
    final current = _selectedAddress;
    if (current == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar direccion'),
          content: const Text('Esta accion quitara la direccion seleccionada.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _persistAddress(
      successMessage: 'Direccion eliminada.',
      action: () async {
        await _apiClient.deleteMyAddress(
          authToken: widget.session.jwt,
          userId: widget.session.userId,
          addressId: current.id,
          addressDocumentId: current.documentId,
        );
        await _loadAddresses();
      },
    );
  }

  Future<void> _persistAddress({
    required String successMessage,
    required Future<void> Function() action,
  }) async {
    if (_isAddressBusy) return;
    setState(() => _isAddressBusy = true);

    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo completar la accion: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isAddressBusy = false);
      }
    }
  }

  Widget _buildAddressAliasTag(String alias) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EFE3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        alias,
        style: const TextStyle(
          color: Color(0xFF2E4F2F),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  double _quantityForApi(CartItem item) {
    final isGrams = item.unitLabel.trim().toLowerCase() == 'g';
    if (item.product.unit == ProductUnit.kg && isGrams) {
      return item.quantity / 1000;
    }
    return item.quantity;
  }

  Future<void> _processOrder() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF4A7A4D)),
      ),
    );

    try {
      final adressId = _selectedAddressId ??
          await _apiClient.fetchMyAddressId(
            authToken: widget.session.jwt,
          );

      if (adressId == null) {
        throw const ApiException(
          'No tienes una direccion registrada para completar la compra.',
        );
      }

      final checkoutItems = widget.cartState.items
          .map((item) => <String, dynamic>{
                'productId': item.option.productId,
                'quantity': _quantityForApi(item),
              })
          .where(
            (item) =>
                (item['productId'] as int? ?? 0) > 0 &&
                (item['quantity'] as num? ?? 0) > 0,
          )
          .toList();

      if (checkoutItems.isEmpty) {
        throw const ApiException(
          'No se pudo construir el pedido con los productos seleccionados.',
        );
      }

      await _apiClient.checkoutOrder(
        authToken: widget.session.jwt,
        adressId: adressId,
        items: checkoutItems,
        deliveryFee: _deliveryFee,
        notes: _referencesController.text,
      );

      if (!mounted) return;
      Navigator.pop(context);
      widget.cartState.clearCart();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          icon: const Icon(Icons.check_circle, color: Color(0xFF4A7A4D), size: 64),
          title: const Text('Pedido confirmado', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'Tu pedido fue enviado correctamente y ya esta en proceso.',
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
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Volver al inicio', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      );
    } on ApiException catch (error) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo completar el pedido. Intenta nuevamente.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
    return !_isLoadingAddresses && !_isAddressBusy && _selectedAddressId != null;
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
        const Text(
          'Direccion de entrega',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: _buildDeliveryAddressContent(),
        ),
      ],
    );
  }

  Widget _buildDeliveryAddressContent() {
    if (_isLoadingAddresses) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF4A7A4D)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Selecciona tu direccion de entrega',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _isAddressBusy ? null : _openAddAddressForm,
              icon: const Icon(Icons.add_location_alt_outlined, size: 18),
              label: const Text('Agregar'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_addressOptions.isEmpty) _buildEmptyAddressState(),
        if (_addressOptions.isNotEmpty) ...[
          ..._addressOptions.map(_buildAddressCard),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isAddressBusy || _selectedAddress == null
                      ? null
                      : _openEditAddressForm,
                  icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
                  label: const Text('Editar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isAddressBusy || _selectedAddress == null
                      ? null
                      : _confirmDeleteAddress,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Eliminar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _referencesController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Notas de entrega (opcional)',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildEmptyAddressState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5EF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2DBCF)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No hay direcciones guardadas.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'Agrega una direccion para continuar con tu compra.',
            style: TextStyle(color: Color(0xFF6E6259)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(AddressBookEntry address) {
    final selected = _selectedAddressId == address.id;
    return InkWell(
      onTap: _isAddressBusy
          ? null
          : () => setState(() => _selectedAddressId = address.id),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE9EFE3) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF2E4F2F) : const Color(0xFFE0D8CD),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<int>(
              value: address.id,
              groupValue: _selectedAddressId,
              activeColor: const Color(0xFF2E4F2F),
              onChanged: _isAddressBusy
                  ? null
                  : (value) => setState(() => _selectedAddressId = value),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildAddressAliasTag(address.alias),
                      if (selected) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Color(0xFF2E4F2F),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    address.primaryLine,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F1209),
                    ),
                  ),
                  if (address.secondaryLine != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      address.secondaryLine!,
                      style: const TextStyle(color: Color(0xFF6E6259)),
                    ),
                  ],
                  if (address.contactLine != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      address.contactLine!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6E6259),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
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
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: _buildMiniProductVisual(item.product.visual),
                  ),
                ),
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

  Widget _buildMiniProductVisual(String raw) {
    final visual = raw.trim();
    final isUrl = visual.startsWith('http://') ||
        visual.startsWith('https://') ||
        visual.startsWith('/');
    final resolved = isUrl ? _apiClient.resolveMediaUrl(visual) : visual;

    if (isUrl) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          resolved,
          width: 38,
          height: 38,
          fit: BoxFit.cover,
          errorBuilder: (context, _, __) {
            return const Icon(
              Icons.image_not_supported_outlined,
              size: 16,
              color: Color(0xFF8F958D),
            );
          },
        ),
      );
    }

    return Text(visual, style: const TextStyle(fontSize: 14));
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
        onPressed: (widget.cartState.items.isEmpty || !_isPaymentValid || !_isAddressValid || _isSubmitting) 
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

