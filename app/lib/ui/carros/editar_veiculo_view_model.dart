import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formato.dart';
import '../../data/provedores.dart';
import '../../domain/calculos/identificacao_energia.dart';
import '../../domain/veiculo.dart';

enum CampoVeiculo { apelido, marca, modelo, odometro }

class EditarVeiculoEstado {
  const EditarVeiculoEstado({this.veiculo, this.energia, this.menorLeitura, this.salvando = false});

  final Veiculo? veiculo;
  final EnergiaIdentificada? energia;
  final int? menorLeitura;
  final bool salvando;
}

class EditarVeiculoViewModel extends Notifier<EditarVeiculoEstado> {
  EditarVeiculoViewModel(this.veiculoId);

  final String veiculoId;

  @override
  EditarVeiculoEstado build() {
    Future.microtask(_carregar);
    return const EditarVeiculoEstado();
  }

  Future<void> _carregar() async {
    final veiculo = await ref.read(veiculoRepositorioProvider).obter(veiculoId);
    if (veiculo == null) return;
    final registros = await ref.read(registroRepositorioProvider).listarDoVeiculo(veiculoId);
    if (!ref.mounted) return;
    state = EditarVeiculoEstado(
      veiculo: veiculo,
      energia: EnergiaIdentificada(veiculo.tipoEnergia, veiculo.combustiveis),
      menorLeitura: registros.isEmpty ? null : registros.map((r) => r.odometro).reduce(min),
    );
  }

  void corrigirEnergia(EnergiaIdentificada energia) => state = EditarVeiculoEstado(
        veiculo: state.veiculo,
        energia: energia,
        menorLeitura: state.menorLeitura,
      );

  Future<Map<CampoVeiculo, String>> salvar({
    required String apelido,
    required String marca,
    required String modelo,
    required int? ano,
    required double? tanqueL,
    required double? bateriaKwh,
    required int? odometro,
  }) async {
    final veiculo = state.veiculo;
    final energia = state.energia;
    if (veiculo == null || energia == null) return const {};
    final menor = state.menorLeitura;
    final erros = <CampoVeiculo, String>{
      if (apelido.trim().isEmpty) CampoVeiculo.apelido: 'Informe um apelido.',
      if (marca.trim().isEmpty) CampoVeiculo.marca: 'Informe a marca.',
      if (modelo.trim().isEmpty) CampoVeiculo.modelo: 'Informe o modelo.',
      if (odometro == null) CampoVeiculo.odometro: 'Informe o hodômetro inicial.',
      if (odometro != null && menor != null && odometro > menor)
        CampoVeiculo.odometro: 'Precisa ser no máximo ${Formato.km(menor)}, a menor leitura registrada.',
    };
    if (erros.isNotEmpty) return erros;

    await ref.read(veiculoRepositorioProvider).atualizar(veiculo.copiar(
          apelido: apelido.trim(),
          marca: marca.trim(),
          modelo: modelo.trim(),
          ano: () => ano,
          tipoEnergia: energia.tipo,
          combustiveis: energia.combustiveis,
          capacidadeTanqueL: () => energia.tipo.abastece ? tanqueL : null,
          capacidadeBateriaKwh: () => energia.tipo.recarrega ? bateriaKwh : null,
          odometroInicial: odometro,
        ));
    return const {};
  }

  Future<void> excluir() => ref.read(veiculoRepositorioProvider).excluir(veiculoId);
}

final editarVeiculoViewModelProvider = NotifierProvider.autoDispose
    .family<EditarVeiculoViewModel, EditarVeiculoEstado, String>(EditarVeiculoViewModel.new);
