import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../models/address_draft.dart';
import '../models/auth_session.dart';
import '../widgets/address_form_sheet.dart';

class EditProfilePage extends StatefulWidget {
  final AuthSession session;

  const EditProfilePage({
    super.key,
    required this.session,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();

  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isAddressLoading = false;
  bool _isAddressBusy = false;

  List<AddressBookEntry> _addressOptions = <AddressBookEntry>[];
  int? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController();
    _emailCtrl = TextEditingController(text: widget.session.email);
    _phoneCtrl = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final me = await _apiClient.getMyProfile(
        authToken: widget.session.jwt,
      );
      if (!mounted) return;

      _usernameCtrl.text = (me['username'] ?? '').toString();
      _emailCtrl.text = (me['email'] ?? widget.session.email).toString();
      _phoneCtrl.text = (me['phone'] ?? '').toString();

      if (widget.session.role == 'customer') {
        await _loadAddresses();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cargar el perfil: $e')),
      );

      _usernameCtrl.text =
          widget.session.displayName.replaceAll(' ', '').toLowerCase();
      _emailCtrl.text = widget.session.email;
      _phoneCtrl.text = '';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadAddresses({
    int? preferredId,
    String? preferredDocumentId,
    String? preferredLabel,
  }) async {
    if (mounted) {
      setState(() => _isAddressLoading = true);
    }

    try {
      final raw = await _apiClient.fetchMyAddresses(
        authToken: widget.session.jwt,
      );
      if (!mounted) return;

      final parsed = raw
          .map((item) {
            try {
              return AddressBookEntry.fromApi(item);
            } catch (_) {
              return null;
            }
          })
          .whereType<AddressBookEntry>()
          .toList();

      int? selected = preferredId ?? _selectedAddressId;
      if (selected == null && preferredDocumentId != null) {
        for (final item in parsed) {
          if (item.documentId == preferredDocumentId) {
            selected = item.id;
            break;
          }
        }
      }
      if (selected == null && preferredLabel != null) {
        for (final item in parsed) {
          if (item.rawLabel == preferredLabel) {
            selected = item.id;
            break;
          }
        }
      }

      if (!parsed.any((item) => item.id == selected)) {
        selected = parsed.isEmpty ? null : parsed.first.id;
      }

      setState(() {
        _addressOptions = parsed;
        _selectedAddressId = selected;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _addressOptions = <AddressBookEntry>[];
        _selectedAddressId = null;
      });
    } finally {
      if (mounted) {
        setState(() => _isAddressLoading = false);
      }
    }
  }

  AddressBookEntry? get _selectedAddress {
    for (final item in _addressOptions) {
      if (item.id == _selectedAddressId) {
        return item;
      }
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await _apiClient.updateMyBasicProfile(
        authToken: widget.session.jwt,
        userId: widget.session.userId,
        username: _usernameCtrl.text,
        email: _emailCtrl.text,
        phone: _phoneCtrl.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente.')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar el perfil: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _openAddAddressForm() async {
    final draft = await showAddressFormSheet(
      context,
      title: 'Agregar direccion',
      submitLabel: 'Guardar direccion',
      initial: AddressDraft.empty(),
    );
    if (draft == null || !draft.hasRequiredFields) return;

    await _withAddressAction(
      successMessage: 'Direccion guardada.',
      action: () async {
        final createdDocumentId = await _apiClient.createMyAddress(
          authToken: widget.session.jwt,
          userId: widget.session.userId,
          draft: draft,
        );
        await _loadAddresses(preferredDocumentId: createdDocumentId);
      },
    );
  }

  Future<void> _openEditAddressForm() async {
    final current = _selectedAddress;
    if (current == null) return;

    final initial = current.draft ?? AddressDraft.fromLegacyLabel(current.rawLabel);
    final draft = await showAddressFormSheet(
      context,
      title: 'Editar direccion',
      submitLabel: 'Guardar cambios',
      initial: initial,
    );
    if (draft == null || !draft.hasRequiredFields) return;

    await _withAddressAction(
      successMessage: 'Direccion actualizada.',
      action: () async {
        await _apiClient.updateMyAddress(
          authToken: widget.session.jwt,
          userId: widget.session.userId,
          addressId: current.id,
          addressDocumentId: current.documentId,
          draft: draft,
        );
        await _loadAddresses(preferredId: current.id);
      },
    );
  }

  Future<void> _confirmDeleteAddress() async {
    final current = _selectedAddress;
    if (current == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar direccion'),
        content: const Text('Esta accion quitara la direccion seleccionada.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _withAddressAction(
      successMessage: 'Direccion eliminada.',
      action: () async {
        await _apiClient.deleteMyAddress(
          authToken: widget.session.jwt,
          userId: widget.session.userId,
          addressId: current.id,
          addressDocumentId: current.documentId,
        );
        await _loadAddresses();
      },
    );
  }

  Future<void> _withAddressAction({
    required String successMessage,
    required Future<void> Function() action,
  }) async {
    if (_isAddressBusy) return;
    setState(() => _isAddressBusy = true);

    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo completar la accion: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isAddressBusy = false);
      }
    }
  }

  Widget _buildAddressAliasTag(String alias) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EFE3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        alias,
        style: const TextStyle(
          color: Color(0xFF2E4F2F),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAddressCard(AddressBookEntry address) {
    final selected = _selectedAddressId == address.id;
    return InkWell(
      onTap: _isAddressBusy
          ? null
          : () => setState(() => _selectedAddressId = address.id),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE9EFE3) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF2E4F2F) : const Color(0xFFE0D8CD),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<int>(
              value: address.id,
              groupValue: _selectedAddressId,
              activeColor: const Color(0xFF2E4F2F),
              onChanged: _isAddressBusy
                  ? null
                  : (value) => setState(() => _selectedAddressId = value),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildAddressAliasTag(address.alias),
                      if (selected) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Color(0xFF2E4F2F),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    address.primaryLine,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F1209),
                    ),
                  ),
                  if (address.secondaryLine != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      address.secondaryLine!,
                      style: const TextStyle(color: Color(0xFF6E6259)),
                    ),
                  ],
                  if (address.contactLine != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      address.contactLine!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6E6259),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressManagerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0D8CD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Direcciones de entrega',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _isAddressBusy ? null : _openAddAddressForm,
                icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                label: const Text('Agregar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isAddressLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          if (!_isAddressLoading && _addressOptions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5EF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'No hay direcciones guardadas.',
                style: TextStyle(color: Color(0xFF6E6259)),
              ),
            ),
          if (!_isAddressLoading && _addressOptions.isNotEmpty) ...[
            ..._addressOptions.map(_buildAddressCard),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isAddressBusy || _selectedAddress == null
                        ? null
                        : _openEditAddressForm,
                    icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
                    label: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isAddressBusy || _selectedAddress == null
                        ? null
                        : _confirmDeleteAddress,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Eliminar'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F1EA),
        elevation: 0,
        title: const Text(
          'Editar perfil',
          style: TextStyle(
            color: Color(0xFF1F1209),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F1209)),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Card(
                      color: const Color(0xFFF3F0EA),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Informacion del usuario',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F1209),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Edita username, correo y telefono.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6E6259),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Center(
                                child: CircleAvatar(
                                  radius: 46,
                                  backgroundColor: Color(0xFFD8D2C8),
                                  child: Icon(
                                    Icons.person,
                                    size: 46,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _ProfileField(
                                label: 'Username',
                                controller: _usernameCtrl,
                                hint: 'gerardozepeda',
                                validator: _requiredValidator,
                              ),
                              const SizedBox(height: 16),
                              _ProfileField(
                                label: 'Correo electronico',
                                controller: _emailCtrl,
                                hint: 'correo@ejemplo.com',
                                keyboardType: TextInputType.emailAddress,
                                validator: _emailValidator,
                              ),
                              const SizedBox(height: 16),
                              _ProfileField(
                                label: 'Telefono',
                                controller: _phoneCtrl,
                                hint: '+52 449 000 0000',
                                keyboardType: TextInputType.phone,
                                validator: _phoneValidator,
                              ),
                              if (widget.session.role == 'customer') ...[
                                const SizedBox(height: 24),
                                _buildAddressManagerSection(),
                              ],
                              const SizedBox(height: 28),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _isSaving
                                          ? null
                                          : () => Navigator.pop(context),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF1F1209),
                                        side: const BorderSide(
                                          color: Color(0xFFB9B0A7),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
                                      child: const Text('Cancelar'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _isSaving ? null : _saveProfile,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFE09A2C),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
                                      child: Text(
                                        _isSaving
                                            ? 'Guardando...'
                                            : 'Guardar cambios',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    final email = value.trim();
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!regex.hasMatch(email)) {
      return 'Ingresa un correo valido';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final phone = value.trim();
    final regex = RegExp(r'^[0-9+\-\s()]+$');
    if (!regex.hasMatch(phone)) {
      return 'Ingresa un telefono valido';
    }
    return null;
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _ProfileField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: Color(0xFF1F1209),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDDD4C7)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDDD4C7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE09A2C),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
