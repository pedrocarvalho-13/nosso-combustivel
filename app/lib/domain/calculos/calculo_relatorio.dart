import '../cartao.dart';
import '../registro_energia.dart';
import 'calculo_fatura.dart';

class GastoMensal {
  const GastoMensal({
    required this.mes,
    this.combustivelCentavos = 0,
    this.eletricoCentavos = 0,
    this.futuro = false,
  });

  final DateTime mes;
  final int combustivelCentavos;
  final int eletricoCentavos;
  final bool futuro;

  int get totalCentavos => combustivelCentavos + eletricoCentavos;
}

abstract final class CalculoRelatorio {
  static List<GastoMensal> gastoPorMes(
    List<RegistroEnergia> registros,
    DateTime agora, {
    int meses = 12,
    Map<String, Cartao> cartoes = const {},
  }) {
    GastoMensal doMes(DateTime inicio, {bool futuro = false}) {
      final registrosDoMes = registros.where((r) => CalculoFatura.mesDoGasto(r, cartoes) == inicio);
      return GastoMensal(
        mes: inicio,
        futuro: futuro,
        combustivelCentavos: registrosDoMes.whereType<Abastecimento>().fold(0, (soma, r) => soma + r.valorCentavos),
        eletricoCentavos: registrosDoMes.whereType<Recarga>().fold(0, (soma, r) => soma + r.valorCentavos),
      );
    }

    final seguinte = doMes(DateTime(agora.year, agora.month + 1), futuro: true);
    return [
      for (var i = meses - 1; i >= 0; i--) doMes(DateTime(agora.year, agora.month - i)),
      if (seguinte.totalCentavos > 0) seguinte,
    ];
  }

  static int totalFechado(List<GastoMensal> meses) =>
      meses.where((m) => !m.futuro).fold(0, (soma, m) => soma + m.totalCentavos);

  static int? mediaMensal(List<GastoMensal> meses) {
    final passados = meses.where((m) => !m.futuro).toList();
    final primeiroComGasto = passados.indexWhere((m) => m.totalCentavos > 0);
    if (primeiroComGasto < 0) return null;
    final considerados = passados.sublist(primeiroComGasto);
    return (considerados.fold<int>(0, (soma, m) => soma + m.totalCentavos) / considerados.length).round();
  }
}
