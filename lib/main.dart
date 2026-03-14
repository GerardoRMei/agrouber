import 'package:flutter/material.dart';
// Importamos los nuevos archivos que creamos
import 'models/product.dart';
import 'widgets/product_card.dart';
import 'widgets/sidebar_nav.dart';

void main() {
  runApp(const CampoApp());
}

class CampoApp extends StatelessWidget {
  const CampoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campo',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F0EA),
        fontFamily: 'Arial',
      ),
      // Cambia a BuyerHomePage() para ver los cambios directamente
      home: const BuyerHomePage(), 
    );
  }
}

class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({super.key});

  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'Veggies';

  // Datos de ejemplo (En el futuro, esto podría venir de un Provider o API)
  final List<Product> allProducts = const [
    Product(name: 'Red Tomatoes', producer: 'EcoFarm', price: '\$2.50', unit: '/kg', emoji: '🍅', tag: 'Today', category: 'Veggies'),
    Product(name: 'Fresh Broccoli', producer: 'GreenLife', price: '\$3.20', unit: '/unit', emoji: '🥦', tag: 'Today', category: 'Veggies'),
    Product(name: 'Organic Carrots', producer: 'SunRoot', price: '\$1.80', unit: '/kg', emoji: '🥕', tag: '2 days', category: 'Veggies'),
    Product(name: 'Sweet Bananas', producer: 'TropicalS', price: '\$1.50', unit: '/kg', emoji: '🍌', tag: 'Today', category: 'Fruits'),
  ];

  @override
  Widget build(BuildContext context) {
    // Filtrado de productos
    final filteredProducts = allProducts.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesCategory = p.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 1000;

        return Scaffold(
          // Sidebar dinámico: Drawer en móvil, fijo en Desktop
          drawer: isDesktop ? null : const Drawer(child: SidebarNav()),
          body: Row(
            children: [
              if (isDesktop) const SizedBox(width: 260, child: SidebarNav()),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(isDesktop),
                      const SizedBox(height: 24),
                      _buildSearchAndFilters(),
                      const SizedBox(height: 24),
                      const Text(
                        'Fresh picks',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 700 ? 2 : 1),
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) => ProductCard(product: filteredProducts[index]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, Gerard 👋',
              style: TextStyle(fontSize: isDesktop ? 28 : 22, fontWeight: FontWeight.bold),
            ),
            const Text('What are you looking for today?', style: TextStyle(color: Colors.grey)),
          ],
        ),
        if (!isDesktop)
          Builder(builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          }),
      ],
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
        // Aquí podrías usar un PopupMenuButton para las categorías en móvil
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