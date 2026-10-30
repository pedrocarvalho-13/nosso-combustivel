import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formato.dart';
import '../../data/provedores.dart';
import '../../domain/calculos/calculo_consumo.dart';
import '../../domain/calculos/calculo_resumo.dart';
import '../../domain/combustivel.dart';
import '../../domain/registro_energia.dart';
import '../../domain/veiculo.dart';

class Indicador {
  const Indicador(this.rotulo, this.valor);

  final String rotulo;
  final String valor;
}

class InicioEstado {
  const InicioEstado({
    required this.veiculo,
    required this.mes,
    required this.nomeMes,
    required this.projecaoCentavos,
    required this.indicadores,
    required this.ultimos,
  });

  final Veiculo veiculo;
  final ResumoPeriodo mes;
  final String nomeMes;
  final int? projecaoCentavos;
  final List<Indicador> indicadores;
  final List<RegistroEnergia> ultimos;
}

final inicioViewModelProvider = Provider<AsyncValue<InicioEstado?>>((ref) {
  final registros = ref.watch(registrosDoAtivoProvider).value ?? const <RegistroEnergia>[];
  final agora = ref.watch(relogioProvider)();

  return ref.watch(veiculoAtivoProvider).whenData((veiculo) {
    if (veiculo == null) return null;

    final mes = CalculoResumo.doPeriodo(
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

    final indicadores = [
      Indicador('Esta semana', Formato.moeda(semana.gastoCentavos)),
      Indicador('Custo por km', _custoPorKm(registros)),
      ..._consumos(veiculo, registros),
    ];
    if (indicadores.length.isOdd) {
      final leituras = registros.map((r) => r.odometro);
      final odometro = max(veiculo.odometroInicial, leituras.isEmpty ? 0 : leituras.reduce(max));
      indicadores.add(Indicador('Odômetro', Formato.km(odometro)));
    }

    return InicioEstado(
      veiculo: veiculo,
      mes: mes,
      nomeMes: Formato.mes(agora),
      projecaoCentavos: CalculoResumo.projecaoDoMes(registros: registros, agora: agora),
      indicadores: indicadores,
      ultimos: registros.take(3).toList(),
    );
  });
});

List<Indicador> _consumos(Veiculo veiculo, List<RegistroEnergia> registros) {
  String valor(double? media, String unidade) => media == null ? '—' : '${Formato.decimal(media)} $unidade';
  final indicadores = <Indicador>[];

  if (veiculo.tipoEnergia.abastece) {
    final ciclos = CalculoConsumo.ciclosDeAbastecimento(registros.whereType<Abastecimento>());
    if (veiculo.flex) {
      indicadores
        ..add(Indicador('Consumo · etanol', valor(CalculoConsumo.media(ciclos, combustivel: Combustivel.etanol), 'km/l')))
        ..add(Indicador('Consumo · gasolina', valor(CalculoConsumo.media(ciclos, combustivel: Combustivel.gasolina), 'km/l')));
    } else {
      indicadores.add(Indicador('Consumo médio', valor(CalculoConsumo.media(ciclos, qualquerCombustivel: true), 'km/l')));
    }
  }

  if (veiculo.tipoEnergia.recarrega) {
    final ciclos = CalculoConsumo.ciclosDeRecarga(registros.whereType<Recarga>());
    indicadores.add(Indicador('Consumo elétrico', valor(CalculoConsumo.media(ciclos), 'km/kWh')));
  }
  return indicadores;
}

String _custoPorKm(List<RegistroEnergia> registros) {
  final combustivel = CalculoConsumo.custoPorKm(CalculoConsumo.ciclosDeAbastecimento(registros.whereType<Abastecimento>()));
  final eletrico = CalculoConsumo.custoPorKm(CalculoConsumo.ciclosDeRecarga(registros.whereType<Recarga>()));
  if (combustivel == null && eletrico == null) return 'após 2 tanques';
  return Formato.moedaPorKm((combustivel ?? 0) + (eletrico ?? 0));
}
