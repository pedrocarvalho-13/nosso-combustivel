import '../registro_energia.dart';

class GastoMensal {
  const GastoMensal({required this.mes, this.combustivelCentavos = 0, this.eletricoCentavos = 0});

  final DateTime mes;
  final int combustivelCentavos;
  final int eletricoCentavos;

  int get totalCentavos => combustivelCentavos + eletricoCentavos;
}

abstract final class CalculoRelatorio {
  static List<GastoMensal> gastoPorMes(List<RegistroEnergia> registros, DateTime agora, {int meses = 12}) {
    final inicios = [for (var i = meses - 1; i >= 0; i--) DateTime(agora.year, agora.month - i)];
    return [
      for (final inicio in inicios)
        () {
          final fim = DateTime(inicio.year, inicio.month + 1);
          final doMes = registros.where((r) => !r.data.isBefore(inicio) && r.data.isBefore(fim));
          return GastoMensal(
            mes: inicio,
            combustivelCentavos: doMes.whereType<Abastecimento>().fold(0, (soma, r) => soma + r.valorCentavos),
            eletricoCentavos: doMes.whereType<Recarga>().fold(0, (soma, r) => soma + r.valorCentavos),
          );
        }(),
    ];
  }

  static int? mediaMensal(List<GastoMensal> meses) {
    final primeiroComGasto = meses.indexWhere((m) => m.totalCentavos > 0);
    if (primeiroComGasto < 0) return null;
    final considerados = meses.sublist(primeiroComGasto);
    return (considerados.fold<int>(0, (soma, m) => soma + m.totalCentavos) / considerados.length).round();
  }
}
