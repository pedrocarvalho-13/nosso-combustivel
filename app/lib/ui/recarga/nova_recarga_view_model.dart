import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/provedores.dart';
import '../../domain/calculos/validacao_odometro.dart';
import '../../domain/forma_pagamento.dart';
import '../../domain/registro_energia.dart';
import '../../domain/veiculo.dart';
import '../comum/formulario_registro.dart';

class NovaRecargaEstado {
  const NovaRecargaEstado({
    required this.veiculo,
    required this.local,
    this.registros = const [],
    this.editando,
    this.tarifaCasa,
    this.salvando = false,
  });

  final Veiculo? veiculo;
  final LocalRecarga local;
  final List<RegistroEnergia> registros;
  final Recarga? editando;
  final double? tarifaCasa;
  final bool salvando;

  int get ultimoOdometro => registros
      .where((r) => r.id != editando?.id)
      .fold(veiculo?.odometroInicial ?? 0, (maior, r) => max(maior, r.odometro));

  NovaRecargaEstado copiar({
    LocalRecarga? local,
    List<RegistroEnergia>? registros,
    Recarga? editando,
    double? tarifaCasa,
    bool? salvando,
  }) =>
      NovaRecargaEstado(
        veiculo: veiculo,
        local: local ?? this.local,
        registros: registros ?? this.registros,
        editando: editando ?? this.editando,
        tarifaCasa: tarifaCasa ?? this.tarifaCasa,
        salvando: salvando ?? this.salvando,
      );
}

class NovaRecargaViewModel extends Notifier<NovaRecargaEstado> {
  NovaRecargaViewModel(this.registroId);

  final String? registroId;

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
    final editando = registros.whereType<Recarga>().where((r) => r.id == registroId).firstOrNull;
    state = state.copiar(
      registros: registros,
      editando: editando,
      tarifaCasa: tarifa,
      local: editando?.local ?? registros.whereType<Recarga>().firstOrNull?.local,
    );
  }

  void selecionarLocal(LocalRecarga local) => state = state.copiar(local: local);

  Future<ResultadoSalvar> salvar({
    required DateTime data,
    required int? odometro,
    required double? kwh,
    required double? preco,
    required double? total,
    required bool cargaCompleta,
    FormaPagamento? formaPagamento,
    String? cartaoId,
    bool contaNaMedia = true,
  }) async {
    final veiculo = state.veiculo;
    if (veiculo == null) return const ResultadoSalvar.mensagem('Cadastre um veículo antes de recarregar.');

    final erros = <CampoRegistro, String>{
      if (odometro == null) CampoRegistro.odometro: 'Informe o hodômetro.',
      if (kwh == null || kwh <= 0) CampoRegistro.quantidade: 'Informe os kWh.',
      if (preco == null || preco < 0) CampoRegistro.preco: 'Informe o preço.',
    };
    if (erros.isNotEmpty) return ResultadoSalvar.erros(erros);
    if (formaPagamento == FormaPagamento.credito && cartaoId == null) {
      return const ResultadoSalvar.mensagem('Escolha o cartão de crédito usado.');
    }

    final repositorio = ref.read(registroRepositorioProvider);
    final erroOdometro = ValidacaoOdometro.validar(
      registros: await repositorio.listarDoVeiculo(veiculo.id),
      odometroInicial: veiculo.odometroInicial,
      data: data,
      odometro: odometro!,
      ignorarId: state.editando?.id,
    );
    if (erroOdometro != null) return ResultadoSalvar.erros({CampoRegistro.odometro: erroOdometro});

    state = state.copiar(salvando: true);
    await repositorio.salvarRecarga(Recarga(
      id: state.editando?.id ?? ref.read(geradorIdProvider)(),
      veiculoId: veiculo.id,
      data: data,
      odometro: odometro,
      valorCentavos: ((total ?? kwh! * preco!) * 100).round(),
      local: state.local,
      kwh: kwh!,
      precoKwh: preco!,
      cargaCompleta: cargaCompleta,
      formaPagamento: formaPagamento,
      cartaoId: formaPagamento == FormaPagamento.credito ? cartaoId : null,
      contaNaMedia: contaNaMedia,
    ));
    await ref.read(preferenciasRepositorioProvider).definirUltimoPagamento('${formaPagamento?.name ?? ''}|${cartaoId ?? ''}');
    if (state.local == LocalRecarga.casa) {
      await ref.read(preferenciasRepositorioProvider).definirTarifaCasa(preco);
    }
    if (ref.mounted) state = state.copiar(salvando: false);
    return const ResultadoSalvar.ok();
  }

  Future<void> excluir() async {
    final editando = state.editando;
    if (editando != null) await ref.read(registroRepositorioProvider).excluir(editando);
  }
}

final novaRecargaViewModelProvider = NotifierProvider.autoDispose
    .family<NovaRecargaViewModel, NovaRecargaEstado, String?>(NovaRecargaViewModel.new);
