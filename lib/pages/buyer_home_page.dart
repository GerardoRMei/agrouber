import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/welcome_header.dart';

class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({super.key});

  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'Veggies';

  final List<Product> allProducts = const [
    Product(name: 'Red Tomatoes', producer: 'EcoFarm', price: '\$2.50', unit: '/kg', emoji: '🍅', tag: 'Today', category: 'Veggies'),
    Product(name: 'Fresh Broccoli', producer: 'GreenLife', price: '\$3.20', unit: '/unit', emoji: '🥦', tag: 'Today', category: 'Veggies'),
    Product(name: 'Organic Carrots', producer: 'SunRoot', price: '\$1.80', unit: '/kg', emoji: '🥕', tag: '2 days', category: 'Veggies'),
    Product(name: 'Sweet Bananas', producer: 'TropicalS', price: '\$1.50', unit: '/kg', emoji: '🍌', tag: 'Today', category: 'Fruits'),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _getFilteredProducts();

    return Scaffold(
      appBar: const HomeAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WelcomeHeader(userName: 'Gerard'),
                  const SizedBox(height: 24),
                  _buildSearchAndFilters(),
                  const SizedBox(height: 32),
                  const Text(
                    'Fresh picks',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildProductGrid(filteredProducts, constraints),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Product> _getFilteredProducts() {
    return allProducts.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesCategory = p.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Widget _buildProductGrid(List<Product> products, BoxConstraints constraints) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 800 ? 2 : 1),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.85,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => ProductCard(product: products[index]),
    );
  }

  Widget _buildSearchAndFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildCategoryChip('Veggies'),
        const SizedBox(width: 8),
        _buildCategoryChip('Fruits'),
      ],
    );
  }

  Widget _buildCategoryChip(String category) {
    final bool isSelected = selectedCategory == category;
    return ChoiceChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() => selectedCategory = category);
      },
      selectedColor: const Color(0xFF4A7A4D),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }
}