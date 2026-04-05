class AppValidators {
  static String? requiredField(String? value, {required String label}) {
    if (value == null || value.trim().isEmpty) {
      return '$label es requerido';
    }
    return null;
  }

  static String? email(String? value) {
    final required = requiredField(value, label: 'El email');
    if (required != null) {
      return required;
    }

    final pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!pattern.hasMatch(value!.trim())) {
      return 'Ingresa un email valido';
    }

    return null;
  }

  static String? minLength(
    String? value, {
    required String label,
    required int min,
  }) {
    final required = requiredField(value, label: label);
    if (required != null) {
      return required;
    }

    if (value!.trim().length < min) {
      return '$label debe tener al menos $min caracteres';
    }

    return null;
  }
}
