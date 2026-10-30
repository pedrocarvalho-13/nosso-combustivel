import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/fipe/fipe_cliente.dart';
import '../../data/ia/cliente_ia.dart';
import '../../data/provedores.dart';
import '../../data/sessao/sessao_controller.dart';
import '../../domain/calculos/identificacao_energia.dart';
import '../../domain/combustivel.dart';
import '../../domain/tipo_energia.dart';
import '../../domain/tipo_veiculo.dart';
import '../../domain/veiculo.dart';

enum CampoCadastro { fipe, marca, modelo, odometro, geral }

class CadastroCarroEstado {
  const CadastroCarroEstado({
    this.tipoVeiculo = TipoVeiculo.carro,
    this.manual = false,
    this.marcas = const AsyncLoading(),
    this.marca,
    this.modelos = const AsyncData([]),
    this.modelo,
    this.anos = const AsyncData([]),
    this.ano,
    this.detalhe,
    this.carregandoDetalhe = false,
    this.energia,
    this.energiaCorrigida = false,
    this.salvando = false,
    this.consultandoIa = false,
  });

  static const _manter = Object();

  final TipoVeiculo tipoVeiculo;
  final bool manual;
  final AsyncValue<List<OpcaoFipe>> marcas;
  final OpcaoFipe? marca;
  final AsyncValue<List<OpcaoFipe>> modelos;
  final OpcaoFipe? modelo;
  final AsyncValue<List<OpcaoFipe>> anos;
  final OpcaoFipe? ano;
  final DetalheFipe? detalhe;
  final bool carregandoDetalhe;
  final EnergiaIdentificada? energia;
  final bool energiaCorrigida;
  final bool salvando;
  final bool consultandoIa;

  bool get podeSalvar => !salvando && energia != null && (manual || detalhe != null);

  CadastroCarroEstado copiar({
    TipoVeiculo? tipoVeiculo,
    bool? manual,
    AsyncValue<List<OpcaoFipe>>? marcas,
    Object? marca = _manter,
    AsyncValue<List<OpcaoFipe>>? modelos,
    Object? modelo = _manter,
    AsyncValue<List<OpcaoFipe>>? anos,
    Object? ano = _manter,
    Object? detalhe = _manter,
    bool? carregandoDetalhe,
    Object? energia = _manter,
    bool? energiaCorrigida,
    bool? salvando,
    bool? consultandoIa,
  }) => CadastroCarroEstado(
    tipoVeiculo: tipoVeiculo ?? this.tipoVeiculo,
    manual: manual ?? this.manual,
    marcas: marcas ?? this.marcas,
    marca: identical(marca, _manter) ? this.marca : marca as OpcaoFipe?,
    modelos: modelos ?? this.modelos,
    modelo: identical(modelo, _manter) ? this.modelo : modelo as OpcaoFipe?,
    anos: anos ?? this.anos,
    ano: identical(ano, _manter) ? this.ano : ano as OpcaoFipe?,
    detalhe: identical(detalhe, _manter) ? this.detalhe : detalhe as DetalheFipe?,
    carregandoDetalhe: carregandoDetalhe ?? this.carregandoDetalhe,
    energia: identical(energia, _manter) ? this.energia : energia as EnergiaIdentificada?,
    energiaCorrigida: energiaCorrigida ?? this.energiaCorrigida,
    salvando: salvando ?? this.salvando,
    consultandoIa: consultandoIa ?? this.consultandoIa,
  );
}

class CadastroCarroViewModel extends Notifier<CadastroCarroEstado> {
  static const energiaPadraoManual = EnergiaIdentificada(TipoEnergia.combustao, [Combustivel.gasolina]);

  FipeCliente get _fipe => ref.read(fipeClienteProvider);

  @override
  CadastroCarroEstado build() {
    Future.microtask(carregarMarcas);
    return const CadastroCarroEstado();
  }

  Future<void> carregarMarcas() async {
    state = state.copiar(marcas: const AsyncLoading());
    final tipo = state.tipoVeiculo;
    final resultado = await AsyncValue.guard(() => _fipe.marcas(tipo));
    if (ref.mounted && state.tipoVeiculo == tipo) state = state.copiar(marcas: resultado);
  }

  Future<void> selecionarMarca(OpcaoFipe? marca) async {
    state = state.copiar(
      marca: marca,
      modelo: null,
      modelos: marca == null ? const AsyncData([]) : const AsyncLoading(),
      ano: null,
      anos: const AsyncData([]),
      detalhe: null,
      energia: null,
      energiaCorrigida: false,
    );
    if (marca == null) return;
    final resultado = await AsyncValue.guard(() => _fipe.modelos(state.tipoVeiculo, marca.codigo));
    if (ref.mounted && state.marca == marca) state = state.copiar(modelos: resultado);
  }

  Future<void> selecionarModelo(OpcaoFipe? modelo) async {
    final marca = state.marca;
    state = state.copiar(
      modelo: modelo,
      ano: null,
      anos: modelo == null ? const AsyncData([]) : const AsyncLoading(),
      detalhe: null,
      energia: null,
      energiaCorrigida: false,
    );
    if (marca == null || modelo == null) return;
    final resultado = await AsyncValue.guard(() => _fipe.anos(state.tipoVeiculo, marca.codigo, modelo.codigo));
    if (ref.mounted && state.modelo == modelo) state = state.copiar(anos: resultado);
  }

