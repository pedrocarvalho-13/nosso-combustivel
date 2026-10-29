enum Combustivel {
  gasolina('Gasolina'),
  etanol('Etanol'),
  dieselS10('Diesel S10'),
  dieselS500('Diesel S500'),
  gnv('GNV');

  const Combustivel(this.rotulo);

  final String rotulo;

  bool get diesel => this == dieselS10 || this == dieselS500;
}
