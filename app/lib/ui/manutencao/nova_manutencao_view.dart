import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formato.dart';
import '../../core/tema/cores_base.dart';
import '../../data/ia/cliente_ia.dart';
import '../../data/postos/cliente_postos.dart';
import '../../data/provedores.dart';
import '../../domain/calculos/calculo_manutencao.dart';
import '../../domain/categoria_manutencao.dart';
import '../../domain/forma_pagamento.dart';
import '../../domain/registro_energia.dart';
import '../../domain/servico.dart';
import '../comum/campo_pagamento.dart';
import '../comum/saida_com_rascunho.dart';
import '../postos/lugares_view.dart';
import '../postos/postos_view.dart';
import 'icones_manutencao.dart';
import '../comum/campo_com_rotulo.dart';

class NovaManutencaoView extends ConsumerStatefulWidget {
  const NovaManutencaoView({super.key, this.servicoId});

  final String? servicoId;

  @override
  ConsumerState<NovaManutencaoView> createState() => _NovaManutencaoViewState();
}

class _NovaManutencaoViewState extends ConsumerState<NovaManutencaoView> with SaidaComRascunho<NovaManutencaoView> {
  static const _passos = ['O que foi feito?', 'Detalhes', 'Quando e onde?', 'Quanto custou?'];

  final _busca = TextEditingController();
  final _odometro = TextEditingController();
  final _oficina = TextEditingController();
  final _total = TextEditingController();
  final _pecas = TextEditingController();
  final _maoDeObra = TextEditingController();
  final _observacao = TextEditingController();
  final _textos = <String, TextEditingController>{};
  final _categorias = <CategoriaManutencao>[];
  final _detalhes = <String, Map<String, dynamic>>{};
  var _passo = 0;
  var _data = DateUtils.dateOnly(DateTime.now());
  var _versaoCalendario = 0;
  String? _oficinaId;
  FormaPagamento? _forma;
  String? _cartaoId;
  String? _erroValor;
  var _salvando = false;
  Servico? _original;
  final _sugestoes = <String, IntervaloSugerido?>{};
  final _consultando = <String>{};

  bool get _editando => widget.servicoId != null;

  @override
  String get tipoRascunho => 'manutencao';

  @override
  String get nomeDoRegistro => 'manutenção';

  @override
  bool get editandoRegistro => _editando;

  @override
  String? get veiculoIdRascunho => ref.read(veiculoAtivoProvider).value?.id;

  @override
  void initState() {
    super.initState();
    _total.addListener(() {
      if (_erroValor != null) setState(() => _erroValor = null);
    });
    if (_editando) {
      _carregar();
    } else {
      _carregarPagamentoPadrao();
      WidgetsBinding.instance.addPostFrameCallback((_) => verificarRascunho());
    }
  }

  @override
  void dispose() {
    for (final controle in [_busca, _odometro, _oficina, _total, _pecas, _maoDeObra, _observacao, ..._textos.values]) {
      controle.dispose();
    }
    super.dispose();
  }

  Future<void> _carregarPagamentoPadrao() async {
    final preferencias = ref.read(preferenciasRepositorioProvider);
    final salvo = await preferencias.pagamentoPadrao() ?? await preferencias.ultimoPagamento();
    if (salvo == null || !mounted || _forma != null) return;
    final partes = salvo.split('|');
    final forma = FormaPagamento.values.where((f) => f.name == partes.first).firstOrNull;
    setState(() {
      _forma = forma;
      _cartaoId = forma == FormaPagamento.credito && partes.length > 1 && partes[1].isNotEmpty ? partes[1] : null;
    });
  }

