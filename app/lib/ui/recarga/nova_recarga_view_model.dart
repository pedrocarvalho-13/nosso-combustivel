import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/provedores.dart';
import '../../domain/calculos/validacao_odometro.dart';
import '../../domain/registro_energia.dart';
import '../../domain/veiculo.dart';

class NovaRecargaEstado {
  const NovaRecargaEstado({
    required this.veiculo,
    required this.local,
    this.registros = const [],
    this.tarifaCasa,
    this.salvando = false,
  });

  final Veiculo? veiculo;
  final LocalRecarga local;
  final List<RegistroEnergia> registros;
  final double? tarifaCasa;
  final bool salvando;

  int get ultimoOdometro => registros.fold(veiculo?.odometroInicial ?? 0, (maior, r) => max(maior, r.odometro));

  NovaRecargaEstado copiar({
    LocalRecarga? local,
    List<RegistroEnergia>? registros,
    double? tarifaCasa,
    bool? salvando,
  }) =>
      NovaRecargaEstado(
        veiculo: veiculo,
        local: local ?? this.local,
        registros: registros ?? this.registros,
        tarifaCasa: tarifaCasa ?? this.tarifaCasa,
        salvando: salvando ?? this.salvando,
      );
}

class NovaRecargaViewModel extends Notifier<NovaRecargaEstado> {
  @override
  NovaRecargaEstado build() {
    final veiculo = ref.read(veiculoAtivoProvider).value;
    if (veiculo != null) Future.microtask(() => _carregar(veiculo));
    return NovaRecargaEstado(veiculo: veiculo, local: LocalRecarga.casa);
  }

  Future<void> _carregar(Veiculo veiculo) async {
    final registros = await ref.read(registroRepositorioProvider).listarDoVeiculo(veiculo.id);
    final tarifa = await ref.read(preferenciasRepositorioProvider).observarTarifaCasa().first;
    if (!ref.mounted) return;
    state = state.copiar(
      registros: registros,
      tarifaCasa: tarifa,
      local: registros.whereType<Recarga>().firstOrNull?.local,
    );
  }

  void selecionarLocal(LocalRecarga local) => state = state.copiar(local: local);

  Future<String?> salvar({
    required DateTime data,
    required int? odometro,
    required double? kwh,
    required double? preco,
    required double? total,
    required bool cargaCompleta,
  }) async {
    final veiculo = state.veiculo;
    if (veiculo == null) return 'Cadastre um carro antes de recarregar.';
    if (odometro == null) return 'Informe o odômetro.';
    if (kwh == null || kwh <= 0) return 'Informe quantos kWh entraram.';
    if (preco == null || preco < 0) return 'Informe o preço por kWh.';

    final repositorio = ref.read(registroRepositorioProvider);
    final erroOdometro = ValidacaoOdometro.validar(
      registros: await repositorio.listarDoVeiculo(veiculo.id),
      odometroInicial: veiculo.odometroInicial,
      data: data,
      odometro: odometro,
    );
    if (erroOdometro != null) return erroOdometro;

    state = state.copiar(salvando: true);
    await repositorio.salvarRecarga(Recarga(
      id: ref.read(geradorIdProvider)(),
      veiculoId: veiculo.id,
      data: data,
      odometro: odometro,
      valorCentavos: ((total ?? kwh * preco) * 100).round(),
      local: state.local,
      kwh: kwh,
      precoKwh: preco,
      cargaCompleta: cargaCompleta,
    ));
    if (state.local == LocalRecarga.casa) {
      await ref.read(preferenciasRepositorioProvider).definirTarifaCasa(preco);
    }
    if (ref.mounted) state = state.copiar(salvando: false);
    return null;
  }
}

final novaRecargaViewModelProvider =
    NotifierProvider.autoDispose<NovaRecargaViewModel, NovaRecargaEstado>(NovaRecargaViewModel.new);
