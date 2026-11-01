import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formato.dart';
import '../../data/provedores.dart';
import '../../domain/calculos/calculo_consumo.dart';
import '../../domain/calculos/calculo_fatura.dart';
import '../../domain/calculos/calculo_resumo.dart';
import '../../domain/cartao.dart';
import '../../domain/registro_energia.dart';
import '../../domain/veiculo.dart';
import '../../domain/servico.dart';

class ConsumoInicio {
  const ConsumoInicio({
    required this.titulo,
    required this.unidade,
    required this.dias,
    required this.mediaMes,
    required this.ultimo,
    required this.ultimos,
  });

  final String titulo;
  final String unidade;
  final int dias;
  final ({int km, double quantidade, double media})? mediaMes;
  final CicloConsumo? ultimo;
  final List<CicloConsumo> ultimos;

  double? get variacaoDoUltimo {
    final media = mediaMes?.media;
    final ultimo = this.ultimo;
    if (media == null || ultimo == null) return null;
    return ultimo.rendimento / media - 1;
  }
}

enum TipoMes { passado, atual, seguinte }

class MesGasto {
  const MesGasto({
    required this.mes,
    required this.tipo,
    required this.totalCentavos,
    required this.kmRodados,
    this.registrosNoCredito = 0,
  });

  final DateTime mes;
  final TipoMes tipo;
  final int totalCentavos;
  final int kmRodados;
  final int registrosNoCredito;

  double? get custoPorKm => kmRodados == 0 ? null : totalCentavos / 100 / kmRodados;

  int get mediaSemanalCentavos {
    final dias = DateTime(mes.year, mes.month + 1, 0).day;
    return (totalCentavos / dias * 7).round();
  }
}

class RegistroLinhaDoTempo {
  const RegistroLinhaDoTempo({required this.registro, required this.consumo, required this.unidade, required this.abaixo});

  final RegistroEnergia registro;
  final double? consumo;
  final String unidade;
  final bool abaixo;
}

class InicioEstado {
  const InicioEstado({
    required this.veiculo,
    required this.nomeMes,
    required this.gastoMesCentavos,
    required this.kmRodadosMes,
    required this.projecaoCentavos,
    required this.metaCentavos,
    required this.semanaCentavos,
    required this.custoPorKm,
    required this.consumos,
    required this.ultimos,
    required this.meses,
    this.manutencaoMesCentavos = 0,
  });

  final Veiculo veiculo;
  final String nomeMes;
  final int gastoMesCentavos;
  final int kmRodadosMes;
  final int? projecaoCentavos;
  final int? metaCentavos;
  final int semanaCentavos;
  final double? custoPorKm;
  final List<ConsumoInicio> consumos;
  final List<RegistroLinhaDoTempo> ultimos;
  final List<MesGasto> meses;
  final int manutencaoMesCentavos;

  int get indiceDoMesAtual => meses.indexWhere((m) => m.tipo == TipoMes.atual);
}

const quedaParaDestacar = 0.15;

final inicioViewModelProvider = Provider<AsyncValue<InicioEstado?>>((ref) {
  final registros = ref.watch(registrosDoAtivoProvider).value ?? const <RegistroEnergia>[];
  final cartoes = {for (final c in ref.watch(cartoesProvider).value ?? const <Cartao>[]) c.id: c};
  final manutencoes = ref.watch(manutencoesDoAtivoProvider).value ?? const <Servico>[];
  final agora = ref.watch(relogioProvider)();
  final dias = ref.watch(periodoMediaProvider).value ?? 30;
  final meta = ref.watch(metaMensalProvider).value;

  return ref.watch(veiculoAtivoProvider).whenData((veiculo) {
    if (veiculo == null) return null;

    final mesPorData = CalculoResumo.doPeriodo(
      registros: registros,
      odometroInicial: veiculo.odometroInicial,
      inicio: CalculoResumo.inicioDoMes(agora),
      fim: DateTime(agora.year, agora.month + 1),
    );
    final semana = CalculoResumo.doPeriodo(
      registros: registros,
      odometroInicial: veiculo.odometroInicial,
      inicio: CalculoResumo.inicioDaSemana(agora),
      fim: agora.add(const Duration(days: 1)),
    );
    final gastos = <GastoComPagamento>[...registros, ...manutencoes];
    final gastoMes = CalculoFatura.gastoDoMes(gastos, cartoes, agora);
    final manutencaoMes = CalculoFatura.gastoDoMes(manutencoes, cartoes, agora);
    final projecaoPorData = CalculoResumo.projecaoDoMes(registros: registros, agora: agora);

    final ciclosCombustivel = CalculoConsumo.ciclosDeAbastecimento(registros.whereType<Abastecimento>());
    final ciclosEletricos = CalculoConsumo.ciclosDeRecarga(registros.whereType<Recarga>());
    final consumos = _consumos(veiculo, registros, ciclosCombustivel, ciclosEletricos, agora, dias);
    final ciclosPorRegistro = {for (final c in [...ciclosCombustivel, ...ciclosEletricos]) c.registroId: c};

    return InicioEstado(
      veiculo: veiculo,
      nomeMes: Formato.mes(agora),
      gastoMesCentavos: gastoMes,
      kmRodadosMes: mesPorData.kmRodados,
      projecaoCentavos: projecaoPorData == null ? null : projecaoPorData - mesPorData.gastoCentavos + gastoMes,
      metaCentavos: meta,
      semanaCentavos: semana.gastoCentavos,
      custoPorKm: _custoPorKm(ciclosCombustivel, ciclosEletricos),
      consumos: consumos,
      meses: _meses(veiculo, registros, gastos, cartoes, agora),
      manutencaoMesCentavos: manutencaoMes,
      ultimos: [
        for (final registro in registros.take(3))
          () {
            final ciclo = ciclosPorRegistro[registro.id];
            final consumo = consumos.where((c) => c.unidade == (registro is Recarga ? 'km/kWh' : 'km/l')).firstOrNull;
            final media = consumo?.mediaMes?.media;
            return RegistroLinhaDoTempo(
              registro: registro,
              consumo: ciclo?.rendimento,
              unidade: registro is Recarga ? 'km/kWh' : 'km/l',
              abaixo: ciclo != null && media != null && ciclo.rendimento < media * (1 - quedaParaDestacar),
            );
          }(),
      ],
    );
  });
});

