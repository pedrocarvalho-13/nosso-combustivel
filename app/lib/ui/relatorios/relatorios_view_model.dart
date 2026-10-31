import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/provedores.dart';
import '../../domain/calculos/calculo_consumo.dart';
import '../../domain/calculos/calculo_relatorio.dart';
import '../../domain/calculos/calculo_resumo.dart';
import '../../domain/cartao.dart';
import '../../domain/registro_energia.dart';
import '../../domain/veiculo.dart';

class CicloRelatorio {
  const CicloRelatorio({required this.ciclo, required this.unidade, required this.abaixoDaMedia});

  final CicloConsumo ciclo;
  final String unidade;
  final bool abaixoDaMedia;
}

class ComparativoVeiculo {
  const ComparativoVeiculo({required this.veiculo, required this.gastoCentavos, required this.custoPorKm});

  final Veiculo veiculo;
  final int gastoCentavos;
  final double? custoPorKm;
}

class RelatoriosEstado {
  const RelatoriosEstado({
    required this.veiculo,
    required this.meses,
    required this.totalCentavos,
    required this.mediaMensalCentavos,
    required this.kmRodados,
    required this.custoPorKm,
    required this.ciclos,
  });

  final Veiculo veiculo;
  final List<GastoMensal> meses;
  final int totalCentavos;
  final int? mediaMensalCentavos;
  final int kmRodados;
  final double? custoPorKm;
  final List<CicloRelatorio> ciclos;

  bool get vazio => meses.every((m) => m.totalCentavos == 0);
}

const _mesesDoRelatorio = 12;
const _ciclosExibidos = 8;

final relatoriosViewModelProvider = Provider<AsyncValue<RelatoriosEstado?>>((ref) {
  final registros = ref.watch(registrosDoAtivoProvider).value ?? const <RegistroEnergia>[];
  final agora = ref.watch(relogioProvider)();
  final cartoes = {for (final c in ref.watch(cartoesProvider).value ?? const <Cartao>[]) c.id: c};

  return ref.watch(veiculoAtivoProvider).whenData((veiculo) {
    if (veiculo == null) return null;
    final meses = CalculoRelatorio.gastoPorMes(registros, agora, meses: _mesesDoRelatorio, cartoes: cartoes);
    final periodo = CalculoResumo.doPeriodo(
      registros: registros,
      odometroInicial: veiculo.odometroInicial,
      inicio: meses.first.mes,
      fim: DateTime(agora.year, agora.month + 1),
    );
    return RelatoriosEstado(
      veiculo: veiculo,
      meses: meses,
      totalCentavos: CalculoRelatorio.totalFechado(meses),
      mediaMensalCentavos: CalculoRelatorio.mediaMensal(meses),
      kmRodados: periodo.kmRodados,
      custoPorKm: _custoPorKm(registros),
      ciclos: _ciclos(registros),
    );
  });
});

final comparativoVeiculosProvider = FutureProvider<List<ComparativoVeiculo>>((ref) async {
  ref.watch(registrosDoAtivoProvider);
  final veiculos = ref.watch(veiculosProvider).value ?? const <Veiculo>[];
  if (veiculos.length < 2) return const [];
  final repositorio = ref.watch(registroRepositorioProvider);
  final agora = ref.watch(relogioProvider)();
  final inicio = DateTime(agora.year, agora.month - (_mesesDoRelatorio - 1));

  final comparativo = <ComparativoVeiculo>[];
  for (final veiculo in veiculos) {
    final registros = await repositorio.listarDoVeiculo(veiculo.id);
    comparativo.add(
      ComparativoVeiculo(
        veiculo: veiculo,
        gastoCentavos: registros.where((r) => !r.data.isBefore(inicio)).fold(0, (soma, r) => soma + r.valorCentavos),
        custoPorKm: _custoPorKm(registros),
      ),
    );
  }
  return comparativo..sort((a, b) => b.gastoCentavos.compareTo(a.gastoCentavos));
});

double? _custoPorKm(List<RegistroEnergia> registros) {
  final combustivel = CalculoConsumo.custoPorKm(
    CalculoConsumo.ciclosDeAbastecimento(registros.whereType<Abastecimento>()),
  );
  final eletrico = CalculoConsumo.custoPorKm(CalculoConsumo.ciclosDeRecarga(registros.whereType<Recarga>()));
  if (combustivel == null && eletrico == null) return null;
  return (combustivel ?? 0) + (eletrico ?? 0);
}

List<CicloRelatorio> _ciclos(List<RegistroEnergia> registros) {
  final deCombustivel = CalculoConsumo.ciclosDeAbastecimento(registros.whereType<Abastecimento>());
  final deRecarga = CalculoConsumo.ciclosDeRecarga(registros.whereType<Recarga>());
  final todos = [
    for (final ciclo in deCombustivel)
      CicloRelatorio(ciclo: ciclo, unidade: 'km/l', abaixoDaMedia: CalculoConsumo.abaixoDaMedia(ciclo, deCombustivel)),
    for (final ciclo in deRecarga)
      CicloRelatorio(ciclo: ciclo, unidade: 'km/kWh', abaixoDaMedia: CalculoConsumo.abaixoDaMedia(ciclo, deRecarga)),
  ]..sort((a, b) => b.ciclo.fim.compareTo(a.ciclo.fim));
  return todos.take(_ciclosExibidos).toList();
}
