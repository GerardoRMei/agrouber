import 'package:flutter/material.dart';

import '../data/seller_api_service.dart';
import '../models/auth_session.dart';
import '../models/seller_category.dart';
import '../models/seller_product_request.dart';

class SellerProductFormPage extends StatefulWidget {
  const SellerProductFormPage({
    super.key,
    required this.session,
  });

  final AuthSession session;

  @override
  State<SellerProductFormPage> createState() => _SellerProductFormPageState();
}

class _SellerProductFormPageState extends State<SellerProductFormPage> {
  final SellerApiService _sellerApiService = SellerApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _minOrderQtyController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoadingCategories = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<SellerCategory> _categories = <SellerCategory>[];
  SellerCategory? _selectedCategory;
  String _selectedUnit = 'kg';

  static const List<String> _units = <String>[
    'kg',
    'pieza',
    'caja',
    'manojo',
    'bolsa',
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _minOrderQtyController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _errorMessage = null;
    });

    try {
      final categories = await _sellerApiService.fetchCategories(widget.session);
      if (!mounted) {
        return;
      }

      setState(() {
        _categories = categories;
        _selectedCategory = categories.isEmpty ? null : categories.first;
        _isLoadingCategories = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.toString();
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      setState(() {
        _errorMessage = 'Selecciona una categoria.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final request = SellerProductRequest(
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        unit: _selectedUnit,
        categoryId: _selectedCategory!.id,
        stock: double.parse(_stockController.text.trim()),
        sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
        minOrderQty: _minOrderQtyController.text.trim().isEmpty
            ? null
            : double.parse(_minOrderQtyController.text.trim()),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      await _sellerApiService.createProduct(
        session: widget.session,
        request: request,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo producto'),
        backgroundColor: const Color(0xFF1F1209),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _isLoadingCategories
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4A7A4D)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Registrar producto',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Version adaptada a tu estructura actual. Esta forma usa el endpoint /api/sellers/products y no depende de la refactorizacion por features.',
                              style: TextStyle(height: 1.5, color: Color(0xFF6B6B6B)),
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            _buildTextField(
                              controller: _nameController,
                              label: 'Nombre',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Escribe el nombre del producto.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _priceController,
                                    label: 'Precio',
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    validator: _validateDecimal,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _stockController,
                                    label: 'Stock',
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    validator: _validateDecimal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedUnit,
                                    decoration: _inputDecoration('Unidad'),
                                    items: _units
                                        .map(
                                          (unit) => DropdownMenuItem<String>(
                                            value: unit,
                                            child: Text(unit),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value == null) {
                                        return;
                                      }
                                      setState(() {
                                        _selectedUnit = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<SellerCategory>(
                                    value: _selectedCategory,
                                    decoration: _inputDecoration('Categoria'),
                                    items: _categories
                                        .map(
                                          (category) => DropdownMenuItem<SellerCategory>(
                                            value: category,
                                            child: Text(category.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCategory = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _skuController,
                                    label: 'SKU (opcional)',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _minOrderQtyController,
                                    label: 'Pedido minimo (opcional)',
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    validator: _validateOptionalDecimal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _descriptionController,
                              label: 'Descripcion (opcional)',
                              maxLines: 4,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF284826),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Guardar producto',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF8F4EE),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  String? _validateDecimal(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo requerido.';
    }

    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Escribe un numero valido.';
    }

    if (number < 0) {
      return 'No puede ser negativo.';
    }

    return null;
  }

  String? _validateOptionalDecimal(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Escribe un numero valido.';
    }

    if (number < 0) {
      return 'No puede ser negativo.';
    }

    return null;
  }
}
