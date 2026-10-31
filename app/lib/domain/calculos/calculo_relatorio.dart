import '../cartao.dart';
import '../registro_energia.dart';
import 'calculo_fatura.dart';

class GastoMensal {
  const GastoMensal({required this.mes, this.combustivelCentavos = 0, this.eletricoCentavos = 0});

  final DateTime mes;
  final int combustivelCentavos;
  final int eletricoCentavos;

  int get totalCentavos => combustivelCentavos + eletricoCentavos;
}

abstract final class CalculoRelatorio {
  static List<GastoMensal> gastoPorMes(
    List<RegistroEnergia> registros,
    DateTime agora, {
    int meses = 12,
    Map<String, Cartao> cartoes = const {},
  }) {
    final inicios = [for (var i = meses - 1; i >= 0; i--) DateTime(agora.year, agora.month - i)];
    return [
      for (final inicio in inicios)
        () {
          final doMes = registros.where((r) => CalculoFatura.mesDoGasto(r, cartoes) == inicio);
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
