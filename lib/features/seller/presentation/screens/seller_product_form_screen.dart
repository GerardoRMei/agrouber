import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/models/app_media.dart';
import '../../../../shared/services/media_api_service.dart';
import '../../../../shared/theme/agrorun_theme.dart';
import '../../../account/presentation/widgets/account_components.dart';
import '../../../auth/models/auth_session.dart';
import '../../controllers/seller_products_controller.dart';
import '../../models/seller_product.dart';
import '../../models/seller_product_request.dart';

class SellerProductFormScreen extends StatefulWidget {
  const SellerProductFormScreen({
    super.key,
    required this.controller,
    this.initialProduct,
  });

  final SellerProductsController controller;
  final SellerProduct? initialProduct;

  bool get isEditing => initialProduct != null;

  @override
  State<SellerProductFormScreen> createState() => _SellerProductFormScreenState();
}

class _SellerProductFormScreenState extends State<SellerProductFormScreen> {
  static const int _maxImages = 5;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _minOrderQtyController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final MediaApiService _mediaApiService = MediaApiService();
  final ImagePicker _imagePicker = ImagePicker();

  late List<AppMedia> _existingImages;
  final List<_LocalProductImage> _newImages = <_LocalProductImage>[];

  String _selectedUnit = 'kg';
  int? _selectedCategoryId;
  bool _isUploadingImages = false;
  String? _localErrorMessage;

