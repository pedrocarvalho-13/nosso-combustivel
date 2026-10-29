class ComparacaoEtanol {
  const ComparacaoEtanol({
    required this.razaoPreco,
    required this.limite,
    required this.limiteDoCarro,
  });

  final double razaoPreco;
  final double limite;
  final bool limiteDoCarro;

  bool get etanolCompensa => razaoPreco <= limite;
}

abstract final class CalculoEtanol {
  static const limitePadrao = 0.70;

  static ComparacaoEtanol? comparar({
    required double precoEtanol,
    required double precoGasolina,
    double? kmlEtanol,
    double? kmlGasolina,
  }) {
    if (precoEtanol <= 0 || precoGasolina <= 0) return null;
    final temHistorico = kmlEtanol != null && kmlGasolina != null && kmlEtanol > 0 && kmlGasolina > 0;
    return ComparacaoEtanol(
      razaoPreco: precoEtanol / precoGasolina,
      limite: temHistorico ? kmlEtanol / kmlGasolina : limitePadrao,
      limiteDoCarro: temHistorico,
    );
  }
}
