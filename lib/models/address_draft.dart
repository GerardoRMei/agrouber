class AddressDraft {
  final String alias;
  final String fullName;
  final String phone;
  final String postalCode;
  final String state;
  final String city;
  final String neighborhood;
  final String street;
  final String extNumber;
  final String intNumber;
  final String references;

  const AddressDraft({
    required this.alias,
    required this.fullName,
    required this.phone,
    required this.postalCode,
    required this.state,
    required this.city,
    required this.neighborhood,
    required this.street,
    required this.extNumber,
    required this.intNumber,
    required this.references,
  });

  factory AddressDraft.empty() {
    return const AddressDraft(
      alias: 'Casa',
      fullName: '',
      phone: '',
      postalCode: '',
      state: '',
      city: '',
      neighborhood: '',
      street: '',
      extNumber: '',
      intNumber: '',
      references: '',
    );
  }

  factory AddressDraft.fromLegacyLabel(String label) {
    return AddressDraft.empty().copyWith(street: label.trim());
  }

  AddressDraft copyWith({
    String? alias,
    String? fullName,
    String? phone,
    String? postalCode,
    String? state,
    String? city,
    String? neighborhood,
    String? street,
    String? extNumber,
    String? intNumber,
    String? references,
  }) {
    return AddressDraft(
      alias: alias ?? this.alias,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      postalCode: postalCode ?? this.postalCode,
      state: state ?? this.state,
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      street: street ?? this.street,
      extNumber: extNumber ?? this.extNumber,
      intNumber: intNumber ?? this.intNumber,
      references: references ?? this.references,
    );
  }

  bool get hasRequiredFields =>
      fullName.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      postalCode.trim().isNotEmpty &&
      state.trim().isNotEmpty &&
      city.trim().isNotEmpty &&
      neighborhood.trim().isNotEmpty &&
      street.trim().isNotEmpty &&
      extNumber.trim().isNotEmpty;

  String get normalizedAlias {
    final value = alias.trim();
    return value.isEmpty ? 'Casa' : value;
  }
}

class AddressBookEntry {
  final int id;
  final String? documentId;
  final String rawLabel;
  final AddressDraft? draft;

  const AddressBookEntry({
    required this.id,
    this.documentId,
    required this.rawLabel,
    required this.draft,
  });

  factory AddressBookEntry.fromApi(Map<String, dynamic> raw) {
    final dynamicId = raw['id'];
    final parsedId = dynamicId is int
        ? dynamicId
        : int.tryParse(dynamicId?.toString() ?? '');
    if (parsedId == null) {
      throw ArgumentError('Address id invalido: $dynamicId');
    }

    final displayLabel =
        (raw['displayLabel'] ?? raw['label'] ?? '').toString().trim();
    final label = (raw['label'] ?? '').toString().trim();
    final documentIdValue = raw['documentId']?.toString().trim();
    final normalizedDocumentId = (documentIdValue == null || documentIdValue.isEmpty)
        ? null
        : documentIdValue;

    final structuredDraft = _buildDraftFromStructured(raw, label: label);
    return AddressBookEntry(
      id: parsedId,
      documentId: normalizedDocumentId,
      rawLabel: displayLabel.isEmpty ? label : displayLabel,
      draft: structuredDraft ?? tryParseSerializedAddress(label),
    );
  }

  String get alias => draft?.normalizedAlias ?? 'Direccion';

  String get primaryLine {
    if (draft == null) {
      return rawLabel;
    }
    final base = '${draft!.street.trim()} ${draft!.extNumber.trim()}'.trim();
    if (draft!.intNumber.trim().isEmpty) {
      return base;
    }
    return '$base, Int ${draft!.intNumber.trim()}';
  }

  String? get secondaryLine {
    if (draft == null) return null;
    final pieces = <String>[
      draft!.neighborhood.trim(),
      draft!.city.trim(),
      draft!.state.trim(),
      if (draft!.postalCode.trim().isNotEmpty) 'CP ${draft!.postalCode.trim()}',
    ].where((value) => value.isNotEmpty).toList();
    if (pieces.isEmpty) return null;
    return pieces.join(', ');
  }

  String? get contactLine {
    if (draft == null) return null;
    final pieces = <String>[
      draft!.fullName.trim(),
      draft!.phone.trim(),
    ].where((value) => value.isNotEmpty).toList();
    if (pieces.isEmpty) return null;
    return pieces.join(' · ');
  }
}

AddressDraft? _buildDraftFromStructured(
  Map<String, dynamic> raw, {
  required String label,
}) {
  final fullName = (raw['recipientName'] ?? '').toString().trim();
  final phone = (raw['phone'] ?? '').toString().trim();
  final street = (raw['street'] ?? raw['addressLine1'] ?? '').toString().trim();
  final extNumber = (raw['externalNumber'] ?? '').toString().trim();
  final intNumber = (raw['internalNumber'] ?? '').toString().trim();
  final neighborhood = (raw['neighborhood'] ?? '').toString().trim();
  final city = (raw['city'] ?? '').toString().trim();
  final state = (raw['state'] ?? '').toString().trim();
  final zipCode = (raw['zipCode'] ?? raw['postalCode'] ?? '').toString().trim();
  final references = (raw['references'] ?? '').toString().trim();

  final hasStructuredData = <String>[
    fullName,
    phone,
    street,
    extNumber,
    neighborhood,
    city,
    state,
    zipCode,
    references,
  ].any((value) => value.isNotEmpty);

  if (!hasStructuredData) {
    return null;
  }

  return AddressDraft(
    alias: label.isEmpty ? 'Casa' : label,
    fullName: fullName,
    phone: phone,
    postalCode: zipCode,
    state: state,
    city: city,
    neighborhood: neighborhood,
    street: street,
    extNumber: extNumber,
    intNumber: intNumber,
    references: references,
  );
}

const String _kAddressPrefix = 'AGROADDR';

String serializeAddressDraft(AddressDraft draft) {
  final fields = <String, String>{
    'alias': draft.normalizedAlias,
    'name': draft.fullName.trim(),
    'phone': draft.phone.trim(),
    'zip': draft.postalCode.trim(),
    'state': draft.state.trim(),
    'city': draft.city.trim(),
    'neighborhood': draft.neighborhood.trim(),
    'street': draft.street.trim(),
    'ext': draft.extNumber.trim(),
    'int': draft.intNumber.trim(),
    'ref': draft.references.trim(),
  };

  final tokens = <String>[_kAddressPrefix];
  fields.forEach((key, value) {
    tokens.add('$key=${Uri.encodeComponent(value)}');
  });
  return tokens.join('|');
}

AddressDraft? tryParseSerializedAddress(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return null;

  final tokens = value.split('|');
  if (tokens.isEmpty || tokens.first != _kAddressPrefix) {
    return null;
  }

  final parsed = <String, String>{};
  for (final token in tokens.skip(1)) {
    final separator = token.indexOf('=');
    if (separator <= 0) continue;
    final key = token.substring(0, separator).trim();
    final encoded = token.substring(separator + 1);
    parsed[key] = Uri.decodeComponent(encoded);
  }

  return AddressDraft(
    alias: parsed['alias'] ?? 'Casa',
    fullName: parsed['name'] ?? '',
    phone: parsed['phone'] ?? '',
    postalCode: parsed['zip'] ?? '',
    state: parsed['state'] ?? '',
    city: parsed['city'] ?? '',
    neighborhood: parsed['neighborhood'] ?? '',
    street: parsed['street'] ?? '',
    extNumber: parsed['ext'] ?? '',
    intNumber: parsed['int'] ?? '',
    references: parsed['ref'] ?? '',
  );
}
