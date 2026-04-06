import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../features/account/presentation/screens/customer_account_screen.dart';
import '../features/auth/models/auth_session.dart';
import '../features/buyer/controllers/buyer_cart_controller.dart';
import '../features/buyer/presentation/screens/cart_screen.dart';
import '../models/marketplace_product.dart';
import '../shared/theme/agrorun_theme.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/market_product_card.dart';
import '../widgets/welcome_header.dart';

class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({
    super.key,
    required this.session,
    required this.onSessionChanged,
    required this.onLogout,
  });

  final AuthSession session;
  final ValueChanged<AuthSession> onSessionChanged;
  final VoidCallback onLogout;

  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();
  late final BuyerCartController _cartController;

  List<MarketplaceProduct> _displayProducts = <MarketplaceProduct>[];
  String? selectedCategory;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cartController = BuyerCartController();
    _fetchMarketData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cartController.dispose();
    super.dispose();
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CartScreen(
          controller: _cartController,
          customerName: widget.session.displayName,
        ),
      ),
    );
  }

  void _openAccount() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CustomerAccountScreen(
          session: widget.session,
          onSessionChanged: widget.onSessionChanged,
          onLogout: widget.onLogout,
        ),
      ),
    );
  }

  void _addToCart(MarketplaceProduct product) {
    setState(() {
      _cartController.addProduct(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} se agrego a tu carrito'),
        duration: const Duration(seconds: 2),
      ),
    );
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
        selectedCategory =
            categories.contains(selectedCategory) ? selectedCategory : null;
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedBuilder(
          animation: _cartController,
          builder: (context, _) => HomeAppBar(
            cartCount: _cartController.itemCount,
            onCartTap: _openCart,
            onProfileTap: _openAccount,
            profileImageUrl: widget.session.profileImageUrl,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _cartController,
        builder: (context, _) => LayoutBuilder(
          builder: (context, constraints) {
          if (_isLoading) {
            return const SafeArea(
              child: Center(
                child: CircularProgressIndicator(color: AgrorunPalette.forest),
              ),
            );
          }

          if (_errorMessage != null) {
            return SafeArea(
              child: RefreshIndicator(
                onRefresh: _fetchMarketData,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(32),
                  children: [
                    const SizedBox(height: 120),
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 54,
                      color: AgrorunPalette.forest,
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
                      style: TextStyle(color: AgrorunPalette.textMuted),
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
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth < 700 ? 20 : 64,
                  vertical: constraints.maxWidth < 700 ? 20 : 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BuyerHero(
                      session: widget.session,
                      cartController: _cartController,
                    ),
                    const SizedBox(height: 24),
                    WelcomeHeader(userName: widget.session.displayName),
                    const SizedBox(height: 24),
                    _buildSearchAndFilters(categories),
                    const SizedBox(height: 32),
                    Text(
                      selectedCategory ?? 'Todo el mercado',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AgrorunPalette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${filteredProducts.length} opciones disponibles para tu compra',
                      style: const TextStyle(
                        color: AgrorunPalette.textMuted,
                        fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildProductGrid(
    List<MarketplaceProduct> products,
    BoxConstraints constraints,
  ) {
    if (products.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Text(
          'No se encontraron productos disponibles por ahora.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final isMobile = constraints.maxWidth < 700;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1),
        crossAxisSpacing: isMobile ? 14 : 20,
        mainAxisSpacing: isMobile ? 14 : 20,
        childAspectRatio: isMobile ? 1.05 : 0.85,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return MarketProductCard(
          categoryName: product.categoryName,
          productName: product.name,
          imageUrl: product.visual,
          priceDisplay: product.priceDisplay,
          sellerCount: product.sellerCount,
          quantityInCart: _cartController.quantityFor(product),
          onAddToCart: () => _addToCart(product),
        );
      },
    );
  }

  Widget _buildSearchAndFilters(List<String> categories) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: isMobile ? width - 40 : 420,
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Buscar frutas, verduras, granos...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        _buildAllChip(),
        ...categories.map(_buildCategoryChip),
      ],
    );
  }

  Widget _buildAllChip() {
    final isSelected = selectedCategory == null;

    return ChoiceChip(
      label: const Text('Todo'),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          selectedCategory = null;
        });
      },
      selectedColor: AgrorunPalette.forest,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AgrorunPalette.textPrimary,
      ),
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
      selectedColor: AgrorunPalette.forest,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AgrorunPalette.textPrimary,
      ),
    );
  }
}

class _BuyerHero extends StatelessWidget {
  const _BuyerHero({
    required this.session,
    required this.cartController,
  });

  final AuthSession session;
  final BuyerCartController cartController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: cartController,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AgrorunPalette.forestDark,
                AgrorunPalette.forest,
                AgrorunPalette.leaf,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Compra fresca y sin complicaciones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                cartController.isEmpty
                    ? 'Explora el mercado, elige productos y arma un pedido en minutos.'
                    : 'Ya tienes ${cartController.itemCount} articulo${cartController.itemCount == 1 ? '' : 's'} en tu carrito. Continua con tu pedido cuando quieras.',
                style: const TextStyle(
                  color: Color(0xFFE7F1E8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _HeroPill(
                    label: session.roleType == 'customer' ? 'Cuenta compradora' : 'Explorando como comprador',
                  ),
                  _HeroPill(
                    label: cartController.isEmpty
                        ? 'Carrito listo para empezar'
                        : 'Total estimado \$${cartController.total.toStringAsFixed(0)}',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
