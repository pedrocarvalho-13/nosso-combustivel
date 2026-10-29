import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/provedores.dart';
import '../../domain/calculos/calculo_consumo.dart';
import '../../domain/calculos/calculo_etanol.dart';
import '../../domain/calculos/validacao_odometro.dart';
import '../../domain/combustivel.dart';
import '../../domain/registro_energia.dart';
import '../../domain/veiculo.dart';

class NovoAbastecimentoEstado {
  const NovoAbastecimentoEstado({
    required this.veiculo,
    required this.combustivel,
    required this.ultimoOdometro,
    this.preco,
    this.comparacao,
    this.precoOutroCombustivel,
    this.salvando = false,
  });

  final Veiculo? veiculo;
  final Combustivel? combustivel;
  final int ultimoOdometro;
  final double? preco;
  final ComparacaoEtanol? comparacao;
  final double? precoOutroCombustivel;
  final bool salvando;

  NovoAbastecimentoEstado copiar({
    Combustivel? combustivel,
    double? preco,
    ComparacaoEtanol? comparacao,
    double? precoOutroCombustivel,
    bool limparComparacao = false,
    bool? salvando,
  }) =>
      NovoAbastecimentoEstado(
        veiculo: veiculo,
        combustivel: combustivel ?? this.combustivel,
        ultimoOdometro: ultimoOdometro,
        preco: preco ?? this.preco,
        comparacao: limparComparacao ? null : comparacao ?? this.comparacao,
        precoOutroCombustivel: limparComparacao ? null : precoOutroCombustivel ?? this.precoOutroCombustivel,
        salvando: salvando ?? this.salvando,
      );
}

class NovoAbastecimentoViewModel extends Notifier<NovoAbastecimentoEstado> {
  List<RegistroEnergia> get _registros => ref.read(registrosDoAtivoProvider).value ?? const [];

  @override
  NovoAbastecimentoEstado build() {
    final veiculo = ref.read(veiculoAtivoProvider).value;
    final abastecimentos = _registros.whereType<Abastecimento>();
    final ultimoCombustivel = abastecimentos.firstOrNull?.combustivel;
    final combustivel = veiculo == null
        ? null
        : (veiculo.combustiveis.contains(ultimoCombustivel) ? ultimoCombustivel : veiculo.combustiveis.firstOrNull);
    final leituras = _registros.map((r) => r.odometro);
    return NovoAbastecimentoEstado(
      veiculo: veiculo,
      combustivel: combustivel,
      ultimoOdometro: max(veiculo?.odometroInicial ?? 0, leituras.isEmpty ? 0 : leituras.reduce(max)),
    );
  }

  void selecionarCombustivel(Combustivel combustivel) {
    state = state.copiar(combustivel: combustivel);
    _compararEtanol();
  }

  void atualizarPreco(double? preco) {
    state = NovoAbastecimentoEstado(
      veiculo: state.veiculo,
      combustivel: state.combustivel,
      ultimoOdometro: state.ultimoOdometro,
      preco: preco,
      salvando: state.salvando,
    );
    _compararEtanol();
  }

  void _compararEtanol() {
    final veiculo = state.veiculo;
    final combustivel = state.combustivel;
    final preco = state.preco;
    final ehEtanolOuGasolina = combustivel == Combustivel.etanol || combustivel == Combustivel.gasolina;
    if (veiculo == null || !veiculo.flex || !ehEtanolOuGasolina || preco == null) {
      state = state.copiar(limparComparacao: true);
      return;
    }

    final outro = combustivel == Combustivel.etanol ? Combustivel.gasolina : Combustivel.etanol;
    final abastecimentos = _registros.whereType<Abastecimento>().toList();
    final precoOutro = abastecimentos.where((a) => a.combustivel == outro).firstOrNull?.precoLitro;
    if (precoOutro == null) {
      state = state.copiar(limparComparacao: true);
      return;
    }

    final ciclos = CalculoConsumo.ciclosDeAbastecimento(abastecimentos);
    final comparacao = CalculoEtanol.comparar(
      precoEtanol: combustivel == Combustivel.etanol ? preco : precoOutro,
      precoGasolina: combustivel == Combustivel.gasolina ? preco : precoOutro,
      kmlEtanol: CalculoConsumo.media(ciclos, combustivel: Combustivel.etanol),
      kmlGasolina: CalculoConsumo.media(ciclos, combustivel: Combustivel.gasolina),
    );
    state = state.copiar(comparacao: comparacao, precoOutroCombustivel: precoOutro);
  }

  Future<String?> salvar({
    required DateTime data,
    required int? odometro,
    required double? litros,
    required double? preco,
    required double? total,
    required bool tanqueCheio,
    required String posto,
  }) async {
    final veiculo = state.veiculo;
    final combustivel = state.combustivel;
    if (veiculo == null || combustivel == null) return 'Cadastre um carro antes de abastecer.';
    if (odometro == null) return 'Informe o odômetro.';
    if (litros == null || litros <= 0) return 'Informe quantos litros entraram.';
    if (preco == null || preco <= 0) return 'Informe o preço por litro.';

    final registros = await ref.read(registrosDoAtivoProvider.future);
    final erroOdometro = ValidacaoOdometro.validar(
      registros: registros,
      odometroInicial: veiculo.odometroInicial,
      data: data,
      odometro: odometro,
    );
    if (erroOdometro != null) return erroOdometro;

    state = state.copiar(salvando: true);
    await ref.read(registroRepositorioProvider).salvarAbastecimento(Abastecimento(
          id: ref.read(geradorIdProvider)(),
          veiculoId: veiculo.id,
          data: data,
          odometro: odometro,
          valorCentavos: ((total ?? litros * preco) * 100).round(),
          combustivel: combustivel,
          litros: litros,
          precoLitro: preco,
          tanqueCheio: tanqueCheio,
          posto: posto.trim().isEmpty ? null : posto.trim(),
        ));
    if (ref.mounted) state = state.copiar(salvando: false);
    return null;
  }
}

final novoAbastecimentoViewModelProvider =
    NotifierProvider.autoDispose<NovoAbastecimentoViewModel, NovoAbastecimentoEstado>(NovoAbastecimentoViewModel.new);
