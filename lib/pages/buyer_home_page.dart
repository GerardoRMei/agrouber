import 'package:agrouber/widgets/cart_panel.dart';
import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../models/auth_session.dart';
import '../models/cart_state.dart';
import '../models/marketplace_product.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/market_product_card.dart';
import '../widgets/welcome_header.dart';

class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({
    super.key,
    required this.session,
  });

  final AuthSession session;

  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  final ApiClient _apiClient = ApiClient();
  final CartState _cartState = CartState();
  final TextEditingController _searchController = TextEditingController();

  List<MarketplaceProduct> _displayProducts = <MarketplaceProduct>[];
  String? selectedCategory;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMarketData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMarketData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _apiClient.fetchMarketplaceProducts(
        authToken: widget.session.jwt,
      );
      final categories = products
          .map((product) => product.categoryName)
          .toSet()
          .toList()
        ..sort();

      if (!mounted) {
        return;
      }

      setState(() {
        _displayProducts = products;
        _errorMessage = null;
        selectedCategory = categories.isEmpty
            ? null
            : (categories.contains(selectedCategory) ? selectedCategory : categories.first);
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'No fue posible cargar los productos.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _displayProducts
        .map((product) => product.categoryName)
        .toSet()
        .toList()
      ..sort();

    final query = _searchController.text.toLowerCase();
    final filteredProducts = _displayProducts.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(query);
      final matchesCategory =
          selectedCategory == null || product.categoryName == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: HomeAppBar(cartState: _cartState),
      endDrawer: Drawer(
        width: 400,
        child: CartPanel(
          cartState: _cartState,
          isDrawer: true,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 600;
          final double hPadding = isMobile ? 20.0 : 64.0;

          if (_isLoading) {
            return const SafeArea(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF4A7A4D)),
              ),
            );
          }

          if (_errorMessage != null) {
            return SafeArea(
              child: RefreshIndicator(
                onRefresh: _fetchMarketData,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 32),
                  children: [
                    const SizedBox(height: 120),
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 54,
                      color: Color(0xFF4A7A4D),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Desliza hacia abajo para reintentar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: _fetchMarketData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WelcomeHeader(userName: widget.session.displayName),
                    const SizedBox(height: 24),
                    _buildSearchAndFilters(categories, constraints),
                    const SizedBox(height: 32),
                    Text(
                      selectedCategory ?? 'Mercado disponible',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildProductGrid(
    List<MarketplaceProduct> products,
    BoxConstraints constraints,
  ) {
    final bool isMobile = constraints.maxWidth <= 800;
    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('No se encontraron productos.'),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: isMobile ? 3.0 : 0.85,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return MarketProductCard(
          productName: product.name,
          imageUrl: product.visual,
          priceDisplay: product.priceDisplay,
          sellerCount: product.sellerCount,
          isMobile: isMobile,
          onAddToCart: () {
            if (product.options.length > 1) {
              _showSellerSelectionModal(context, product);
            } else {
              _addToCartAndNotify(product, product.options.first);
            }
          },
        );
      },
    );
  }

  void _showSellerSelectionModal(BuildContext context, MarketplaceProduct product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF3F0EA),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
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
                        'Selecciona un vendedor para ${product.name}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F1209)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Lista de vendedores
                ...product.options.map((option) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE9EFE3),
                        child: Icon(Icons.storefront, color: Color(0xFF4A7A4D)),
                      ),
                      title: Text(option.sellerName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Text(
                        '\$${option.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1F1209), fontSize: 16),
                      ),
                      onTap: () {
                        Navigator.pop(context); // Cierra el modal
                        _addToCartAndNotify(product, option); // Agrega al carrito
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addToCartAndNotify(MarketplaceProduct product, ProductOption selectedOption) {
    // Aquí deberás actualizar tu _cartState para que acepte la opción seleccionada.
    // Por ahora lo simulamos llamando al método actual:
    // _cartState.addProduct(product); // Idealmente: _cartState.addProduct(product, selectedOption);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} de ${selectedOption.sellerName} agregado al carrito'),
        backgroundColor: const Color(0xFF4A7A4D),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSearchAndFilters(List<String> categories, BoxConstraints constraints) {
    final bool isMobile = constraints.maxWidth < 600;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: isMobile ? double.infinity : 420,
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
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
        ...categories.map(_buildCategoryChip),
      ],
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = selectedCategory == category;

    return ChoiceChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          selectedCategory = category;
        });
      },
      selectedColor: const Color(0xFF4A7A4D),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }
}