  Future<void> _carregar() async {
    final servico = await ref.read(servicoRepositorioProvider).obter(widget.servicoId!);
    if (servico == null || !mounted) return;
    _original = servico;
    aplicarRascunho({
      'categorias': servico.categorias,
      'detalhes': servico.detalhes,
      'data': servico.data.toIso8601String(),
      'odometro': servico.odometro == null ? '' : '${servico.odometro}',
      'oficina': servico.lugarNome ?? '',
      'oficinaId': servico.lugarId,
      'total': Formato.paraCampo(servico.valorCentavos / 100),
      'pecas': servico.pecasCentavos == null ? '' : Formato.paraCampo(servico.pecasCentavos! / 100),
      'maoDeObra': servico.maoDeObraCentavos == null ? '' : Formato.paraCampo(servico.maoDeObraCentavos! / 100),
      'forma': servico.formaPagamento?.name,
      'cartaoId': servico.cartaoId,
      'observacao': servico.observacao ?? '',
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => registrarEstadoDaEdicao());
  }

  TextEditingController _texto(CategoriaManutencao categoria, String chave) =>
      _textos.putIfAbsent('${categoria.name}.$chave', () {
        final valor = _detalhes[categoria.name]?[chave];
        return TextEditingController(text: valor == null ? '' : '$valor')..addListener(
          () =>
              _detalhes.putIfAbsent(categoria.name, () => {})[chave] = _textos['${categoria.name}.$chave']!.text.trim(),
        );
      });

  Map<String, dynamic> _detalhesLimpos() => {
    for (final categoria in _categorias)
      categoria.name: {
        for (final entrada in (_detalhes[categoria.name] ?? const <String, dynamic>{}).entries)
          if (entrada.key != 'intervaloEditado' &&
              entrada.value != null &&
              entrada.value != '' &&
              !(entrada.value is List && (entrada.value as List).isEmpty))
            entrada.key: entrada.value,
      },
  }..removeWhere((_, valor) => valor.isEmpty);

  @override
  Map<String, dynamic> dadosDoFormulario() => {
    'categorias': [for (final c in _categorias) c.name],
    'detalhes': _detalhesLimpos(),
    'data': _data.toIso8601String(),
    'odometro': _odometro.text,
    'oficina': _oficina.text,
    'oficinaId': _oficinaId,
    'total': _total.text,
    'pecas': _pecas.text,
    'maoDeObra': _maoDeObra.text,
    'forma': _forma?.name,
    'cartaoId': _cartaoId,
    'observacao': _observacao.text,
  };

  @override
  List<String> camposPreenchidos() => [
    if (_categorias.isNotEmpty) 'Serviços',
    if (_odometro.text.trim().isNotEmpty) 'Hodômetro',
    if (_oficina.text.trim().isNotEmpty) 'Oficina',
    if (_total.text.trim().isNotEmpty) 'Valor',
  ];

  @override
  void aplicarRascunho(Map<String, dynamic> dados) {
    setState(() {
      _categorias
        ..clear()
        ..addAll([
          for (final nome in (dados['categorias'] as List? ?? const []).cast<String>())
            ?CategoriaManutencao.porNome(nome),
        ]);
      _detalhes
        ..clear()
        ..addAll({
          for (final entrada in ((dados['detalhes'] as Map?) ?? const {}).entries)
            entrada.key as String: Map<String, dynamic>.from(entrada.value as Map),
        });
      for (final controle in _textos.values) {
        controle.dispose();
      }
      _textos.clear();
      _data = DateUtils.dateOnly(DateTime.tryParse(dados['data'] as String? ?? '') ?? _data);
      _versaoCalendario++;
      _oficinaId = dados['oficinaId'] as String?;
      _forma = FormaPagamento.values.where((f) => f.name == dados['forma']).firstOrNull;
      _cartaoId = dados['cartaoId'] as String?;
    });
    _odometro.text = dados['odometro'] as String? ?? '';
    _oficina.text = dados['oficina'] as String? ?? '';
    _total.text = dados['total'] as String? ?? '';
    _pecas.text = dados['pecas'] as String? ?? '';
    _maoDeObra.text = dados['maoDeObra'] as String? ?? '';
    _observacao.text = dados['observacao'] as String? ?? '';
  }

  @override
  bool tratarVoltar() {
    if (_passo == 0) return false;
    setState(() => _passo--);
    return true;
  }

  void _avancar() {
    FocusScope.of(context).unfocus();
    if (_passo == 0 && _categorias.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escolha pelo menos um serviço.')));
      return;
    }
    if (_passo < _passos.length - 1) {
      setState(() => _passo++);
      if (_passo == 1) _buscarIntervalos();
    } else {
      _salvar();
    }
  }

  String? _detalheDaSugestao(CategoriaManutencao categoria) =>
      categoria == CategoriaManutencao.oleo ? (_detalhes['oleo']?['tipo'] as String?) : null;

  String _chaveSugestao(CategoriaManutencao categoria) => '${categoria.name}:${_detalheDaSugestao(categoria) ?? '-'}';

  void _buscarIntervalos() {
    for (final categoria in _categorias.where((c) => c.temLembrete)) {
      _buscarIntervalo(categoria);
    }
  }

  Future<void> _buscarIntervalo(CategoriaManutencao categoria) async {
    final veiculo = ref.read(veiculoAtivoProvider).value;
    final chave = _chaveSugestao(categoria);
    if (veiculo == null || _sugestoes.containsKey(chave) || _consultando.contains(chave)) return;
    setState(() => _consultando.add(chave));
    IntervaloSugerido? sugestao;
    try {
      sugestao = await ref
          .read(clienteIaProvider)
          .estimarIntervalo(
            tipoVeiculo: veiculo.tipoVeiculo,
            marca: veiculo.marca,
            modelo: veiculo.modelo,
            ano: veiculo.ano,
            codigoFipe: veiculo.codigoFipe,
            tipoEnergia: veiculo.tipoEnergia,
            servico: categoria.rotulo,
            detalhe: _detalheDaSugestao(categoria),
          );
    } on ErroIa {
      sugestao = null;
    }
    if (!mounted) return;
    setState(() {
      _consultando.remove(chave);
      _sugestoes[chave] = sugestao;
    });
    final valores = _detalhes[categoria.name];
    final semValores = '${valores?['intervaloKm'] ?? ''}${valores?['intervaloMeses'] ?? ''}'.isEmpty;
    if (_chaveSugestao(categoria) == chave && (valores?['intervaloEditado'] == false || semValores)) {
      _aplicarIntervalo(categoria, severo: valores?['usoSevero'] as bool? ?? false);
    }
  }

  void _aplicarIntervalo(CategoriaManutencao categoria, {required bool severo}) {
    final sugestao = _sugestoes[_chaveSugestao(categoria)];
    final km = severo ? (sugestao?.kmSevero ?? sugestao?.km) : sugestao?.km;
    final meses = severo ? (sugestao?.mesesSevero ?? sugestao?.meses) : sugestao?.meses;
    final usarPadrao = sugestao == null;
    final valorKm = usarPadrao ? categoria.intervaloKm : km;
    final valorMeses = usarPadrao ? categoria.intervaloMeses : meses;
    _detalhes.putIfAbsent(categoria.name, () => {})['usoSevero'] = severo;
    _texto(categoria, 'intervaloKm').text = valorKm == null ? '' : '$valorKm';
    _texto(categoria, 'intervaloMeses').text = valorMeses == null ? '' : '$valorMeses';
    _detalhes[categoria.name]!['intervaloEditado'] = false;
    setState(() {});
  }

  Future<void> _escolherOficina() async {
    final veiculo = ref.read(veiculoAtivoProvider).value;
    final escolhido = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<PostoProximo>(
        builder: (contexto) => LugaresView(
          tipoInicial: TipoPosto.oficina,
          tiposPermitidos: const [TipoPosto.oficina],
          combustiveis: veiculo?.combustiveis ?? const [],
          aoEscolher: (lugar) => Navigator.of(contexto).pop(lugar),
          aoIrAte: (lugar) => abrirRota(contexto, lugar),
        ),
      ),
    );
    if (escolhido == null || !mounted) return;
    setState(() {
      _oficina.text = escolhido.nome;
      _oficinaId = escolhido.id;
    });
  }