  @override
  void initState() {
    super.initState();
    widget.controller.loadCategories();
    _hydrateInitialValues();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _minOrderQtyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _hydrateInitialValues() {
    final product = widget.initialProduct;
    if (product == null) {
      _existingImages = <AppMedia>[];
      return;
    }

    _nameController.text = product.name;
    _priceController.text =
        product.price.toStringAsFixed(product.price.truncateToDouble() == product.price ? 0 : 2);
    _stockController.text =
        product.stock.toStringAsFixed(product.stock.truncateToDouble() == product.stock ? 0 : 2);
    _minOrderQtyController.text = product.minOrderQty == null
        ? ''
        : product.minOrderQty!.toStringAsFixed(
            product.minOrderQty!.truncateToDouble() == product.minOrderQty! ? 0 : 2,
          );
    _descriptionController.text = product.description ?? '';
    _selectedUnit = product.unit ?? 'kg';
    _selectedCategoryId = product.categoryId;
    _existingImages = List<AppMedia>.from(product.images);
  }

  AuthSession get _session => widget.controller.session;

  int get _totalImageCount => _existingImages.length + _newImages.length;

  Future<void> _pickImages() async {
    final picked = await _imagePicker.pickMultiImage(imageQuality: 88);
    if (picked.isEmpty || !mounted) {
      return;
    }

    final remainingSlots = _maxImages - _totalImageCount;
    if (remainingSlots <= 0) {
      setState(() {
        _localErrorMessage = 'Puedes cargar hasta $_maxImages imagenes por producto.';
      });
      return;
    }

    final selected = picked.take(remainingSlots).toList();
    final previews = <_LocalProductImage>[];

    for (final file in selected) {
      final bytes = await file.readAsBytes();
      previews.add(_LocalProductImage(file: file, bytes: bytes));
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _newImages.addAll(previews);
      _localErrorMessage = picked.length > remainingSlots
          ? 'Solo se agregaron $remainingSlots imagenes para respetar el limite de $_maxImages.'
          : null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      setState(() {
        _localErrorMessage =
            _selectedCategoryId == null ? 'Selecciona una categoria.' : _localErrorMessage;
      });
      return;
    }

    setState(() {
      _isUploadingImages = true;
      _localErrorMessage = null;
    });

    try {
      final uploadedMedia = _newImages.isEmpty
          ? <AppMedia>[]
          : await _mediaApiService.uploadImages(
              session: _session,
              files: _newImages.map((image) => image.file).toList(),
            );

      final request = SellerProductRequest(
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        stock: double.parse(_stockController.text.trim()),
        unit: _selectedUnit,
        categoryId: _selectedCategoryId!,
        minOrderQty: _minOrderQtyController.text.trim().isEmpty
            ? null
            : double.parse(_minOrderQtyController.text.trim()),
        description: _descriptionController.text.trim(),
        imageIds: <int>[
          ..._existingImages.map((image) => image.id),
          ...uploadedMedia.map((image) => image.id),
        ],
        includeImagesField: widget.isEditing,
      );

      final ok = widget.isEditing
          ? await widget.controller.updateProduct(
              productId: widget.initialProduct!.id,
              request: request,
            )
          : await widget.controller.createProduct(request);

      if (!mounted || !ok) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Actualizamos tu producto.'
                : 'Tu producto se publico correctamente.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _localErrorMessage = 'No pudimos guardar tu producto.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImages = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar producto' : 'Nuevo producto'),
      ),
      backgroundColor: AgrorunPalette.cream,
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final categories = widget.controller.categories;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProductHero(isEditing: widget.isEditing),
                  if (widget.controller.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    InlineErrorCard(message: widget.controller.errorMessage!),
                  ],
                  if (_localErrorMessage != null) ...[
                    const SizedBox(height: 16),
                    InlineErrorCard(message: _localErrorMessage!),
                  ],
                  const SizedBox(height: 18),
                  const _FormTitle(
                    title: 'Imagenes del producto',
                    subtitle:
                        'Agrega fotos claras de tu producto para que destaque dentro del catálogo.',
                  ),
                  const SizedBox(height: 12),
                  _FormCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '$_totalImageCount de $_maxImages imagenes',
                                style: const TextStyle(
                                  color: AgrorunPalette.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed:
                                  _isUploadingImages || _totalImageCount >= _maxImages
                                      ? null
                                      : _pickImages,
                              icon: const Icon(Icons.add_photo_alternate_outlined),
                              label: const Text('Agregar'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final image in _existingImages)
                              MediaThumb(
                                media: image,
                                onRemove: () {
                                  setState(() {
                                    _existingImages =
                                        _existingImages.where((item) => item.id != image.id).toList();
                                  });
                                },
                              ),
                            for (var index = 0; index < _newImages.length; index++)
                              MediaThumb(
                                localBytes: _newImages[index].bytes,
                                onRemove: () {
                                  setState(() {
                                    _newImages.removeAt(index);
                                  });
                                },
                              ),
                            if (_existingImages.isEmpty && _newImages.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6F1E8),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Text(
                                  'Todavia no has agregado imagenes. Sube fotos del producto, su empaque o presentacion.',
                                  style: TextStyle(
                                    color: AgrorunPalette.textMuted,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _FormTitle(
                    title: 'Informacion principal',
                    subtitle:
                        'Completa los datos clave para que el producto quede listo para publicarse.',
                  ),
                  const SizedBox(height: 12),
                  _FormCard(
                    child: Column(
                      children: [
                        _field(
                          controller: _nameController,
                          label: 'Nombre del producto',
                          hintText: 'Ej. Tomate saladette',
                          validator: (value) => _required(value, 'El nombre del producto'),
                        ),
                        _field(
                          controller: _priceController,
                          label: 'Precio',
                          hintText: 'Ej. 34.50',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: _numberValidator(
                            label: 'El precio',
                            allowZero: false,
                          ),
                        ),
                        _field(
                          controller: _stockController,
                          label: 'Stock disponible',
                          hintText: 'Ej. 120',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: _numberValidator(label: 'El stock disponible'),
                        ),
                        DropdownButtonFormField<String>(
                          value: _selectedUnit,
                          decoration: _inputDecoration(
                            'Unidad de venta',
                            hintText: 'Selecciona una unidad',
                          ),
                          items: const ['kg', 'pieza', 'caja', 'manojo', 'bolsa']
                              .map(
                                (unit) => DropdownMenuItem<String>(
                                  value: unit,
                                  child: Text(unit),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedUnit = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _selectedCategoryId,
                          decoration: _inputDecoration(
                            'Categoria',
                            hintText: 'Selecciona una categoria',
                          ),
                          items: categories
                              .map(
                                (category) => DropdownMenuItem<int>(
                                  value: category.id,
                                  child: Text(category.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Selecciona una categoria' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _FormTitle(
                    title: 'Condiciones de venta',
                    subtitle:
                        'Agrega detalles que ayuden a los compradores a entender mejor tu oferta.',
                  ),
                  const SizedBox(height: 12),
                  _FormCard(
                    child: Column(
                      children: [
                        _field(
                          controller: _minOrderQtyController,
                          label: 'Compra minima',
                          hintText: 'Ej. 2',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return null;
                            }
                            return _numberValidator(label: 'La compra minima')(value);
                          },
                        ),
                        _field(
                          controller: _descriptionController,
                          label: 'Descripcion',
                          hintText:
                              'Describe calidad, presentacion o informacion importante',
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: widget.controller.isSubmitting || _isUploadingImages
                          ? null
                          : _submit,
                      child: widget.controller.isSubmitting || _isUploadingImages
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.isEditing
                                  ? 'Guardar cambios'
                                  : 'Publicar producto',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hintText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: _inputDecoration(label, hintText: hintText),
      ),
    );
  }

  String? Function(String?) _numberValidator({
    required String label,
    bool allowZero = true,
  }) {
    return (value) {
      final required = _required(value, label);
      if (required != null) {
        return required;
      }

      final parsed = double.tryParse(value!.trim());
      if (parsed == null) {
        return 'Ingresa un valor valido';
      }
      if (parsed < 0 || (!allowZero && parsed <= 0)) {
        return allowZero
            ? 'El valor no puede ser negativo'
            : 'El valor debe ser mayor a cero';
      }
      return null;
    };
  }

  String? _required(String? value, String label) {
    if ((value ?? '').trim().isEmpty) {
      return '$label es requerido';
    }
    return null;
  }

  InputDecoration _inputDecoration(String label, {String? hintText}) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
    );
  }
}

class _ProductHero extends StatelessWidget {
  const _ProductHero({required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AgrorunPalette.forestDark,
            AgrorunPalette.forest,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 30),
          const SizedBox(height: 14),
          Text(
            isEditing ? 'Refina tu producto' : 'Publica un nuevo producto',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isEditing
                ? 'Actualiza precio, stock, fotos o detalles clave para mantener tu catálogo siempre fresco.'
                : 'Crea una ficha clara y comercial para que tu producto quede listo dentro de tu catálogo.',
            style: const TextStyle(
              color: Color(0xFFE6F0E7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormTitle extends StatelessWidget {
  const _FormTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AgrorunPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: AgrorunPalette.textMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

class _LocalProductImage {
  const _LocalProductImage({
    required this.file,
    required this.bytes,
  });

  final XFile file;
  final Uint8List bytes;
}
