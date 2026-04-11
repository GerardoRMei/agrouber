import 'package:flutter/material.dart';

import '../models/address_draft.dart';

Future<AddressDraft?> showAddressFormSheet(
  BuildContext context, {
  required String title,
  required String submitLabel,
  required AddressDraft initial,
}) {
  return showModalBottomSheet<AddressDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _AddressFormSheet(
        title: title,
        submitLabel: submitLabel,
        initial: initial,
      );
    },
  );
}

class _AddressFormSheet extends StatefulWidget {
  final String title;
  final String submitLabel;
  final AddressDraft initial;

  const _AddressFormSheet({
    required this.title,
    required this.submitLabel,
    required this.initial,
  });

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _customAliasCtrl;
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _postalCodeCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _neighborhoodCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _extNumberCtrl;
  late final TextEditingController _intNumberCtrl;
  late final TextEditingController _referencesCtrl;

  final List<String> _aliasOptions = const <String>['Casa', 'Trabajo', 'Otro'];
  late String _selectedAlias;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    final alias = initial.normalizedAlias;
    _selectedAlias = _aliasOptions.contains(alias) ? alias : 'Otro';

    _customAliasCtrl = TextEditingController(
      text: _selectedAlias == 'Otro' ? alias : '',
    );
    _fullNameCtrl = TextEditingController(text: initial.fullName);
    _phoneCtrl = TextEditingController(text: initial.phone);
    _postalCodeCtrl = TextEditingController(text: initial.postalCode);
    _stateCtrl = TextEditingController(text: initial.state);
    _cityCtrl = TextEditingController(text: initial.city);
    _neighborhoodCtrl = TextEditingController(text: initial.neighborhood);
    _streetCtrl = TextEditingController(text: initial.street);
    _extNumberCtrl = TextEditingController(text: initial.extNumber);
    _intNumberCtrl = TextEditingController(text: initial.intNumber);
    _referencesCtrl = TextEditingController(text: initial.references);
  }

  @override
  void dispose() {
    _customAliasCtrl.dispose();
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _postalCodeCtrl.dispose();
    _stateCtrl.dispose();
    _cityCtrl.dispose();
    _neighborhoodCtrl.dispose();
    _streetCtrl.dispose();
    _extNumberCtrl.dispose();
    _intNumberCtrl.dispose();
    _referencesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final alias = _selectedAlias == 'Otro'
        ? _customAliasCtrl.text.trim()
        : _selectedAlias;

    final draft = AddressDraft(
      alias: alias,
      fullName: _fullNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      postalCode: _postalCodeCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      neighborhood: _neighborhoodCtrl.text.trim(),
      street: _streetCtrl.text.trim(),
      extNumber: _extNumberCtrl.text.trim(),
      intNumber: _intNumberCtrl.text.trim(),
      references: _referencesCtrl.text.trim(),
    );

    Navigator.of(context).pop(draft);
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio.';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    final base = _requiredValidator(value);
    if (base != null) return base;
    final regex = RegExp(r'^[0-9+\-\s()]{8,}$');
    if (!regex.hasMatch(value!.trim())) {
      return 'Telefono invalido.';
    }
    return null;
  }

  String? _postalCodeValidator(String? value) {
    final base = _requiredValidator(value);
    if (base != null) return base;
    final regex = RegExp(r'^[0-9]{4,6}$');
    if (!regex.hasMatch(value!.trim())) {
      return 'CP invalido.';
    }
    return null;
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: const Color(0xFFF9F7F3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 12, 12, bottom + 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F1209),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _aliasOptions.map((alias) {
                        final selected = _selectedAlias == alias;
                        return ChoiceChip(
                          label: Text(alias),
                          selected: selected,
                          selectedColor: const Color(0xFFE9EFE3),
                          onSelected: (_) {
                            setState(() => _selectedAlias = alias);
                          },
                        );
                      }).toList(),
                    ),
                    if (_selectedAlias == 'Otro') ...[
                      const SizedBox(height: 12),
                      _field(
                        label: 'Alias personalizado',
                        controller: _customAliasCtrl,
                        hint: 'Ej: Oficina',
                        validator: _requiredValidator,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _field(
                      label: 'Nombre de la Ubicación',
                      controller: _fullNameCtrl,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      label: 'Telefono',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      validator: _phoneValidator,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            label: 'Codigo postal',
                            controller: _postalCodeCtrl,
                            keyboardType: TextInputType.number,
                            validator: _postalCodeValidator,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            label: 'Estado',
                            controller: _stateCtrl,
                            validator: _requiredValidator,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            label: 'Ciudad',
                            controller: _cityCtrl,
                            validator: _requiredValidator,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            label: 'Colonia',
                            controller: _neighborhoodCtrl,
                            validator: _requiredValidator,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _field(
                            label: 'Calle',
                            controller: _streetCtrl,
                            validator: _requiredValidator,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            label: 'No. Ext',
                            controller: _extNumberCtrl,
                            validator: _requiredValidator,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            label: 'No. Int',
                            controller: _intNumberCtrl,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _field(
                      label: 'Referencias (opcional)',
                      controller: _referencesCtrl,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E4F2F),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.submitLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
