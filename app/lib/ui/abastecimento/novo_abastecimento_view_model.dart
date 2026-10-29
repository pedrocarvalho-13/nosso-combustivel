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
    this.registros = const [],
    this.preco,
    this.comparacao,
    this.salvando = false,
  });

  final Veiculo? veiculo;
  final Combustivel? combustivel;
  final List<RegistroEnergia> registros;
  final double? preco;
  final ComparacaoEtanol? comparacao;
  final bool salvando;

  int get ultimoOdometro => registros.fold(veiculo?.odometroInicial ?? 0, (maior, r) => max(maior, r.odometro));

  NovoAbastecimentoEstado copiar({
    Combustivel? combustivel,
    List<RegistroEnergia>? registros,
    double? Function()? preco,
    ComparacaoEtanol? Function()? comparacao,
    bool? salvando,
  }) =>
      NovoAbastecimentoEstado(
        veiculo: veiculo,
        combustivel: combustivel ?? this.combustivel,
        registros: registros ?? this.registros,
        preco: preco == null ? this.preco : preco(),
        comparacao: comparacao == null ? this.comparacao : comparacao(),
        salvando: salvando ?? this.salvando,
      );
}

class NovoAbastecimentoViewModel extends Notifier<NovoAbastecimentoEstado> {
  @override
  NovoAbastecimentoEstado build() {
    final veiculo = ref.read(veiculoAtivoProvider).value;
    if (veiculo != null) Future.microtask(() => _carregar(veiculo));
    return NovoAbastecimentoEstado(veiculo: veiculo, combustivel: veiculo?.combustiveis.firstOrNull);
  }

  Future<void> _carregar(Veiculo veiculo) async {
    final registros = await ref.read(registroRepositorioProvider).listarDoVeiculo(veiculo.id);
    if (!ref.mounted) return;
    final ultimoCombustivel = registros.whereType<Abastecimento>().firstOrNull?.combustivel;
    state = state.copiar(
      registros: registros,
      combustivel: veiculo.combustiveis.contains(ultimoCombustivel) ? ultimoCombustivel : null,
    );
    _compararEtanol();
  }

  void selecionarCombustivel(Combustivel combustivel) {
    state = state.copiar(combustivel: combustivel);
    _compararEtanol();
  }

  void atualizarPreco(double? preco) {
    state = state.copiar(preco: () => preco);
    _compararEtanol();
  }

  void _compararEtanol() {
    state = state.copiar(comparacao: () => _comparacao(state));
  }

  static ComparacaoEtanol? _comparacao(NovoAbastecimentoEstado estado) {
    final veiculo = estado.veiculo;
    final combustivel = estado.combustivel;
    final preco = estado.preco;
    final ehEtanolOuGasolina = combustivel == Combustivel.etanol || combustivel == Combustivel.gasolina;
    if (veiculo == null || !veiculo.flex || !ehEtanolOuGasolina || preco == null) return null;

    final outro = combustivel == Combustivel.etanol ? Combustivel.gasolina : Combustivel.etanol;
    final abastecimentos = estado.registros.whereType<Abastecimento>().toList();
    final precoOutro = abastecimentos.where((a) => a.combustivel == outro).firstOrNull?.precoLitro;
    if (precoOutro == null) return null;

    final ciclos = CalculoConsumo.ciclosDeAbastecimento(abastecimentos);
    return CalculoEtanol.comparar(
      precoEtanol: combustivel == Combustivel.etanol ? preco : precoOutro,
      precoGasolina: combustivel == Combustivel.gasolina ? preco : precoOutro,
      kmlEtanol: CalculoConsumo.media(ciclos, combustivel: Combustivel.etanol),
      kmlGasolina: CalculoConsumo.media(ciclos, combustivel: Combustivel.gasolina),
    );
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

    final repositorio = ref.read(registroRepositorioProvider);
    final erroOdometro = ValidacaoOdometro.validar(
      registros: await repositorio.listarDoVeiculo(veiculo.id),
      odometroInicial: veiculo.odometroInicial,
      data: data,
      odometro: odometro,
    );
    if (erroOdometro != null) return erroOdometro;

    state = state.copiar(salvando: true);
    await repositorio.salvarAbastecimento(Abastecimento(
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
