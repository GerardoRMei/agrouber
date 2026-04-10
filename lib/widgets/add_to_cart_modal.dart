import 'package:flutter/material.dart';
import '../models/marketplace_product.dart';
import '../models/product_unit.dart';

class AddToCartModal extends StatefulWidget {
  final MarketplaceProduct product;
  final Function(ProductOption option, double quantity, String unitLabel, double finalPrice) onAddToCart;

  const AddToCartModal({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<AddToCartModal> createState() => _AddToCartModalState();
}

class _AddToCartModalState extends State<AddToCartModal> {
  ProductOption? _selectedOption;
  bool _useGrams = false;
  double _quantity = 1.0;

  @override
  void initState() {
    super.initState();
    if (widget.product.options.length == 1) {
      _selectedOption = widget.product.options.first;
    }
    if (widget.product.unit == ProductUnit.kg) {
      _quantity = 1.0;
    }
  }

  void _increment() {
    setState(() {
      if (_useGrams) {
        _quantity += 100;
      } else if (widget.product.unit == ProductUnit.kg) {
        _quantity += 0.5;
      } else {
        _quantity += 1.0;
      }
    });
  }

  void _decrement() {
    setState(() {
      if (_useGrams && _quantity > 100) {
        _quantity -= 100;
      } else if (!_useGrams && widget.product.unit == ProductUnit.kg && _quantity > 0.5) {
        _quantity -= 0.5;
      } else if (!_useGrams && widget.product.unit != ProductUnit.kg && _quantity > 1) {
        _quantity -= 1.0;
      }
    });
  }

  double get _calculatedPrice {
    if (_selectedOption == null) return 0.0;
    if (widget.product.unit == ProductUnit.kg && _useGrams) {
      return (_selectedOption!.price / 1000) * _quantity;
    }
    return _selectedOption!.price * _quantity;
  }

  String get _currentUnitLabel {
    if (widget.product.unit == ProductUnit.kg) {
      return _useGrams ? 'g' : 'Kg';
    }
    return widget.product.unit.displayName;
  }

  @override
  Widget build(BuildContext context) {
    final isKg = widget.product.unit == ProductUnit.kg;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Agregar ${widget.product.name}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F1209)),
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),

            const Text('1. Selecciona el vendedor', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            ...widget.product.options.map((option) {
              final isSelected = _selectedOption == option;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE9EFE3) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? const Color(0xFF4A7A4D) : Colors.grey.shade200, width: 2),
                ),
                child: RadioListTile<ProductOption>(
                  value: option,
                  groupValue: _selectedOption,
                  activeColor: const Color(0xFF4A7A4D),
                  onChanged: (val) => setState(() => _selectedOption = val),
                  title: Text(option.sellerName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('\$${option.price.toStringAsFixed(2)} ${widget.product.unit.suffix}'),
                ),
              );
            }),
            const SizedBox(height: 24),

            if (_selectedOption != null) ...[
              const Text('2. Selecciona la cantidad', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 16),
              
              if (isKg)
                Center(
                  child: ToggleButtons(
                    children: const [
                      Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text('Kilos')),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text('Gramos')),
                    ],
                    isSelected: [!_useGrams, _useGrams],
                    color: Colors.grey,
                    selectedColor: Colors.white,
                    fillColor: const Color(0xFF4A7A4D),
                    borderRadius: BorderRadius.circular(12),
                    onPressed: (index) {
                      setState(() {
                        final wantGrams = index == 1;
                        if (_useGrams != wantGrams) {
                          _useGrams = wantGrams;
                          _quantity = _useGrams ? 500.0 : 1.0; 
                        }
                      });
                    },
                  ),
                ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _decrement,
                    icon: const Icon(Icons.remove_circle_outline, size: 32, color: Color(0xFF4A7A4D)),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_useGrams ? _quantity.toStringAsFixed(0) : _quantity.toStringAsFixed(isKg ? 1 : 0)} $_currentUnitLabel',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: _increment,
                    icon: const Icon(Icons.add_circle_outline, size: 32, color: Color(0xFF4A7A4D)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E4F2F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => widget.onAddToCart(_selectedOption!, _quantity, _currentUnitLabel, _calculatedPrice),
                  child: Text(
                    'Agregar - \$${_calculatedPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}