  Future<void> _salvar() async {
    final veiculo = ref.read(veiculoAtivoProvider).value;
    if (veiculo == null) return;
    final pecas = Formato.lerDecimal(_pecas.text);
    final maoDeObra = Formato.lerDecimal(_maoDeObra.text);
    final total =
        Formato.lerDecimal(_total.text) ??
        (pecas == null && maoDeObra == null ? null : (pecas ?? 0) + (maoDeObra ?? 0));
    if (total == null || total <= 0) {
      setState(() => _erroValor = 'Informe quanto custou.');
      return;
    }
    if (_forma == FormaPagamento.credito && _cartaoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escolha o cartão de crédito usado.')));
      return;
    }
    setState(() => _salvando = true);
    final detalhes = _detalhesLimpos();
    await ref
        .read(servicoRepositorioProvider)
        .salvar(
          Servico(
            id: _original?.id ?? ref.read(geradorIdProvider)(),
            veiculoId: _original?.veiculoId ?? veiculo.id,
            tipo: TipoServico.manutencao,
            data: DateTime(_data.year, _data.month, _data.day, 12),
            odometro: Formato.lerInteiro(_odometro.text),
            categorias: [for (final c in _categorias) c.name],
            detalhes: detalhes,
            valorCentavos: (total * 100).round(),
            pecasCentavos: pecas == null ? null : (pecas * 100).round(),
            maoDeObraCentavos: maoDeObra == null ? null : (maoDeObra * 100).round(),
            lugarId: _oficina.text.trim().isEmpty ? null : _oficinaId,
            lugarNome: _oficina.text.trim().isEmpty ? null : _oficina.text.trim(),
            formaPagamento: _forma,
            cartaoId: _forma == FormaPagamento.credito ? _cartaoId : null,
            observacao: _observacao.text.trim().isEmpty ? null : _observacao.text.trim(),
          ),
        );
    await ref.read(preferenciasRepositorioProvider).definirUltimoPagamento('${_forma?.name ?? ''}|${_cartaoId ?? ''}');
    await apagarRascunhoSalvo();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_editando ? 'Manutenção atualizada.' : 'Manutenção salva.')));
    sairLiberado();
  }

  Future<void> _excluir() async {
    final confirmou = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (contexto) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Excluir esta manutenção?', style: Theme.of(contexto).textTheme.titleLarge),
              const SizedBox(height: 6),
              const Text('O gasto do mês e os lembretes serão recalculados sem ela.'),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: CoresBase.alerta),
                onPressed: () => Navigator.of(contexto).pop(true),
                child: const Text('Excluir'),
              ),
              TextButton(onPressed: () => Navigator.of(contexto).pop(false), child: const Text('Cancelar')),
            ],
          ),
        ),
      ),
    );
    if (confirmou != true || !mounted) return;
    await ref.read(servicoRepositorioProvider).excluir(widget.servicoId!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Manutenção excluída.')));
    sairLiberado();
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final corpo = switch (_passo) {
      0 => _passoServicos(),
      1 => _passoDetalhes(),
      2 => _passoQuandoOnde(),
      _ => _passoValor(),
    };
    final rotuloBotao = switch (_passo) {
      0 =>
        _categorias.isEmpty
            ? 'Escolha os serviços'
            : 'Continuar · ${_categorias.length} ${_categorias.length == 1 ? 'serviço' : 'serviços'}',
      3 => _editando ? 'Salvar alterações' : 'Salvar manutenção',
      _ => 'Continuar',
    };

    return envolverSaida(
      Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: _passo == 0 ? 'Fechar' : 'Voltar',
            icon: Icon(_passo == 0 ? Icons.close : Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(_editando ? 'Editar manutenção' : 'Nova manutenção'),
          actions: [
            if (_editando) IconButton(tooltip: 'Excluir', icon: const Icon(Icons.delete_outline), onPressed: _excluir),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: Text('${_passo + 1} de ${_passos.length}', style: textos.labelMedium)),
            ),
          ],
        ),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        for (var i = 0; i < _passos.length; i++) ...[
                          if (i > 0) const SizedBox(width: 4),
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 4,
                              decoration: BoxDecoration(
                                color: i <= _passo ? esquema.primary : esquema.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (rascunhoPendente != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AvisoRascunho(
                        rascunho: rascunhoPendente!,
                        aoContinuar: continuarRascunho,
                        aoDescartar: descartarRascunho,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(_passos[_passo], style: textos.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  Expanded(child: corpo),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: FilledButton(
                      onPressed: _salvando ? null : _avancar,
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      child: Text(rotuloBotao),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _passoServicos() {
    final veiculo = ref.watch(veiculoAtivoProvider).value;
    final esquema = Theme.of(context).colorScheme;
    final termo = _busca.text.trim().toLowerCase();
    final disponiveis = CategoriaManutencao.values
        .where((c) => veiculo == null || c.serveParaVeiculo(veiculo.tipoEnergia, veiculo.tipoVeiculo))
        .where((c) => termo.isEmpty || c.rotulo.toLowerCase().contains(termo) || _opcoesContem(c, termo))
        .toList();
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        TextField(
          controller: _busca,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Buscar serviço (ex.: pastilha, pintura)',
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.05,
          children: [
            for (final categoria in disponiveis)
              () {
                final marcada = _categorias.contains(categoria);
                return Material(
                  color: marcada ? esquema.primaryContainer : esquema.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: marcada ? esquema.primary : esquema.outlineVariant,
                      width: marcada ? 1.5 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => marcada ? _categorias.remove(categoria) : _categorias.add(categoria)),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(iconeDaCategoria(categoria), color: esquema.primary, size: 26),
                          const SizedBox(height: 6),
                          Text(
                            categoria.rotulo,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }(),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  static bool _opcoesContem(CategoriaManutencao categoria, String termo) =>
      categoria.campos.any((campo) => campo.opcoes.any((opcao) => opcao.toLowerCase().contains(termo)));

  Widget _passoDetalhes() {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        for (final categoria in _categorias) ...[
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(iconeDaCategoria(categoria), size: 20, color: esquema.primary),
                      const SizedBox(width: 8),
                      Text(categoria.rotulo, style: textos.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  for (final campo in categoria.campos) ...[const SizedBox(height: 10), _campo(categoria, campo)],
                  if (categoria.campos.isEmpty && !categoria.temLembrete)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 4),
                      child: Text(
                        'Sem detalhes para preencher. Use a observação no último passo, se quiser.',
                        style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant),
                      ),
                    ),
                  if (categoria.temLembrete) ...[
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Lembrar a próxima troca'),
                      value: _detalhes[categoria.name]?['lembrete'] as bool? ?? true,
                      onChanged: (valor) =>
                          setState(() => _detalhes.putIfAbsent(categoria.name, () => {})['lembrete'] = valor),
                    ),
                    if (_detalhes[categoria.name]?['lembrete'] as bool? ?? true) _intervalo(categoria),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _intervalo(CategoriaManutencao categoria) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final veiculo = ref.watch(veiculoAtivoProvider).value;
    final chave = _chaveSugestao(categoria);
    final consultando = _consultando.contains(chave);
    final consultado = _sugestoes.containsKey(chave);
    final sugestao = _sugestoes[chave];
    final severo = _detalhes[categoria.name]?['usoSevero'] as bool? ?? false;
    final nomeVeiculo = veiculo == null ? 'seu veículo' : '${veiculo.marca} ${veiculo.modelo}';

    String partes(int? km, int? meses) =>
        [if (km != null) Formato.km(km), if (meses != null) '$meses meses'].join(' ou ');

    final Widget origem;
    if (consultando) {
      origem = Row(
        children: [
          const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 8),
          Expanded(child: Text('Consultando o intervalo recomendado para $nomeVeiculo...', style: textos.bodySmall)),
        ],
      );
    } else if (sugestao != null) {
      origem = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 16, color: esquema.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Recomendado para $nomeVeiculo: ${partes(sugestao.km, sugestao.meses)}'
                  '${sugestao.kmSevero != null || sugestao.mesesSevero != null ? ' · uso severo: ${partes(sugestao.kmSevero, sugestao.mesesSevero)}' : ''}',
                  style: textos.bodySmall?.copyWith(color: esquema.primary),
                ),
              ),
            ],
          ),
          if (sugestao.observacao != null)
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 22),
              child: Text(sugestao.observacao!, style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant)),
            ),
        ],
      );
    } else {
      origem = Text(
        consultado
            ? 'Não consegui a recomendação para $nomeVeiculo. Usando a média geral: ${categoria.intervaloLegivel()}.'
            : 'Média geral: ${categoria.intervaloLegivel()}.',
        style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          origem,
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              ChoiceChip(
                label: const Text('Uso normal'),
                selected: !severo,
                onSelected: (_) => _aplicarIntervalo(categoria, severo: false),
              ),
              ChoiceChip(
                label: const Text('Uso severo'),
                tooltip: 'Trânsito para e anda, trajetos curtos, estrada de terra ou carro parado muito tempo',
                selected: severo,
                onSelected: (_) => _aplicarIntervalo(categoria, severo: true),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CampoComRotulo(
                  rotulo: 'A cada (km)',
                  child: TextField(
                    controller: _texto(categoria, 'intervaloKm'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => _detalhes.putIfAbsent(categoria.name, () => {})['intervaloEditado'] = true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CampoComRotulo(
                  rotulo: 'Ou a cada (meses)',
                  child: TextField(
                    controller: _texto(categoria, 'intervaloMeses'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => _detalhes.putIfAbsent(categoria.name, () => {})['intervaloEditado'] = true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _campo(CategoriaManutencao categoria, CampoDetalhe campo) {
    final textos = Theme.of(context).textTheme;
    final valores = _detalhes.putIfAbsent(categoria.name, () => {});
    return switch (campo.tipo) {
      TipoCampo.escolha || TipoCampo.multipla => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(campo.rotulo, style: textos.bodySmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final opcao in campo.opcoes)
                if (campo.tipo == TipoCampo.escolha)
                  ChoiceChip(
                    label: Text(opcao),
                    selected: valores[campo.chave] == opcao,
                    onSelected: (marcado) {
                      setState(() => valores[campo.chave] = marcado ? opcao : null);
                      if (categoria == CategoriaManutencao.oleo && campo.chave == 'tipo') _buscarIntervalo(categoria);
                    },
                  )
                else
                  FilterChip(
                    label: Text(opcao),
                    selected: ((valores[campo.chave] as List?) ?? const []).contains(opcao),
                    onSelected: (marcado) => setState(() {
                      final lista = List<String>.from((valores[campo.chave] as List?) ?? const []);
                      marcado ? lista.add(opcao) : lista.remove(opcao);
                      valores[campo.chave] = lista;
                    }),
                  ),
            ],
          ),
        ],
      ),
      TipoCampo.texto || TipoCampo.numero => CampoComRotulo(
        rotulo: campo.rotulo,
        child: TextField(
          controller: _texto(categoria, campo.chave),
          keyboardType: campo.tipo == TipoCampo.numero ? const TextInputType.numberWithOptions(decimal: true) : null,
          textCapitalization: TextCapitalization.words,
        ),
      ),
    };
  }

  Widget _passoQuandoOnde() {
    final hoje = DateUtils.dateOnly(DateTime.now());
    final veiculo = ref.watch(veiculoAtivoProvider).value;
    final registros = ref.watch(registrosDoAtivoProvider).value ?? const <RegistroEnergia>[];
    final manutencoes = ref.watch(manutencoesDoAtivoProvider).value ?? const <Servico>[];
    final ultimoKm = veiculo == null
        ? null
        : CalculoManutencao.odometroAtual(
            odometroInicial: veiculo.odometroInicial,
            registros: registros,
            servicos: manutencoes,
          );
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
            child: Column(
              children: [
                CalendarDatePicker(
                  key: ValueKey(_versaoCalendario),
                  initialDate: _data.isAfter(hoje) ? hoje : _data,
                  firstDate: DateTime(2000),
                  lastDate: hoje,
                  onDateChanged: (data) => setState(() => _data = data),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final (dias, rotulo) in [(0, 'Hoje'), (1, 'Ontem')])
                      ChoiceChip(
                        label: Text(rotulo),
                        selected: _data == hoje.subtract(Duration(days: dias)),
                        onSelected: (_) => setState(() {
                          _data = hoje.subtract(Duration(days: dias));
                          _versaoCalendario++;
                        }),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        CampoComRotulo(
          rotulo: 'Hodômetro (km)',
          child: TextField(
            controller: _odometro,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              helperText: ultimoKm == null ? 'Opcional' : 'Opcional · último registrado: ${Formato.km(ultimoKm)}',
            ),
          ),
        ),
        const SizedBox(height: 12),
        CampoComRotulo(
          rotulo: 'Oficina (opcional)',
          child: TextField(
            controller: _oficina,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) {
              if (_oficinaId != null) setState(() => _oficinaId = null);
            },
            decoration: InputDecoration(
              hintText: 'Toque no mapa para ver as oficinas perto',
              suffixIcon: IconButton(
                tooltip: 'Oficinas perto de mim',
                icon: Icon(_oficinaId == null ? Icons.map_outlined : Icons.where_to_vote),
                onPressed: _escolherOficina,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _passoValor() {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final resumo = [
      [for (final c in _categorias) c.rotulo].join(', '),
      [
        Formato.dataCurta(_data),
        if (_odometro.text.isNotEmpty) '${_odometro.text} km',
        if (_oficina.text.isNotEmpty) _oficina.text,
      ].join(' · '),
    ];
    final lembretes = [
      for (final c in _categorias)
        if (c.temLembrete && (_detalhes[c.name]?['lembrete'] as bool? ?? true)) c.rotulo,
    ];
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        CampoComRotulo(
          rotulo: 'Valor total (R\$)',
          child: TextField(
            controller: _total,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: textos.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            decoration: InputDecoration(errorText: _erroValor),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CampoComRotulo(
                rotulo: 'Peças (opcional)',
                child: TextField(
                  controller: _pecas,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CampoComRotulo(
                rotulo: 'Mão de obra (opcional)',
                child: TextField(
                  controller: _maoDeObra,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CampoPagamento(
          forma: _forma,
          cartaoId: _cartaoId,
          aoMudar: (forma, cartaoId) => setState(() {
            _forma = forma;
            _cartaoId = cartaoId;
          }),
        ),
        const SizedBox(height: 12),
        CampoComRotulo(
          rotulo: 'Observação (opcional)',
          child: TextField(controller: _observacao, maxLines: 2, textCapitalization: TextCapitalization.sentences),
        ),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Resumo', style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant)),
                const SizedBox(height: 4),
                for (final linha in resumo) Text(linha, style: textos.bodyMedium),
                if (lembretes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Vou lembrar: ${lembretes.join(', ')}',
                    style: textos.bodyMedium?.copyWith(color: esquema.primary),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
