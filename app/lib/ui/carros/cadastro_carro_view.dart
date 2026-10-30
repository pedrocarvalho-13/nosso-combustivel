import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formato.dart';
import '../../data/fipe/fipe_cliente.dart';
import '../../domain/calculos/identificacao_energia.dart';
import '../../core/tema/cores_base.dart';
import '../../domain/tipo_veiculo.dart';
import '../../domain/veiculo.dart';
import '../comum/campo_com_rotulo.dart';
import '../comum/icone_energia.dart';
import 'cadastro_carro_view_model.dart';
import 'seletor_energia.dart';

class CadastroCarroView extends ConsumerStatefulWidget {
  const CadastroCarroView({super.key});

  @override
  ConsumerState<CadastroCarroView> createState() => _CadastroCarroViewState();
}

class _CadastroCarroViewState extends ConsumerState<CadastroCarroView> {
  final _apelido = TextEditingController();
  final _marca = TextEditingController();
  final _modelo = TextEditingController();
  final _ano = TextEditingController();
  final _tanque = TextEditingController();
  final _bateria = TextEditingController();
  var _capacidadeDaIa = false;
  final _odometro = TextEditingController();
  Map<CampoCadastro, String> _erros = const {};

  @override
  void initState() {
    super.initState();
    for (final (controle, campo) in [
      (_marca, CampoCadastro.marca),
      (_modelo, CampoCadastro.modelo),
      (_odometro, CampoCadastro.odometro),
    ]) {
      controle.addListener(() {
        if (_erros.containsKey(campo)) setState(() => _erros = {..._erros}..remove(campo));
      });
    }
  }

  @override
  void dispose() {
    for (final controle in [_apelido, _marca, _modelo, _ano, _tanque, _bateria, _odometro]) {
      controle.dispose();
    }
    super.dispose();
  }

  CadastroCarroViewModel get _vm => ref.read(cadastroCarroViewModelProvider.notifier);

