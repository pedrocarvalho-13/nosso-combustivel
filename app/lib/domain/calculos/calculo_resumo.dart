import 'dart:math';

import '../registro_energia.dart';

class ResumoPeriodo {
  const ResumoPeriodo({required this.gastoCentavos, required this.kmRodados});

  final int gastoCentavos;
  final int kmRodados;

  double? get custoPorKm => kmRodados > 0 ? gastoCentavos / 100 / kmRodados : null;
}

abstract final class CalculoResumo {
  static const diasMinimosParaProjecao = 7;
  static const janelaProjecaoDias = 30;

  static DateTime inicioDaSemana(DateTime agora) {
    final hoje = DateTime(agora.year, agora.month, agora.day);
    return hoje.subtract(Duration(days: agora.weekday - DateTime.monday));
  }

  static DateTime inicioDoMes(DateTime agora) => DateTime(agora.year, agora.month);

  static int diasNoMes(DateTime agora) => DateTime(agora.year, agora.month + 1, 0).day;

  static ResumoPeriodo doPeriodo({
    required List<RegistroEnergia> registros,
    required int odometroInicial,
    required DateTime inicio,
    required DateTime fim,
  }) {
    final noPeriodo = registros.where((r) => !r.data.isBefore(inicio) && r.data.isBefore(fim)).toList();
    if (noPeriodo.isEmpty) return const ResumoPeriodo(gastoCentavos: 0, kmRodados: 0);

    final gasto = noPeriodo.fold<int>(0, (soma, r) => soma + r.valorCentavos);
    final anteriores = registros.where((r) => r.data.isBefore(inicio)).map((r) => r.odometro);
    final base = anteriores.isEmpty ? odometroInicial : anteriores.reduce(max);
    final maior = noPeriodo.map((r) => r.odometro).reduce(max);
    return ResumoPeriodo(gastoCentavos: gasto, kmRodados: max(0, maior - base));
  }

  static int? projecaoDoMes({required List<RegistroEnergia> registros, required DateTime agora}) {
    if (registros.isEmpty) return null;
    final primeiro = registros.map((r) => r.data).reduce((a, b) => a.isBefore(b) ? a : b);
    final diasDeHistorico = agora.difference(primeiro).inDays;
    if (diasDeHistorico < diasMinimosParaProjecao) return null;

    final dias = min(diasDeHistorico, janelaProjecaoDias);
    final inicioJanela = agora.subtract(Duration(days: dias));
    final gastoJanela = registros
        .where((r) => r.data.isAfter(inicioJanela) && !r.data.isAfter(agora))
        .fold<int>(0, (soma, r) => soma + r.valorCentavos);
    final mediaDiaria = gastoJanela / dias;

    final inicioMes = inicioDoMes(agora);
    final gastoMes = registros
        .where((r) => !r.data.isBefore(inicioMes) && !r.data.isAfter(agora))
        .fold<int>(0, (soma, r) => soma + r.valorCentavos);
    final diasRestantes = diasNoMes(agora) - agora.day;
    return gastoMes + (mediaDiaria * diasRestantes).round();
  }
}
