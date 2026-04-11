import 'package:agrouber/widgets/cart_panel.dart';
import 'package:flutter/material.dart';
import '../models/cart_state.dart';
import '../models/auth_session.dart';
import 'UserProfile.dart';
import '../models/profile_handling.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CartState cartState;
  final AuthSession session;
  final VoidCallback onLogout;

  const HomeAppBar({
    super.key,
    required this.cartState,
    required this.session,
    required this.onLogout,
  });

  void _openUserProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UserProfile(
        username: session.username.isNotEmpty
            ? session.username
            : session.email,
        email: session.email,
        onEditProfile: () {
          Navigator.pop(context);
          ProfileHandler.onEditProfile(context, session);
        },
        onChangePassword: () {
          Navigator.pop(context);
          ProfileHandler.onChangePassword(context, session);
        },
        onLogout: () {
          Navigator.pop(context);
          ProfileHandler.onLogout(context, onLogout);
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
          'AgroRun',
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
        // Le pasamos la sesión a _CartAction
        _CartAction(
          cartState: cartState, 
          session: session,
        ),
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
  final AuthSession session; // NUEVO: Añadimos la sesión aquí
  
  const _CartAction({
    required this.cartState,
    required this.session, // Requerimos la sesión en el constructor
  });

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
                builder: (context) => CartPanel(
                  cartState: cartState,
                  session: session, // Pasamos la sesión al CartPanel móvil
                ),
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