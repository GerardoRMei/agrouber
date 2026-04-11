import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _imagePicker = ImagePicker();
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
  List<XFile> _selectedImages = <XFile>[];

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

    if (_selectedImages.isEmpty) {
      setState(() {
        _errorMessage = 'Debes seleccionar al menos una imagen del producto.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final imageIds = <int>[];
      for (final image in _selectedImages) {
        final imageId = await _sellerApiService.uploadProductImage(
          session: widget.session,
          image: image,
        );
        imageIds.add(imageId);
      }

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
        imageIds: imageIds,
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
                            _buildResponsivePair(
                              left: _buildTextField(
                                controller: _priceController,
                                label: 'Precio',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: _validateDecimal,
                              ),
                              right: _buildTextField(
                                controller: _stockController,
                                label: 'Stock',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: _validateDecimal,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildResponsivePair(
                              left: DropdownButtonFormField<String>(
                                value: _selectedUnit,
                                isExpanded: true,
                                decoration: _inputDecoration('Unidad'),
                                items: _units
                                    .map(
                                      (unit) => DropdownMenuItem<String>(
                                        value: unit,
                                        child: Text(
                                          unit,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
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
                              right: DropdownButtonFormField<SellerCategory>(
                                value: _selectedCategory,
                                isExpanded: true,
                                decoration: _inputDecoration('Categoria'),
                                items: _categories
                                    .map(
                                      (category) => DropdownMenuItem<SellerCategory>(
                                        value: category,
                                        child: Text(
                                          category.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
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
                            const SizedBox(height: 16),
                            _buildResponsivePair(
                              left: _buildTextField(
                                controller: _skuController,
                                label: 'SKU (opcional)',
                              ),
                              right: _buildTextField(
                                controller: _minOrderQtyController,
                                label: 'Pedido minimo (opcional)',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: _validateOptionalDecimal,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _descriptionController,
                              label: 'Descripcion (opcional)',
                              maxLines: 4,
                            ),
                            const SizedBox(height: 16),
                            _buildImagePickerSection(),
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

  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imagenes del producto (obligatorio, maximo 5)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _pickImage,
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Seleccionar imagenes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFECE3D6),
                        foregroundColor: const Color(0xFF1F1209),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedImages.length}/5',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (_selectedImages.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                setState(() {
                                  _selectedImages = <XFile>[];
                                });
                              },
                        child: const Text('Limpiar'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final image = _selectedImages[index];
                return Stack(
                  children: [
                    FutureBuilder<Uint8List>(
                      future: image.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F4EE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Container(
                            width: 130,
                            height: 130,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F4EE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Error',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          );
                        }

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            snapshot.data!,
                            width: 130,
                            height: 130,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: _isSubmitting
                            ? null
                            : () {
                                setState(() {
                                  _selectedImages = List<XFile>.from(_selectedImages)
                                    ..removeAt(index);
                                });
                              },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final images = await _imagePicker.pickMultiImage(imageQuality: 85);

      if (!mounted || images.isEmpty) {
        return;
      }

      final merged = <XFile>[
        ..._selectedImages,
        ...images,
      ];
      final limited = merged.take(5).toList();

      setState(() {
        _selectedImages = limited;
        if (merged.length > 5) {
          _errorMessage = 'Solo se permiten maximo 5 imagenes por producto.';
        } else {
          _errorMessage = null;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'No se pudo seleccionar la imagen.';
      });
    }
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

  Widget _buildResponsivePair({
    required Widget left,
    required Widget right,
  }) {
    final compact = MediaQuery.of(context).size.width < 720;
    if (compact) {
      return Column(
        children: [
          left,
          const SizedBox(height: 16),
          right,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
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
