import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/user.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/welcome_header.dart';
import '../widgets/market_product_card.dart';

class BuyerHomePage extends StatefulWidget {
  final User user;

  const BuyerHomePage({super.key, required this.user});

  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'Veggies';
  
  List<Map<String, dynamic>> _displayProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMarketData(); // Simular llamada a API al iniciar
  }

  // FUNCIÓN QUE SIMULA LA LLAMADA A LA API
  Future<void> _fetchMarketData() async {
    setState(() => _isLoading = true);
    
    // Simular latencia de red de 1.5 segundos
    await Future.delayed(const Duration(milliseconds: 1500));

    final Map<String, List<double>> groupedPrices = {};
    final Map<String, String> emojis = {};

    for (var seller in mockSellers) {
      for (var product in seller.products) {
        if (!groupedPrices.containsKey(product.name)) {
          groupedPrices[product.name] = [];
          emojis[product.name] = product.image;
        }
        double priceValue = double.tryParse(product.price.replaceAll('\$', '')) ?? 0;
        groupedPrices[product.name]!.add(priceValue);
      }
    }

    _displayProducts = groupedPrices.keys.map((name) {
      final prices = groupedPrices[name]!;
      prices.sort();
      
      String priceRange = prices.length > 1 && prices.first != prices.last
          ? '\$${prices.first.toStringAsFixed(0)} - \$${prices.last.toStringAsFixed(0)}'
          : '\$${prices.first.toStringAsFixed(0)}';

      return {
        'name': name,
        'image': emojis[name],
        'price': priceRange,
        'sellers': prices.length,
        'category': name == 'Banana' ? 'Fruits' : 'Veggies', // Categoría simplificada para el ejemplo
      };
    }).toList();

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _displayProducts.where((p) {
      final matchesSearch = p['name'].toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesCategory = p['category'] == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: const HomeAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SafeArea(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A7A4D)))
              : RefreshIndicator(
                  onRefresh: _fetchMarketData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 24.0), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WelcomeHeader(userName: widget.user.username),
                        const SizedBox(height: 24),
                        _buildSearchAndFilters(),
                        const SizedBox(height: 32),
                        Text(
                          selectedCategory == 'Veggies' ? 'Verduras Frescas' : 'Frutas de Temporada',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildProductGrid(filteredProducts, constraints),
                      ],
                    ),
                  ),
                ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(List<Map<String, dynamic>> products, BoxConstraints constraints) {
    if (products.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Text('No se encontraron productos.'),
      ));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.85,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return MarketProductCard(
          productName: product['name'],
          imageUrl: product['image'],
          priceDisplay: product['price'],
          sellerCount: product['sellers'],
        );
      },
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
              hintText: 'Buscar frutas, verduras, granos...',
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