List<ConsumoInicio> _consumos(
  Veiculo veiculo,
  List<RegistroEnergia> registros,
  List<CicloConsumo> ciclosCombustivel,
  List<CicloConsumo> ciclosEletricos,
  DateTime agora,
  int dias,
) {
  final desde = agora.subtract(Duration(days: dias));
  final consumos = <ConsumoInicio>[];

  if (veiculo.tipoEnergia.abastece) {
    final combustivel = veiculo.flex ? registros.whereType<Abastecimento>().firstOrNull?.combustivel : null;
    final filtrados = combustivel != null ? ciclosCombustivel.where((c) => c.combustivel == combustivel).toList() : ciclosCombustivel;
    consumos.add(ConsumoInicio(
      titulo: combustivel == null ? 'combustível' : combustivel.rotulo.toLowerCase(),
      unidade: 'km/l',
      dias: dias,
      mediaMes: CalculoConsumo.mediaDesde(filtrados, desde, qualquerCombustivel: true),
      ultimo: CalculoConsumo.ultimos(filtrados, 1, qualquerCombustivel: true).firstOrNull,
      ultimos: CalculoConsumo.ultimos(filtrados, 5, qualquerCombustivel: true),
    ));
  }

  if (veiculo.tipoEnergia.recarrega) {
    consumos.add(ConsumoInicio(
      titulo: 'energia',
      unidade: 'km/kWh',
      dias: dias,
      mediaMes: CalculoConsumo.mediaDesde(ciclosEletricos, desde, qualquerCombustivel: true),
      ultimo: CalculoConsumo.ultimos(ciclosEletricos, 1, qualquerCombustivel: true).firstOrNull,
      ultimos: CalculoConsumo.ultimos(ciclosEletricos, 5, qualquerCombustivel: true),
    ));
  }
  return consumos;
}

List<MesGasto> _meses(
  Veiculo veiculo,
  List<RegistroEnergia> registros,
  List<GastoComPagamento> gastos,
  Map<String, Cartao> cartoes,
  DateTime agora,
) {
  const mesesParaTras = 11;
  final atual = DateTime(agora.year, agora.month);
  final seguinte = DateTime(agora.year, agora.month + 1);
  final primeiro = gastos.isEmpty
      ? atual
      : gastos.map((r) => CalculoFatura.mesDoGasto(r, cartoes)).reduce((a, b) => a.isBefore(b) ? a : b);
  final limite = DateTime(agora.year, agora.month - mesesParaTras);
  var mes = primeiro.isBefore(limite) ? limite : (primeiro.isAfter(atual) ? atual : primeiro);

  final meses = <MesGasto>[];
  while (!mes.isAfter(atual)) {
    meses.add(MesGasto(
      mes: mes,
      tipo: mes == atual ? TipoMes.atual : TipoMes.passado,
      totalCentavos: CalculoFatura.gastoDoMes(gastos, cartoes, mes),
      kmRodados: CalculoResumo.doPeriodo(
        registros: registros,
        odometroInicial: veiculo.odometroInicial,
        inicio: mes,
        fim: DateTime(mes.year, mes.month + 1),
      ).kmRodados,
    ));
    mes = DateTime(mes.year, mes.month + 1);
  }

  final noSeguinte = gastos.where((r) => CalculoFatura.mesDoGasto(r, cartoes) == seguinte).toList();
  if (noSeguinte.isNotEmpty) {
    meses.add(MesGasto(
      mes: seguinte,
      tipo: TipoMes.seguinte,
      totalCentavos: noSeguinte.fold(0, (soma, r) => soma + r.valorCentavos),
      kmRodados: 0,
      registrosNoCredito: noSeguinte.where((r) => r.data.isBefore(seguinte)).length,
    ));
  }
  return meses;
}

double? _custoPorKm(List<CicloConsumo> combustivel, List<CicloConsumo> eletrico) {
  final porCombustivel = CalculoConsumo.custoPorKm(combustivel);
  final porEnergia = CalculoConsumo.custoPorKm(eletrico);
  if (porCombustivel == null && porEnergia == null) return null;
  return (porCombustivel ?? 0) + (porEnergia ?? 0);
}
