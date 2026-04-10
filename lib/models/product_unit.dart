enum ProductUnit {
  kg('Kg', '/kg'),
  pieza('Pieza', '/pza'),
  caja('Caja', '/caja');

  final String displayName;
  final String suffix;

  const ProductUnit(this.displayName, this.suffix);

  static ProductUnit fromString(String value) {
    switch (value.toLowerCase()) {
      case 'kg':
        return ProductUnit.kg;
      case 'pieza':
        return ProductUnit.pieza;
      case 'caja':
        return ProductUnit.caja;
      default:
        return ProductUnit.pieza;
    }
  }
}