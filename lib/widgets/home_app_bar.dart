import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../shared/theme/agrorun_theme.dart';
import '../shared/widgets/agrorun_wordmark.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    this.cartCount = 0,
    this.onCartTap,
    this.onProfileTap,
    this.profileImageUrl,
  });

  final int cartCount;
  final VoidCallback? onCartTap;
  final VoidCallback? onProfileTap;
  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleSpacing: isMobile ? 12 : 24,
      title: Padding(
        padding: EdgeInsets.only(left: isMobile ? 0 : 24),
        child: const AgrorunWordmark(compact: true),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home_rounded, color: AgrorunPalette.forest),
          onPressed: () {},
        ),
        _CartAction(
          count: cartCount,
          onTap: onCartTap,
        ),
        Padding(
          padding: EdgeInsets.only(right: isMobile ? 8 : 24),
          child: IconButton(
            icon: profileImageUrl?.trim().isNotEmpty == true
                ? CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage(
                      ApiClient().resolveMediaUrl(profileImageUrl!),
                    ),
                  )
                : const Icon(
                    Icons.person_outline,
                    color: AgrorunPalette.forest,
                  ),
            onPressed: onProfileTap,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CartAction extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const _CartAction({
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        children: [
          const Icon(Icons.shopping_cart_outlined, color: AgrorunPalette.forest),
          if (count > 0)
            Positioned(
              right: 0,
              top: 0,
              child: CircleAvatar(
                radius: 8,
                backgroundColor: AgrorunPalette.orange,
                child: Text(
                  '$count',
                  style: const TextStyle(fontSize: 9, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      onPressed: onTap,
    );
  }
}