  void _avisar(String mensagem) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));

  Future<void> _salvar() async {
    final erros = await _vm.salvar(
      apelido: _apelido.text,
      marcaManual: _marca.text,
      modeloManual: _modelo.text,
      anoManual: Formato.lerInteiro(_ano.text),
      tanqueL: Formato.lerDecimal(_tanque.text),
      bateriaKwh: Formato.lerDecimal(_bateria.text),
      odometro: Formato.lerInteiro(_odometro.text),
    );
    if (!mounted) return;
    setState(() => _erros = erros);
    if (erros[CampoCadastro.geral] != null) _avisar(erros[CampoCadastro.geral]!);
    if (erros.isNotEmpty) return;
    _avisar('Veículo salvo.');
    context.pop();
  }

  Future<void> _sugerirCapacidade({bool automatico = false}) async {
    final resultado = await _vm.sugerirCapacidade(
      marcaManual: _marca.text,
      modeloManual: _modelo.text,
      anoManual: Formato.lerInteiro(_ano.text),
    );
    if (!mounted) return;
    final capacidade = resultado.capacidade;
    if (capacidade == null) {
      if (!automatico) _avisar(resultado.erro ?? 'A IA não soube a capacidade deste veículo.');
      return;
    }
    var preencheu = false;
    if (capacidade.tanqueL != null && (!automatico || _tanque.text.isEmpty)) {
      _tanque.text = Formato.paraCampo(capacidade.tanqueL!, casas: capacidade.tanqueL! % 1 == 0 ? 0 : 1);
      preencheu = true;
    }
    if (capacidade.bateriaKwh != null && (!automatico || _bateria.text.isEmpty)) {
      _bateria.text = Formato.paraCampo(capacidade.bateriaKwh!, casas: 1);
      preencheu = true;
    }
    setState(() => _capacidadeDaIa = preencheu);
  }

  Future<void> _corrigirEnergia(EnergiaIdentificada atual) async {
    final escolhida = await mostrarSeletorEnergia(context, atual);
    if (escolhida != null) _vm.corrigirEnergia(escolhida);
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(cadastroCarroViewModelProvider);
    ref.listen(cadastroCarroViewModelProvider.select((e) => e.detalhe), (_, detalhe) {
      if (detalhe != null && _erros.containsKey(CampoCadastro.fipe)) {
        setState(() => _erros = {..._erros}..remove(CampoCadastro.fipe));
      }
      if (detalhe != null && _apelido.text.isEmpty) _apelido.text = 'Meu ${detalhe.modelo.split(' ').first}';
      if (detalhe != null) Future.microtask(() => _sugerirCapacidade(automatico: true));
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar veículo')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CampoComRotulo(
              rotulo: 'Tipo de veículo',
              child: SegmentedButton<TipoVeiculo>(
                segments: const [
                  ButtonSegment(
                    value: TipoVeiculo.carro,
                    icon: Icon(Icons.directions_car_outlined),
                    label: Text('Carro'),
                  ),
                  ButtonSegment(value: TipoVeiculo.moto, icon: Icon(Icons.two_wheeler), label: Text('Moto')),
                ],
                selected: {estado.tipoVeiculo},
                showSelectedIcon: false,
                onSelectionChanged: (selecao) => _vm.selecionarTipoVeiculo(selecao.first),
              ),
            ),
            const SizedBox(height: 16),
            if (estado.manual) ..._camposManuais() else ..._camposFipe(estado),
            if (estado.energia != null) ...[
              const SizedBox(height: 16),
              _ResumoEnergia(
                energia: estado.energia!,
                origem: estado.manual || estado.energiaCorrigida ? 'Informado por você' : 'Identificado pelo modelo',
                aoCorrigir: () => _corrigirEnergia(estado.energia!),
              ),
            ],
            const SizedBox(height: 16),
            CampoComRotulo(
              rotulo: 'Apelido',
              child: TextField(
                controller: _apelido,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: estado.tipoVeiculo == TipoVeiculo.moto ? 'Ex.: CG do dia a dia' : 'Ex.: Hilux do trabalho',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (estado.energia?.tipo.abastece ?? true)
                  Expanded(
                    child: CampoComRotulo(
                      rotulo: 'Tanque (litros)',
                      child: TextField(
                        controller: _tanque,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ),
                if ((estado.energia?.tipo.abastece ?? true) && (estado.energia?.tipo.recarrega ?? false))
                  const SizedBox(width: 12),
                if (estado.energia?.tipo.recarrega ?? false)
                  Expanded(
                    child: CampoComRotulo(
                      rotulo: 'Bateria (kWh)',
                      child: TextField(
                        controller: _bateria,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: estado.consultandoIa || estado.energia == null ? null : _sugerirCapacidade,
                  icon: estado.consultandoIa
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_awesome_outlined, size: 18),
                  label: Text(
                    estado.consultandoIa ? 'Procurando a capacidade...' : 'Não sei a capacidade, buscar com IA',
                  ),
                ),
                if (_capacidadeDaIa && !estado.consultandoIa)
                  Text(
                    'Sugerido pela IA. Confira se puder.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            CampoComRotulo(
              rotulo: 'Hodômetro atual (km)',
              child: TextField(
                controller: _odometro,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(errorText: _erros[CampoCadastro.odometro]),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _vm.alternarManual,
                child: Text(estado.manual ? 'Buscar na tabela FIPE' : 'Não achou o veículo? Cadastrar sem a FIPE'),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: estado.salvando ? null : _salvar,
              child: estado.salvando
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Salvar veículo'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _camposManuais() => [
    CampoComRotulo(
      rotulo: 'Marca',
      child: TextField(
        controller: _marca,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(errorText: _erros[CampoCadastro.marca]),
      ),
    ),
    const SizedBox(height: 12),
    CampoComRotulo(
      rotulo: 'Modelo',
      child: TextField(
        controller: _modelo,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(errorText: _erros[CampoCadastro.modelo]),
      ),
    ),
    const SizedBox(height: 12),
    CampoComRotulo(
      rotulo: 'Ano (opcional)',
      child: TextField(
        controller: _ano,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
      ),
    ),
  ];

  List<Widget> _camposFipe(CadastroCarroEstado estado) {
    return [
      ...estado.marcas.when(
        loading: () => [const LinearProgressIndicator()],
        error: (_, _) => [_AvisoFipe(aoTentarDeNovo: _vm.carregarMarcas)],
        data: (marcas) => [
          _ListaFipe(rotulo: 'Marca', opcoes: marcas, selecionada: estado.marca, aoSelecionar: _vm.selecionarMarca),
        ],
      ),
      if (estado.marca != null) ...[
        const SizedBox(height: 12),
        ...estado.modelos.when(
          loading: () => [const LinearProgressIndicator()],
          error: (_, _) => [_AvisoFipe(aoTentarDeNovo: () => _vm.selecionarMarca(estado.marca))],
          data: (modelos) => [
            _ListaFipe(
              key: ValueKey(estado.marca!.codigo),
              rotulo: 'Modelo',
              opcoes: modelos,
              selecionada: estado.modelo,
              aoSelecionar: _vm.selecionarModelo,
            ),
          ],
        ),
      ],
      if (estado.modelo != null) ...[
        const SizedBox(height: 12),
        const CampoComRotulo(rotulo: 'Ano e combustível', child: SizedBox.shrink()),
        ...estado.anos.when(
          loading: () => [const LinearProgressIndicator()],
          error: (_, _) => [_AvisoFipe(aoTentarDeNovo: () => _vm.selecionarModelo(estado.modelo))],
          data: (anos) => [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ano in anos)
                  ChoiceChip(
                    label: Text(ano.nome),
                    selected: estado.ano?.codigo == ano.codigo,
                    onSelected: (_) async {
                      final erro = await _vm.selecionarAno(ano);
                      if (erro != null && mounted) _avisar(erro);
                    },
                  ),
              ],
            ),
          ],
        ),
      ],
      if (estado.carregandoDetalhe) ...[const SizedBox(height: 12), const LinearProgressIndicator()],
      if (_erros[CampoCadastro.fipe] != null) ...[
        const SizedBox(height: 8),
        Text(_erros[CampoCadastro.fipe]!, style: const TextStyle(color: CoresBase.alerta, fontSize: 12)),
      ],
    ];
  }
}

class _ListaFipe extends StatelessWidget {
  const _ListaFipe({
    super.key,
    required this.rotulo,
    required this.opcoes,
    required this.selecionada,
    required this.aoSelecionar,
  });

  final String rotulo;
  final List<OpcaoFipe> opcoes;
  final OpcaoFipe? selecionada;
  final ValueChanged<OpcaoFipe?> aoSelecionar;

  @override
  Widget build(BuildContext context) {
    return CampoComRotulo(
      rotulo: rotulo,
      child: DropdownMenu<OpcaoFipe>(
        expandedInsets: EdgeInsets.zero,
        hintText: 'Digite para buscar',
        enableFilter: true,
        requestFocusOnTap: true,
        menuHeight: 320,
        initialSelection: selecionada,
        leadingIcon: const Icon(Icons.search),
        onSelected: aoSelecionar,
        dropdownMenuEntries: [for (final opcao in opcoes) DropdownMenuEntry(value: opcao, label: opcao.nome)],
      ),
    );
  }
}

class _AvisoFipe extends StatelessWidget {
  const _AvisoFipe({required this.aoTentarDeNovo});

  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_outlined),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Não foi possível consultar a FIPE. Verifique a internet ou cadastre sem a FIPE.'),
            ),
            TextButton(onPressed: aoTentarDeNovo, child: const Text('Tentar de novo')),
          ],
        ),
      ),
    );
  }
}

class _ResumoEnergia extends StatelessWidget {
  const _ResumoEnergia({required this.energia, required this.origem, required this.aoCorrigir});

  final EnergiaIdentificada energia;
  final String origem;
  final VoidCallback aoCorrigir;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Row(
          children: [
            IconeEnergia(icone: iconeDoTipo(energia.tipo), tipo: energia.tipo),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Veiculo.descreverEnergia(energia.tipo, energia.combustiveis),
                    style: textos.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    origem,
                    style: textos.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: aoCorrigir, child: const Text('Corrigir')),
          ],
        ),
      ),
    );
  }
}