  Future<String?> selecionarAno(OpcaoFipe ano) async {
    final marca = state.marca;
    final modelo = state.modelo;
    if (marca == null || modelo == null) return null;
    state = state.copiar(ano: ano, detalhe: null, energia: null, energiaCorrigida: false, carregandoDetalhe: true);
    try {
      final detalhe = await _fipe.detalhe(state.tipoVeiculo, marca.codigo, modelo.codigo, ano.codigo);
      if (!ref.mounted || state.ano != ano) return null;
      state = state.copiar(
        detalhe: detalhe,
        carregandoDetalhe: false,
        energia: IdentificacaoEnergia.identificar(modelo: detalhe.modelo, combustivelFipe: detalhe.combustivel),
      );
      return null;
    } catch (_) {
      if (ref.mounted) state = state.copiar(carregandoDetalhe: false, ano: null);
      return 'Não foi possível consultar a FIPE agora. Tente de novo ou cadastre sem a FIPE.';
    }
  }

  void selecionarTipoVeiculo(TipoVeiculo tipo) {
    if (tipo == state.tipoVeiculo) return;
    state = CadastroCarroEstado(
      tipoVeiculo: tipo,
      manual: state.manual,
      energia: state.manual ? energiaPadraoManual : null,
    );
    carregarMarcas();
  }

  void corrigirEnergia(EnergiaIdentificada energia) {
    state = state.copiar(energia: energia, energiaCorrigida: true);
  }

  void alternarManual() {
    final manual = !state.manual;
    state = state.copiar(
      manual: manual,
      energia: manual ? (state.energia ?? energiaPadraoManual) : (state.detalhe == null ? null : state.energia),
    );
  }

  Future<({CapacidadeSugerida? capacidade, String? erro})> sugerirCapacidade({
    required String marcaManual,
    required String modeloManual,
    int? anoManual,
  }) async {
    final energia = state.energia;
    final detalhe = state.detalhe;
    final marca = state.manual ? marcaManual.trim() : detalhe?.marca ?? '';
    final modelo = state.manual ? modeloManual.trim() : detalhe?.modelo ?? '';
    if (energia == null || marca.isEmpty || modelo.isEmpty) {
      return (capacidade: null, erro: 'Informe marca e modelo para a IA procurar.');
    }
    state = state.copiar(consultandoIa: true);
    try {
      final capacidade = await ref
          .read(clienteIaProvider)
          .estimarCapacidade(
            tipoVeiculo: state.tipoVeiculo,
            marca: marca,
            modelo: modelo,
            ano: state.manual ? anoManual : detalhe?.anoModelo,
            codigoFipe: state.manual ? null : detalhe?.codigoFipe,
            tipoEnergia: energia.tipo,
          );
      return (capacidade: capacidade, erro: null);
    } on ErroIa catch (erro) {
      return (capacidade: null, erro: erro.mensagem);
    } finally {
      if (ref.mounted) state = state.copiar(consultandoIa: false);
    }
  }

  Future<Map<CampoCadastro, String>> salvar({
    required String apelido,
    required String marcaManual,
    required String modeloManual,
    int? anoManual,
    double? tanqueL,
    double? bateriaKwh,
    int? odometro,
  }) async {
    final energia = state.energia;
    final detalhe = state.detalhe;
    final usuarioId = ref.read(sessaoProvider).value?.usuario.id;
    if (usuarioId == null) return {CampoCadastro.geral: 'Entre na sua conta para cadastrar um veículo.'};
    final marca = state.manual ? marcaManual.trim() : detalhe?.marca ?? '';
    final modelo = state.manual ? modeloManual.trim() : detalhe?.modelo ?? '';
    final erros = <CampoCadastro, String>{
      if (state.manual && marca.isEmpty) CampoCadastro.marca: 'Informe a marca.',
      if (state.manual && modelo.isEmpty) CampoCadastro.modelo: 'Informe o modelo.',
      if (!state.manual && detalhe == null) CampoCadastro.fipe: 'Escolha marca, modelo e ano.',
      if (odometro == null) CampoCadastro.odometro: 'Informe o hodômetro atual.',
    };
    if (erros.isNotEmpty || energia == null) return erros;

    state = state.copiar(salvando: true);
    final veiculo = Veiculo(
      id: ref.read(geradorIdProvider)(),
      tipoVeiculo: state.tipoVeiculo,
      apelido: apelido.trim().isEmpty ? modelo : apelido.trim(),
      marca: marca,
      modelo: modelo,
      ano: state.manual ? anoManual : detalhe!.anoModelo,
      codigoFipe: state.manual ? null : detalhe!.codigoFipe,
      tipoEnergia: energia.tipo,
      combustiveis: energia.combustiveis,
      capacidadeTanqueL: energia.tipo.abastece ? tanqueL : null,
      capacidadeBateriaKwh: energia.tipo.recarrega ? bateriaKwh : null,
      odometroInicial: odometro!,
    );
    await ref.read(veiculoRepositorioProvider).salvar(veiculo, usuarioId: usuarioId);
    await ref.read(preferenciasRepositorioProvider).definirVeiculoAtivo(veiculo.id);
    if (ref.mounted) state = state.copiar(salvando: false);
    return const {};
  }
}

final cadastroCarroViewModelProvider = NotifierProvider.autoDispose<CadastroCarroViewModel, CadastroCarroEstado>(
  CadastroCarroViewModel.new,
);
