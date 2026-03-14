import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

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
    final filteredProducts = allProducts.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesCategory = p.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1209),
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.only(left: 64.0),
          child: const Text(
            'Campo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ), 
        actions: [
          // Iconos de navegación similares a los que tenías en el Sidebar
          IconButton(
            icon: const Icon(Icons.home_rounded, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Stack(
              children: [
                Icon(Icons.shopping_cart_outlined, color: Colors.white),
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 7,
                    backgroundColor: Color(0xFFE09A2C),
                    child: Text('3', style: TextStyle(fontSize: 9, color: Colors.white)),
                  ),
                )
              ],
            ),
            onPressed: () {},
          ),
          Padding(
            padding: EdgeInsets.only(right: 64.0),
            child: IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado de bienvenida (ahora más limpio sin el botón de menú)
                  const Text(
                    'Welcome back, Gerard 👋',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const Text('What are you looking for today?', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  _buildSearchAndFilters(),
                  const SizedBox(height: 24),
                  const Text(
                    'Fresh picks',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 700 ? 2 : 1),
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) => ProductCard(product: filteredProducts[index]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
        setState(() {
          selectedCategory = category;
        });
      },
      selectedColor: const Color(0xFF4A7A4D),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }
}