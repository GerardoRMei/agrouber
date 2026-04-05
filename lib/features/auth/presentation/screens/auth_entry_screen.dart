import 'package:flutter/material.dart';

import '../../../../models/auth_session.dart';
import '../../../../shared/widgets/agrorun_wordmark.dart';
import '../../../seller/controllers/seller_flow_controller.dart';
import '../../../seller/presentation/screens/become_seller_screen.dart';
import '../../../seller/presentation/screens/seller_status_screen.dart';
import '../../services/auth_api_service.dart';

class AuthEntryScreen extends StatefulWidget {
  const AuthEntryScreen({
    super.key,
    required this.onLoginSuccess,
  });

  final ValueChanged<AuthSession> onLoginSuccess;

  @override
  State<AuthEntryScreen> createState() => _AuthEntryScreenState();
}

class _AuthEntryScreenState extends State<AuthEntryScreen> {
  final AuthApiService _authApiService = AuthApiService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int _selectedSegment = 0;
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final identifier = _emailController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Escribe tu correo y tu contrasena.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final session = await _authApiService.login(
        identifier: identifier,
        password: password,
      );

      if (!mounted) {
        return;
      }

      widget.onLoginSuccess(session);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _openSellerFlow() {
    final controller = SellerFlowController();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BecomeSellerScreen(
          controller: controller,
          onOpenStatusFromLogin: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SellerStatusScreen(
                  controller: controller,
                  title: 'Estado de tu solicitud',
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 480;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                elevation: 0,
                color: const Color(0xFFFFFCF7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: const BorderSide(color: Color(0xFFE6DDD1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      if (isMobile)
                        _buildSegmentedTabsMobile()
                      else
                        _buildSegmentedControl(),
                      const SizedBox(height: 24),
                      if (_selectedSegment == 0)
                        _buildLoginPane()
                      else
                        _buildSellerPane(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        AgrorunWordmark(showTagline: true),
        SizedBox(height: 12),
        Text(
          'Inicia sesion en tu cuenta o comienza tu registro para vender dentro de la plataforma.',
          style: TextStyle(
            height: 1.5,
            color: Color(0xFF5E685B),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedControl() {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment<int>(
          value: 0,
          label: Text('Iniciar sesion'),
          icon: Icon(Icons.login_rounded),
        ),
        ButtonSegment<int>(
          value: 1,
          label: Text('Quiero vender'),
          icon: Icon(Icons.storefront_outlined),
        ),
      ],
      selected: <int>{_selectedSegment},
      onSelectionChanged: (selection) {
        setState(() {
          _selectedSegment = selection.first;
          _errorMessage = null;
        });
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? const Color(0xFF284826)
              : const Color(0xFFF5EFE5);
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? Colors.white
              : const Color(0xFF3E4038);
        }),
      ),
    );
  }

  Widget _buildSegmentedTabsMobile() {
    return Row(
      children: [
        Expanded(
          child: _MobileTabButton(
            label: 'Iniciar sesion',
            icon: Icons.login_rounded,
            selected: _selectedSegment == 0,
            onTap: () {
              setState(() {
                _selectedSegment = 0;
                _errorMessage = null;
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MobileTabButton(
            label: 'Quiero vender',
            icon: Icons.storefront_outlined,
            selected: _selectedSegment == 1,
            onTap: () {
              setState(() {
                _selectedSegment = 1;
                _errorMessage = null;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoginPane() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accede a tu cuenta para revisar el mercado y consultar el estado de tu registro como vendedor.',
          style: TextStyle(height: 1.5),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(
            label: 'Correo o username',
            icon: Icons.mail_outline,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: _inputDecoration(
            label: 'Contrasena',
            icon: Icons.lock_outline,
            suffix: IconButton(
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
          onSubmitted: (_) => _login(),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isSubmitting ? null : _login,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF284826),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Text('Entrar'),
          ),
        ),
      ],
    );
  }

  Widget _buildSellerPane() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8F2),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD7E6D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Chip(
            label: Text('Registro de vendedor'),
            avatar: Icon(Icons.eco_outlined, size: 18),
          ),
          const SizedBox(height: 16),
          const Text(
            'Comienza tu registro como vendedor',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F3A24),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Completa una solicitud breve con los datos del responsable, el nombre de tu tienda y tu telefono de contacto.',
            style: TextStyle(height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openSellerFlow,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF284826),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Comenzar solicitud'),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF5EFE5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _MobileTabButton extends StatelessWidget {
  const _MobileTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF284826) : const Color(0xFFF5EFE5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFF284826) : const Color(0xFFD8D0C4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : const Color(0xFF3E4038),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF3E4038),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
