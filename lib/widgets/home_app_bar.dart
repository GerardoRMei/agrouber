import 'package:agrouber/widgets/cart_panel.dart';
import 'package:flutter/material.dart';
import '../models/cart_state.dart';
import '../models/auth_session.dart';
import 'UserProfile.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CartState cartState;
  final AuthSession session;
  final VoidCallback? onEditProfile;
  final VoidCallback? onChangePassword;
  final VoidCallback onLogout;


  const HomeAppBar({super.key, required this.cartState, required this.session, 
                  required this.onEditProfile, this.onChangePassword, required this.onLogout});


  void _openUserProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UserProfile(
        firstName: session.displayName.isNotEmpty
            ? session.displayName
            : session.email,
        email: session.email,
        onEditProfile: () {
          Navigator.pop(context);
          onEditProfile?.call();
        },
        onChangePassword: () {
          Navigator.pop(context);
          onChangePassword?.call();
        },
        onLogout: () {
          Navigator.pop(context);
          onLogout();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    
    final double hPadding = isMobile ? 20.0 : 64.0;

    return AppBar(
      backgroundColor: const Color(0xFF1F1209),
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.only(left: hPadding),
        child: const Text(
          'Agrouber',
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.w800, 
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home_rounded, color: Colors.white),
          onPressed: () {},
        ),
        _CartAction(cartState: cartState),
        Padding(
          padding: EdgeInsets.only(right: hPadding),
          child: IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {_openUserProfile(context);},
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CartAction extends StatelessWidget {
  final CartState cartState;
  
  const _CartAction({required this.cartState});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (scaffoldContext) {
        return IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              Positioned(
                right: -4,
                top: -4,
                child: ListenableBuilder(
                  listenable: cartState,
                  builder: (context, child) {
                    if (cartState.totalItems == 0) return const SizedBox.shrink();
                    
                    return CircleAvatar(
                      radius: 8,
                      backgroundColor: const Color(0xFFE09A2C),
                      child: Text(
                        '${cartState.totalItems}',
                        style: const TextStyle(
                          fontSize: 10, 
                          color: Colors.white, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
          onPressed: () {
            final bool isMobile = MediaQuery.of(scaffoldContext).size.width < 600;

            if (isMobile) {
              showModalBottomSheet(
                context: scaffoldContext,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => CartPanel(cartState: cartState),
              );
            } else {
              Scaffold.of(scaffoldContext).openEndDrawer();
            }
          },
        );
      }
    );
  }
}