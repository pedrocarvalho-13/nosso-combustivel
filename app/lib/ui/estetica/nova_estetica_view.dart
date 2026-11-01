import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formato.dart';
import '../../data/postos/cliente_postos.dart';
import '../../data/provedores.dart';
import '../../domain/estetica.dart';
import '../../domain/forma_pagamento.dart';
import '../../domain/servico.dart';
import '../comum/campo_com_rotulo.dart';
import '../comum/campo_pagamento.dart';
import '../comum/saida_com_rascunho.dart';
import '../postos/lugares_view.dart';
import '../postos/postos_view.dart';
import 'estetica_view.dart';
import '../comum/formulario_registro.dart';

class NovaEsteticaView extends ConsumerStatefulWidget {
  const NovaEsteticaView({super.key, this.servicoId});

  final String? servicoId;

  @override
  ConsumerState<NovaEsteticaView> createState() => _NovaEsteticaViewState();
}

class _NovaEsteticaViewState extends ConsumerState<NovaEsteticaView> with SaidaComRascunho<NovaEsteticaView> {
  final _lugar = TextEditingController();
  final _total = TextEditingController();
  final _observacao = TextEditingController();
  final _valoresProdutos = <String, TextEditingController>{};
  final _selecionados = <String>[];
  final _produtosUsados = <String>{};
  var _modalidade = ModalidadeEstetica.estetica;
  var _passo = 0;
  var _data = DateUtils.dateOnly(DateTime.now());
  var _versaoCalendario = 0;
  var _planoMensal = false;
  var _lembreteDias = CalculoEstetica.intervaloPadraoDias;
  String? _lugarId;
  FormaPagamento? _forma;
  String? _cartaoId;
  var _parcelas = 1;
  String? _erroValor;
  var _salvando = false;
  Servico? _original;

  bool get _editando => widget.servicoId != null;

  List<String> get _passos => switch (_modalidade) {
        ModalidadeEstetica.estetica => ['O que você fez?', 'Quais serviços?', 'Quando e onde?', 'Quanto custou?'],
        ModalidadeEstetica.casa => ['O que você fez?', 'O que você lavou?', 'Quando?'],
        ModalidadeEstetica.produtos => ['O que você fez?', 'O que você comprou?', 'Quando e como pagou?'],
      };

  @override
  String get tipoRascunho => 'estetica';

