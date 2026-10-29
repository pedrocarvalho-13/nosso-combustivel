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
    required this.ultimoOdometro,
    this.tarifaCasa,
    this.salvando = false,
  });

  final Veiculo? veiculo;
  final LocalRecarga local;
  final int ultimoOdometro;
  final double? tarifaCasa;
  final bool salvando;

  NovaRecargaEstado copiar({LocalRecarga? local, bool? salvando}) => NovaRecargaEstado(
        veiculo: veiculo,
        local: local ?? this.local,
        ultimoOdometro: ultimoOdometro,
        tarifaCasa: tarifaCasa,
        salvando: salvando ?? this.salvando,
      );
}

class NovaRecargaViewModel extends Notifier<NovaRecargaEstado> {
  @override
  NovaRecargaEstado build() {
    final veiculo = ref.read(veiculoAtivoProvider).value;
    final registros = ref.read(registrosDoAtivoProvider).value ?? const [];
    final leituras = registros.map((r) => r.odometro);
    return NovaRecargaEstado(
      veiculo: veiculo,
      local: registros.whereType<Recarga>().firstOrNull?.local ?? LocalRecarga.casa,
      ultimoOdometro: max(veiculo?.odometroInicial ?? 0, leituras.isEmpty ? 0 : leituras.reduce(max)),
      tarifaCasa: ref.read(tarifaCasaProvider).value,
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

    final registros = await ref.read(registrosDoAtivoProvider.future);
    final erroOdometro = ValidacaoOdometro.validar(
      registros: registros,
      odometroInicial: veiculo.odometroInicial,
      data: data,
      odometro: odometro,
    );
    if (erroOdometro != null) return erroOdometro;

    state = state.copiar(salvando: true);
    await ref.read(registroRepositorioProvider).salvarRecarga(Recarga(
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
