import 'package:flutter/material.dart';

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
      home: const BuyerHomePage(),
    );
  }
}

class Product {
  final String name;
  final String producer;
  final String price;
  final String unit;
  final String emoji;
  final String tag;
  final String category;

  const Product({
    required this.name,
    required this.producer,
    required this.price,
    required this.unit,
    required this.emoji,
    required this.tag,
    required this.category,
  });
}

class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({super.key});

  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = const [
    'All',
    'Veggies',
    'Fruits',
    'Protein',
    'Grains',
    'Dairy',
  ];

  String selectedCategory = 'Veggies';

  final List<Product> products = const [
    Product(
      name: 'Saladette Tomato',
      producer: 'Rancho Los Alamos',
      price: '\$18',
      unit: '/kg',
      emoji: '🍅',
      tag: 'Today',
      category: 'Veggies',
    ),
    Product(
      name: 'White Onion',
      producer: 'Finca Morales',
      price: '\$12',
      unit: '/kg',
      emoji: '🧅',
      tag: '2 days',
      category: 'Veggies',
    ),
    Product(
      name: 'Serrano Chili',
      producer: 'Ejido San Pedro',
      price: '\$32',
      unit: '/kg',
      emoji: '🌶️',
      tag: 'Today',
      category: 'Veggies',
    ),
    Product(
      name: 'Broccoli',
      producer: 'Granja Verde',
      price: '\$22',
      unit: '/kg',
      emoji: '🥦',
      tag: 'Today',
      category: 'Veggies',
    ),
    Product(
      name: 'Banana',
      producer: 'Huerta del Sol',
      price: '\$20',
      unit: '/kg',
      emoji: '🍌',
      tag: 'Fresh',
      category: 'Fruits',
    ),
    Product(
      name: 'Apple',
      producer: 'Campos del Norte',
      price: '\$28',
      unit: '/kg',
      emoji: '🍎',
      tag: 'Fresh',
      category: 'Fruits',
    ),
  ];

  List<Product> get filteredProducts {
    final query = _searchController.text.trim().toLowerCase();

    return products.where((product) {
      final categoryMatch =
          selectedCategory == 'All' || product.category == selectedCategory;

      final queryMatch =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.producer.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);

      return categoryMatch && queryMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 1000;
        final bool isTablet = constraints.maxWidth >= 700;

        return Scaffold(
          drawer: isDesktop ? null : const Drawer(child: SidebarNav()),
          body: Row(
            children: [
              if (isDesktop) const SizedBox(width: 260, child: SidebarNav()),
              Expanded(
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeaderSection(
                          isDesktop: isDesktop,
                          onMenuTap: () {
                            if (!isDesktop) {
                              Scaffold.of(context).openDrawer();
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        const PromoBanner(),
                        const SizedBox(height: 20),
                        SearchBarSection(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 18),
                        CategorySection(
                          categories: categories,
                          selectedCategory: selectedCategory,
                          onCategorySelected: (value) {
                            setState(() => selectedCategory = value);
                          },
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Fresh picks',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                            Text(
                              '${filteredProducts.length} products',
                              style: const TextStyle(
                                color: Color(0xFF6E6E6E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GridView.builder(
                          itemCount: filteredProducts.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isDesktop
                                ? 2
                                : isTablet
                                    ? 2
                                    : 1,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: isDesktop ? 1.05 : 1.12,
                          ),
                          itemBuilder: (context, index) {
                            return ProductCard(product: filteredProducts[index]);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SidebarNav extends StatelessWidget {
  const SidebarNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1F1209),
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Campo',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'SHOP',
            style: TextStyle(
              color: Color(0xFF8E7F74),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _navTile(Icons.home_rounded, 'Home', selected: true),
          _navTile(Icons.shopping_cart_outlined, 'Cart', badge: '3'),
          _navTile(Icons.inventory_2_outlined, 'My Orders'),
          const SizedBox(height: 22),
          const Text(
            'ACCOUNT',
            style: TextStyle(
              color: Color(0xFF8E7F74),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _navTile(Icons.person_outline, 'Profile'),
          _navTile(Icons.settings_outlined, 'Settings'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF2A1B12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.shopping_bag_outlined, color: Color(0xFFB7E0A5)),
                SizedBox(width: 8),
                Text(
                  'Buyer mode',
                  style: TextStyle(
                    color: Color(0xFFB7E0A5),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navTile(IconData icon, String label,
      {bool selected = false, String? badge}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF446B44) : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: selected ? Colors.white : const Color(0xFFCBBEAF)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFFCBBEAF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE09A2C),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  final bool isDesktop;
  final VoidCallback onMenuTap;

  const HeaderSection({
    super.key,
    required this.isDesktop,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!isDesktop)
          IconButton(
            onPressed: onMenuTap,
            icon: const Icon(Icons.menu),
          ),
        const Expanded(
          child: Text(
            'Good morning, User 👋',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2A2A2A),
            ),
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE7A52D),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.notifications_none, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFE7A52D),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: const Text(
            'US',
            style: TextStyle(
              color: Color(0xFF2E241B),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A2B11), Color(0xFF274827)],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fresh harvest, fair prices',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Buy directly from local producers without separating browsing from shopping.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFE2E2E2),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Text('🌱', style: TextStyle(fontSize: 42)),
        ],
      ),
    );
  }
}

class SearchBarSection extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const SearchBarSection({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Color(0xFF8B8B8B)),
                hintText: 'Search fresh produce, proteins, grains...',
                hintStyle: TextStyle(color: Color(0xFF8B8B8B)),
                contentPadding: EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFE7ECE0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(Icons.tune, color: Color(0xFF456246)),
              SizedBox(width: 8),
              Text(
                'Filter',
                style: TextStyle(
                  color: Color(0xFF456246),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CategorySection extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategorySection({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.map((category) {
        final bool selected = category == selectedCategory;
        return InkWell(
          onTap: () => onCategorySelected(category),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE3EFE0) : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: selected
                    ? const Color(0xFF4A7A4D)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              category,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF4A7A4D)
                    : const Color(0xFF313131),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  Color _tagColor(String tag) {
    if (tag == '2 days') return const Color(0xFFE39B2D);
    return const Color(0xFF4A7A4D);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFE9EFE3),
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _tagColor(product.tag),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        product.tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      product.emoji,
                      style: const TextStyle(fontSize: 58),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF252525),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.producer,
                    style: const TextStyle(
                      color: Color(0xFF8D8D8D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: product.price,
                              style: const TextStyle(
                                color: Color(0xFF3D6A43),
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                              ),
                            ),
                            TextSpan(
                              text: ' ${product.unit}',
                              style: const TextStyle(
                                color: Color(0xFF8D8D8D),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E4F2F),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}