  @override
  String get nomeDoRegistro => 'estética';

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
      _carregarPadroes();
      WidgetsBinding.instance.addPostFrameCallback((_) => verificarRascunho());
    }
  }

  @override
  void dispose() {
    for (final controle in [_lugar, _total, _observacao, ..._valoresProdutos.values]) {
      controle.dispose();
    }
    super.dispose();
  }

  Future<void> _carregarPadroes() async {
    final esteticas = await ref.read(esteticasDoAtivoProvider.future);
    final ultima = esteticas.where((s) => ModalidadeEstetica.de(s) != ModalidadeEstetica.produtos).firstOrNull;
    final preferencias = ref.read(preferenciasRepositorioProvider);
    final salvo = await preferencias.pagamentoPadrao() ?? await preferencias.ultimoPagamento();
    if (!mounted) return;
    setState(() {
      if (ultima != null) {
        _modalidade = ModalidadeEstetica.de(ultima);
        _lembreteDias = (ultima.detalhes['lembreteDias'] as num?)?.toInt() ?? _lembreteDias;
      }
      if (salvo != null && _forma == null) {
        final partes = salvo.split('|');
        _forma = FormaPagamento.values.where((f) => f.name == partes.first).firstOrNull;
        _cartaoId = _forma == FormaPagamento.credito && partes.length > 1 && partes[1].isNotEmpty ? partes[1] : null;
      }
    });
  }

  Future<void> _carregar() async {
    final servico = await ref.read(servicoRepositorioProvider).obter(widget.servicoId!);
    if (servico == null || !mounted) return;
    _original = servico;
    final produtos = (servico.detalhes['produtos'] as Map?)?.cast<String, dynamic>() ?? const {};
    aplicarRascunho({
      ...dadosDoFormulario(),
      'modalidade': ModalidadeEstetica.de(servico).name,
      'selecionados': servico.categorias,
      'data': servico.data.toIso8601String(),
      'lugar': servico.lugarNome ?? '',
      'lugarId': servico.lugarId,
      'total': ModalidadeEstetica.de(servico) == ModalidadeEstetica.estetica && servico.valorCentavos > 0
          ? Formato.paraCampo(servico.valorCentavos / 100)
          : '',
      'planoMensal': servico.detalhes['planoMensal'] == true,
      'lembreteDias': (servico.detalhes['lembreteDias'] as num?)?.toInt() ?? _lembreteDias,
      'produtos': {
        for (final entrada in produtos.entries) entrada.key: Formato.paraCampo((entrada.value as num) / 100),
      },
      'produtosUsados': (servico.detalhes['produtosUsados'] as List?) ?? const [],
      'forma': servico.formaPagamento?.name,
      'cartaoId': servico.cartaoId,
      'parcelas': servico.parcelas,
      'observacao': servico.observacao ?? '',
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => registrarEstadoDaEdicao());
  }

  TextEditingController _valorDoProduto(String nome) => _valoresProdutos.putIfAbsent(nome, TextEditingController.new);

  int get _totalProdutosCentavos => _selecionados.fold(
        0,
        (soma, nome) => soma + ((Formato.lerDecimal(_valoresProdutos[nome]?.text ?? '') ?? 0) * 100).round(),
      );

  @override
  Map<String, dynamic> dadosDoFormulario() => {
        'modalidade': _modalidade.name,
        'selecionados': [..._selecionados],
        'data': _data.toIso8601String(),
        'lugar': _lugar.text,
        'lugarId': _lugarId,
        'total': _total.text,
        'planoMensal': _planoMensal,
        'lembreteDias': _lembreteDias,
        'produtos': {for (final nome in _selecionados) nome: _valoresProdutos[nome]?.text ?? ''},
        'produtosUsados': [..._produtosUsados],
        'forma': _forma?.name,
        'cartaoId': _cartaoId,
        'parcelas': _parcelas,
        'observacao': _observacao.text,
      };

  @override
  List<String> camposPreenchidos() => [
        if (_selecionados.isNotEmpty) _modalidade == ModalidadeEstetica.produtos ? 'Produtos' : 'Serviços',
        if (_lugar.text.trim().isNotEmpty) 'Lugar',
        if (_total.text.trim().isNotEmpty) 'Valor',
      ];

  @override
  void aplicarRascunho(Map<String, dynamic> dados) {
    setState(() {
      _modalidade = ModalidadeEstetica.values.where((m) => m.name == dados['modalidade']).firstOrNull ?? _modalidade;
      _selecionados
        ..clear()
        ..addAll((dados['selecionados'] as List? ?? const []).cast<String>());
      _data = DateUtils.dateOnly(DateTime.tryParse(dados['data'] as String? ?? '') ?? _data);
      _versaoCalendario++;
      _lugarId = dados['lugarId'] as String?;
      _planoMensal = dados['planoMensal'] as bool? ?? false;
      _lembreteDias = (dados['lembreteDias'] as num?)?.toInt() ?? _lembreteDias;
      _produtosUsados
        ..clear()
        ..addAll((dados['produtosUsados'] as List? ?? const []).cast<String>());
      _forma = FormaPagamento.values.where((f) => f.name == dados['forma']).firstOrNull;
      _cartaoId = dados['cartaoId'] as String?;
      _parcelas = (dados['parcelas'] as num?)?.toInt() ?? 1;
    });
    _lugar.text = dados['lugar'] as String? ?? '';
    _total.text = dados['total'] as String? ?? '';
    _observacao.text = dados['observacao'] as String? ?? '';
    for (final entrada in ((dados['produtos'] as Map?) ?? const {}).entries) {
      _valorDoProduto(entrada.key as String).text = '${entrada.value}';
    }
  }

  @override
  bool tratarVoltar() {
    if (_passo == 0) return false;
    setState(() => _passo--);
    return true;
  }

  void _avancar() {
    FocusScope.of(context).unfocus();
    if (_passo == 1 && _selecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_modalidade == ModalidadeEstetica.produtos ? 'Escolha o que você comprou.' : 'Escolha pelo menos um serviço.'),
      ));
      return;
    }
    if (_passo < _passos.length - 1) {
      setState(() => _passo++);
    } else {
      _salvar();
    }
  }

  Future<void> _escolherEstetica() async {
    final veiculo = ref.read(veiculoAtivoProvider).value;
    final escolhido = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<PostoProximo>(
        builder: (contexto) => LugaresView(
          tipoInicial: TipoPosto.estetica,
          tiposPermitidos: const [TipoPosto.estetica],
          combustiveis: veiculo?.combustiveis ?? const [],
          aoEscolher: (lugar) => Navigator.of(contexto).pop(lugar),
          aoIrAte: (lugar) => abrirRota(contexto, lugar),
        ),
      ),
    );
    if (escolhido == null || !mounted) return;
    setState(() {
      _lugar.text = escolhido.nome;
      _lugarId = escolhido.id;
    });
  }

  Future<void> _salvar() async {
    final veiculo = ref.read(veiculoAtivoProvider).value;
    if (veiculo == null) return;
    final valorCentavos = switch (_modalidade) {
      ModalidadeEstetica.estetica => _planoMensal ? 0 : ((Formato.lerDecimal(_total.text) ?? 0) * 100).round(),
      ModalidadeEstetica.casa => 0,
      ModalidadeEstetica.produtos => _totalProdutosCentavos,
    };
    if (_modalidade != ModalidadeEstetica.casa && !(_modalidade == ModalidadeEstetica.estetica && _planoMensal) && valorCentavos <= 0) {
      setState(() => _erroValor = 'Informe quanto custou.');
      if (_modalidade == ModalidadeEstetica.produtos) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o valor de pelo menos um produto.')));
      }
      return;
    }
    final pagou = valorCentavos > 0;
    if (pagou && _forma == FormaPagamento.credito && _cartaoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escolha o cartão de crédito usado.')));
      return;
    }
    setState(() => _salvando = true);
    final detalhes = <String, dynamic>{
      'modalidade': _modalidade.name,
      if (_modalidade != ModalidadeEstetica.produtos) 'lembreteDias': _lembreteDias,
      if (_modalidade == ModalidadeEstetica.estetica && _planoMensal) 'planoMensal': true,
      if (_modalidade == ModalidadeEstetica.produtos)
        'produtos': {
          for (final nome in _selecionados)
            nome: ((Formato.lerDecimal(_valoresProdutos[nome]?.text ?? '') ?? 0) * 100).round(),
        },
      if (_modalidade == ModalidadeEstetica.casa && _produtosUsados.isNotEmpty) 'produtosUsados': [..._produtosUsados],
      if (valorCentavos > 0 && _forma == FormaPagamento.credito && _parcelas > 1) 'parcelas': _parcelas,
    };
    final temLugar = _modalidade != ModalidadeEstetica.casa && _lugar.text.trim().isNotEmpty;
    await ref.read(servicoRepositorioProvider).salvar(Servico(
          id: _original?.id ?? ref.read(geradorIdProvider)(),
          veiculoId: _original?.veiculoId ?? veiculo.id,
          tipo: TipoServico.estetica,
          data: DateTime(_data.year, _data.month, _data.day, 12),
          categorias: [..._selecionados],
          detalhes: detalhes,
          valorCentavos: valorCentavos,
          lugarId: temLugar ? _lugarId : null,
          lugarNome: temLugar ? _lugar.text.trim() : null,
          formaPagamento: pagou ? _forma : null,
          cartaoId: pagou && _forma == FormaPagamento.credito ? _cartaoId : null,
          observacao: _observacao.text.trim().isEmpty ? null : _observacao.text.trim(),
        ));
    if (pagou) {
      await ref.read(preferenciasRepositorioProvider).definirUltimoPagamento('${_forma?.name ?? ''}|${_cartaoId ?? ''}');
    }
    await apagarRascunhoSalvo();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_editando ? 'Registro atualizado.' : 'Registro salvo.')));
    sairLiberado();
  }

  Future<void> _excluir() async {
    final confirmou = await confirmarExclusao(
      context,
      titulo: 'Excluir este registro?',
      mensagem: 'O gasto do mês e a contagem de lavagens serão recalculados sem ele.',
    );
    if (!confirmou || !mounted) return;
    final repositorio = ref.read(servicoRepositorioProvider);
    final id = widget.servicoId!;
    await repositorio.excluir(id);
    if (!mounted) return;
    avisarExclusao(context, 'Registro excluído.', () => repositorio.restaurar(id));
    sairLiberado();
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final passos = _passos;
    final ultimo = _passo == passos.length - 1;
    final corpo = switch ((_passo, _modalidade)) {
      (0, _) => _passoModalidade(),
      (1, ModalidadeEstetica.produtos) => _passoProdutos(),
      (1, _) => _passoServicos(),
      (2, ModalidadeEstetica.estetica) => _passoQuandoOnde(),
      (2, ModalidadeEstetica.casa) => _passoQuandoCasa(),
      (2, ModalidadeEstetica.produtos) => _passoCompra(),
      _ => _passoValor(),
    };
    final rotuloBotao = ultimo
        ? (_editando ? 'Salvar alterações' : 'Salvar')
        : _passo == 1 && _selecionados.isNotEmpty
            ? 'Continuar · ${_selecionados.length} ${_modalidade == ModalidadeEstetica.produtos ? (_selecionados.length == 1 ? 'produto' : 'produtos') : (_selecionados.length == 1 ? 'serviço' : 'serviços')}'
            : 'Continuar';

    return envolverSaida(Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: _passo == 0 ? 'Fechar' : 'Voltar',
          icon: Icon(_passo == 0 ? Icons.close : Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(_editando ? 'Editar estética' : 'Nova estética'),
        actions: [
          if (_editando) IconButton(tooltip: 'Excluir', icon: const Icon(Icons.delete_outline), onPressed: _excluir),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('${_passo + 1} de ${passos.length}', style: textos.labelMedium)),
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
                      for (var i = 0; i < passos.length; i++) ...[
                        if (i > 0) const SizedBox(width: 4),
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 4,
                            decoration: BoxDecoration(
                              color: i <= _passo ? corEstetica : esquema.surfaceContainerHighest,
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
                  child: Text(passos[_passo], style: textos.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
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
    ));
  }

  Widget _passoModalidade() {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        for (final modalidade in ModalidadeEstetica.values) ...[
          Material(
            color: _modalidade == modalidade ? corEstetica.withValues(alpha: 0.14) : esquema.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: _modalidade == modalidade ? corEstetica : esquema.outlineVariant,
                width: _modalidade == modalidade ? 1.5 : 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() {
                if (_modalidade != modalidade) _selecionados.clear();
                _modalidade = modalidade;
              }),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: corEstetica.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(iconeDaModalidade(modalidade), color: corEstetica),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(modalidade.rotulo, style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          Text(modalidade.descricao, style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _grade(List<(String, String, IconData)> opcoes) {
    final esquema = Theme.of(context).colorScheme;
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.05,
      children: [
        for (final (nome, rotulo, icone) in opcoes)
          () {
            final marcado = _selecionados.contains(nome);
            return Material(
              color: marcado ? corEstetica.withValues(alpha: 0.14) : esquema.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: marcado ? corEstetica : esquema.outlineVariant, width: marcado ? 1.5 : 1),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() => marcado ? _selecionados.remove(nome) : _selecionados.add(nome)),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icone, color: corEstetica, size: 26),
                      const SizedBox(height: 6),
                      Text(
                        rotulo,
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
    );
  }

  Widget _passoServicos() {
    final opcoes = _modalidade == ModalidadeEstetica.estetica
        ? [
            for (final s in ServicoEstetica.values)
              (
                s.name,
                s.rotulo,
                switch (s) {
                  ServicoEstetica.lavagemSimples => Icons.water_drop_outlined,
                  ServicoEstetica.lavagemCompleta => Icons.local_car_wash_outlined,
                  ServicoEstetica.lavagemASeco => Icons.air,
                  ServicoEstetica.higienizacao => Icons.event_seat_outlined,
                  ServicoEstetica.limpezaMotor => Icons.settings_outlined,
                  ServicoEstetica.enceramento => Icons.brush_outlined,
                  ServicoEstetica.polimento => Icons.auto_awesome_outlined,
                  ServicoEstetica.vitrificacao => Icons.diamond_outlined,
                  ServicoEstetica.oxiSanitizacao => Icons.coronavirus_outlined,
                },
              ),
          ]
        : [
            for (final p in ParteLavagem.values)
              (
                p.name,
                p.rotulo,
                switch (p) {
                  ParteLavagem.externa => Icons.local_car_wash_outlined,
                  ParteLavagem.interna => Icons.event_seat_outlined,
                  ParteLavagem.aspiracao => Icons.cleaning_services_outlined,
                  ParteLavagem.pretinho => Icons.tire_repair_outlined,
                  ParteLavagem.cera => Icons.brush_outlined,
                  ParteLavagem.vidros => Icons.window_outlined,
                  ParteLavagem.motor => Icons.settings_outlined,
                },
              ),
          ];
    return ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [_grade(opcoes), const SizedBox(height: 12)]);
  }

  Widget _passoProdutos() {
    final textos = Theme.of(context).textTheme;
    final opcoes = [
      for (final p in ProdutoEstetica.values)
        (
          p.name,
          p.rotulo,
          switch (p) {
            ProdutoEstetica.shampoo => Icons.sanitizer_outlined,
            ProdutoEstetica.cera => Icons.brush_outlined,
            ProdutoEstetica.pretinho => Icons.tire_repair_outlined,
            ProdutoEstetica.limpaVidro => Icons.window_outlined,
            ProdutoEstetica.panos => Icons.dry_cleaning_outlined,
            ProdutoEstetica.hidratante => Icons.opacity,
            ProdutoEstetica.aspirador => Icons.cleaning_services_outlined,
            ProdutoEstetica.outro => Icons.more_horiz,
          },
        ),
    ];
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _grade(opcoes),
        if (_selecionados.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Quanto custou cada um', style: textos.titleSmall),
          const SizedBox(height: 8),
          for (final nome in _selecionados) ...[
            CampoComRotulo(
              rotulo: ProdutoEstetica.values.firstWhere((p) => p.name == nome).rotulo,
              child: TextField(
                controller: _valorDoProduto(nome),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(prefixText: 'R\$ '),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text('Total: ${Formato.moeda(_totalProdutosCentavos)}', style: textos.titleMedium),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _calendario() {
    final hoje = DateUtils.dateOnly(DateTime.now());
    return Card(
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
    );
  }

  Widget _lembrete() {
    final textos = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lembrar de lavar de novo em', style: textos.bodySmall),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: [
            for (final dias in [7, 15, 20, 30])
              ChoiceChip(
                label: Text('$dias dias'),
                selected: _lembreteDias == dias,
                onSelected: (_) => setState(() => _lembreteDias = dias),
              ),
          ],
        ),
      ],
    );
  }

  Widget _passoQuandoOnde() => ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _calendario(),
          const SizedBox(height: 12),
          CampoComRotulo(
            rotulo: 'Estética (opcional)',
            child: TextField(
              controller: _lugar,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) {
                if (_lugarId != null) setState(() => _lugarId = null);
              },
              decoration: InputDecoration(
                hintText: 'Toque no mapa para ver as estéticas perto',
                suffixIcon: IconButton(
                  tooltip: 'Estéticas perto de mim',
                  icon: Icon(_lugarId == null ? Icons.map_outlined : Icons.where_to_vote),
                  onPressed: _escolherEstetica,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      );

  Widget _passoQuandoCasa() {
    final textos = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    final compras = (ref.watch(esteticasDoAtivoProvider).value ?? const <Servico>[])
        .where((s) => ModalidadeEstetica.de(s) == ModalidadeEstetica.produtos)
        .take(5)
        .toList();
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _calendario(),
        const SizedBox(height: 16),
        Text('Produtos que você usou', style: textos.bodySmall),
        const SizedBox(height: 6),
        if (compras.isEmpty)
          Text(
            'Registre uma compra de produtos para o app calcular quanto sai cada lavagem em casa.',
            style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final compra in compras)
                FilterChip(
                  label: Text(
                    '${CalculoEstetica.rotulos(compra).replaceFirst('Produtos: ', '')} · ${Formato.dataCurta(compra.data)}',
                  ),
                  selected: _produtosUsados.contains(compra.id),
                  onSelected: (marcado) =>
                      setState(() => marcado ? _produtosUsados.add(compra.id) : _produtosUsados.remove(compra.id)),
                ),
            ],
          ),
        const SizedBox(height: 16),
        _lembrete(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _passoCompra() => ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _calendario(),
          const SizedBox(height: 12),
          CampoComRotulo(
            rotulo: 'Onde comprou (opcional)',
            child: TextField(
              controller: _lugar,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'Loja, mercado, site...'),
            ),
          ),
          const SizedBox(height: 12),
          CampoPagamento(
            forma: _forma,
            cartaoId: _cartaoId,
            aoMudar: (forma, cartaoId) => setState(() {
              _forma = forma;
              _cartaoId = cartaoId;
            }),
          
            parcelas: _parcelas,
            aoMudarParcelas: (vezes) => setState(() => _parcelas = vezes),
            valorCentavos: _totalProdutosCentavos,
          ),
          const SizedBox(height: 8),
          Text(
            'Total: ${Formato.moeda(_totalProdutosCentavos)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
        ],
      );

  Widget _passoValor() {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final nomes = [
      for (final nome in _selecionados) ServicoEstetica.values.where((s) => s.name == nome).firstOrNull?.rotulo,
    ].whereType<String>();
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (!_planoMensal)
          CampoComRotulo(
            rotulo: 'Valor (R\$)',
            child: TextField(
              controller: _total,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: textos.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
              decoration: InputDecoration(errorText: _erroValor),
            ),
          ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Está no plano mensal'),
          subtitle: const Text('A lavagem fica sem custo; a mensalidade entra como outro custo'),
          value: _planoMensal,
          onChanged: (valor) => setState(() => _planoMensal = valor),
        ),
        if (!_planoMensal) ...[
          const SizedBox(height: 4),
          CampoPagamento(
            forma: _forma,
            cartaoId: _cartaoId,
            aoMudar: (forma, cartaoId) => setState(() {
              _forma = forma;
              _cartaoId = cartaoId;
            }),
          
            parcelas: _parcelas,
            aoMudarParcelas: (vezes) => setState(() => _parcelas = vezes),
            valorCentavos: ((Formato.lerDecimal(_total.text) ?? 0) * 100).round(),
          ),
        ],
        const SizedBox(height: 12),
        _lembrete(),
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
                Text(nomes.join(', '), style: textos.bodyMedium),
                Text(
                  [Formato.dataCurta(_data), if (_lugar.text.isNotEmpty) _lugar.text].join(' · '),
                  style: textos.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
