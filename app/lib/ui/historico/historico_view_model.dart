import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formato.dart';
import '../../data/provedores.dart';
import '../../domain/calculos/calculo_consumo.dart';
import '../../domain/registro_energia.dart';
import '../../domain/veiculo.dart';

enum FiltroHistorico { todos, abastecimentos, recargas }

class ItemHistorico {
  const ItemHistorico({required this.registro, this.consumo, this.alerta = false});

  final RegistroEnergia registro;
  final String? consumo;
  final bool alerta;
}

class GrupoHistorico {
  const GrupoHistorico(this.titulo, this.itens);

  final String titulo;
  final List<ItemHistorico> itens;
}

class HistoricoEstado {
  const HistoricoEstado({
    required this.veiculo,
    required this.filtro,
    required this.grupos,
    required this.vazio,
  });

  final Veiculo? veiculo;
  final FiltroHistorico filtro;
  final List<GrupoHistorico> grupos;
  final bool vazio;

  bool get mostrarFiltro => veiculo != null && veiculo!.tipoEnergia.abastece && veiculo!.tipoEnergia.recarrega;
}

class _Filtro extends Notifier<FiltroHistorico> {
  @override
  FiltroHistorico build() => FiltroHistorico.todos;

  void definir(FiltroHistorico filtro) => state = filtro;
}

final _filtroProvider = NotifierProvider<_Filtro, FiltroHistorico>(_Filtro.new);

class HistoricoViewModel extends Notifier<AsyncValue<HistoricoEstado>> {
  @override
  AsyncValue<HistoricoEstado> build() {
    final filtro = ref.watch(_filtroProvider);
    final veiculo = ref.watch(veiculoAtivoProvider).value;
    return ref.watch(registrosDoAtivoProvider).whenData((registros) {
      final ciclosCombustivel = CalculoConsumo.ciclosDeAbastecimento(registros.whereType<Abastecimento>());
      final ciclosEletricos = CalculoConsumo.ciclosDeRecarga(registros.whereType<Recarga>());
      final ciclosPorRegistro = {
        for (final ciclo in [...ciclosCombustivel, ...ciclosEletricos]) ciclo.registroId: ciclo,
      };

      final filtrados = registros.where((r) => switch (filtro) {
            FiltroHistorico.todos => true,
            FiltroHistorico.abastecimentos => r is Abastecimento,
            FiltroHistorico.recargas => r is Recarga,
          });

      final grupos = <GrupoHistorico>[];
      for (final registro in filtrados) {
        final titulo = _capitalizar(Formato.mesAno(registro.data));
        if (grupos.isEmpty || grupos.last.titulo != titulo) grupos.add(GrupoHistorico(titulo, []));
        final ciclo = ciclosPorRegistro[registro.id];
        final unidade = registro is Recarga ? 'km/kWh' : 'km/l';
        grupos.last.itens.add(ItemHistorico(
          registro: registro,
          consumo: ciclo == null
              ? (registro.contaNaMedia ? null : 'Fora da média de consumo')
              : '${Formato.decimal(ciclo.rendimento)} $unidade',
          alerta: ciclo != null &&
              CalculoConsumo.abaixoDaMedia(ciclo, registro is Recarga ? ciclosEletricos : ciclosCombustivel),
        ));
      }
      return HistoricoEstado(veiculo: veiculo, filtro: filtro, grupos: grupos, vazio: registros.isEmpty);
    });
  }

  void filtrar(FiltroHistorico filtro) => ref.read(_filtroProvider.notifier).definir(filtro);

  Future<void> excluir(RegistroEnergia registro) => ref.read(registroRepositorioProvider).excluir(registro);

  static String _capitalizar(String texto) => texto[0].toUpperCase() + texto.substring(1);
}

final historicoViewModelProvider =
    NotifierProvider<HistoricoViewModel, AsyncValue<HistoricoEstado>>(HistoricoViewModel.new);
