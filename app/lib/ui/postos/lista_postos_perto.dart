import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/formato.dart';
import '../../data/postos/cliente_postos.dart';
import '../../domain/combustivel.dart';
import '../../domain/horario_posto.dart';
import '../../domain/tipo_gasolina.dart';

class ListaPostosPerto extends ConsumerStatefulWidget {
  const ListaPostosPerto({
    super.key,
    required this.aoEscolher,
    this.tipo = TipoPosto.combustivel,
    this.combustivel,
    this.tipoGasolina,
    this.ocuparEspaco = false,
  });

  final void Function(PostoProximo posto) aoEscolher;
  final TipoPosto tipo;
  final Combustivel? combustivel;
  final TipoGasolina? tipoGasolina;
  final bool ocuparEspaco;

  @override
  ConsumerState<ListaPostosPerto> createState() => _ListaPostosPertoState();
}

class _ListaPostosPertoState extends ConsumerState<ListaPostosPerto> {
  Position? _posicao;
  PostosProximos? _resultado;
  String? _erro;
  var _carregando = true;
  var _cadastrando = false;
  var _raio = 1500;
  var _maisBarato = false;

  static const _raios = [1500, 3000, 5000];

  bool get _eletro => widget.tipo == TipoPosto.eletroposto;

  @override
  void initState() {
    super.initState();
    _buscar();
  }

  @override
  void didUpdateWidget(ListaPostosPerto anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.tipo != widget.tipo) {
      _maisBarato = false;
      _buscar();
    }
  }

  Future<void> _buscar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final posicao = _posicao ?? await _localizar();
      final resultado = await ref.read(clientePostosProvider).proximos(
            latitude: posicao.latitude,
            longitude: posicao.longitude,
            raioMetros: _raio,
            tipo: widget.tipo,
          );
      if (!mounted) return;
      setState(() {
        _posicao = posicao;
        _resultado = resultado;
      });
    } on ErroPostos catch (erro) {
      if (mounted) setState(() => _erro = erro.mensagem);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<Position> _localizar() async {
    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) permissao = await Geolocator.requestPermission();
    if (permissao == LocationPermission.denied || permissao == LocationPermission.deniedForever) {
      throw const ErroPostos('Permita o acesso à localização para ver os postos perto de você.');
    }
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
      );
    } catch (_) {
      throw const ErroPostos('Não deu para descobrir onde você está. Tente de novo.');
    }
  }

  Future<void> _cadastrar() async {
    final posicao = _posicao;
    if (posicao == null) return;
    final dados = await showModalBottomSheet<(String, String?)>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _DialogoNovoPosto(eletro: _eletro),
    );
    if (dados == null || !mounted) return;
    setState(() => _cadastrando = true);
    try {
      final posto = await ref.read(clientePostosProvider).cadastrar(
            nome: dados.$1,
            bandeira: dados.$2,
            latitude: posicao.latitude,
            longitude: posicao.longitude,
            tipo: widget.tipo,
          );
      if (!mounted) return;
      setState(() => _cadastrando = false);
      widget.aoEscolher(posto);
    } on ErroPostos catch (erro) {
      if (!mounted) return;
      setState(() => _cadastrando = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro.mensagem)));
    }
  }

  PrecoInformado? _preco(PostoProximo posto) =>
      _eletro ? null : posto.precoDe(widget.combustivel, tipoGasolina: widget.tipoGasolina);

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final combustivel = widget.combustivel;
    final postos = [...?_resultado?.postos];
    if (_maisBarato) {
      postos.sort((a, b) {
        final precoA = _preco(a)?.precoLitro ?? double.infinity;
        final precoB = _preco(b)?.precoLitro ?? double.infinity;
        return precoA != precoB ? precoA.compareTo(precoB) : a.distanciaMetros.compareTo(b.distanciaMetros);
      });
    }
    final algumPreco = postos.any((p) => _preco(p) != null);
    final nomeDoPreco = combustivel == Combustivel.gasolina
        ? 'gasolina ${(widget.tipoGasolina ?? TipoGasolina.comum).rotulo.toLowerCase()}'
        : combustivel?.rotulo.toLowerCase();

    final lista = ListView.builder(
      shrinkWrap: !widget.ocuparEspaco,
      itemCount: postos.length,
      itemBuilder: (context, indice) {
        final posto = postos[indice];
        final detalhes = [
          if (posto.bandeira != null && posto.bandeira != posto.nome) posto.bandeira!,
          if (posto.endereco != null) posto.endereco!,
        ].join(' · ');
        final horario = HorarioPosto.legivel(posto.horario);
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: Icon(_eletro ? Icons.ev_station_outlined : Icons.local_gas_station_outlined, color: esquema.primary),
          title: Text(posto.nome),
          subtitle: detalhes.isEmpty && horario == null
              ? null
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (detalhes.isNotEmpty) Text(detalhes, maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (horario != null)
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 13, color: esquema.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(child: Text(horario, maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                  ],
                ),
          trailing: _Lado(
            distancia: distanciaLegivel(posto.distanciaMetros),
            preco: _preco(posto),
            mostrarPreco: !_eletro,
          ),
          onTap: () => widget.aoEscolher(posto),
        );
      },
    );

    return Column(
      mainAxisSize: widget.ocuparEspaco ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final raio in _raios)
                ChoiceChip(
                  label: Text('Até ${distanciaLegivel(raio)}'),
                  selected: _raio == raio,
                  onSelected: _carregando || _raio == raio
                      ? null
                      : (_) {
                          setState(() => _raio = raio);
                          _buscar();
                        },
                ),
              if (algumPreco && nomeDoPreco != null)
                FilterChip(
                  avatar: const Icon(Icons.savings_outlined, size: 18),
                  label: Text('Mais barato ($nomeDoPreco)'),
                  selected: _maisBarato,
                  onSelected: (valor) => setState(() => _maisBarato = valor),
                ),
            ],
          ),
        ),
        if (_carregando)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(_eletro ? 'Procurando eletropostos...' : 'Procurando postos...'),
              ],
            ),
          )
        else if (_erro != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              children: [
                Text(_erro!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                OutlinedButton(onPressed: _buscar, child: const Text('Tentar de novo')),
              ],
            ),
          )
        else ...[
          if (_resultado?.buscaCompleta == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                'A busca está lenta agora. Mostrando só os que já conhecemos.',
                style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant),
              ),
            ),
          if (postos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Text(
                _eletro
                    ? 'Nenhum eletroposto encontrado neste raio. Tente um raio maior.'
                    : 'Nenhum posto encontrado neste raio. Tente um raio maior.',
                textAlign: TextAlign.center,
              ),
            )
          else if (widget.ocuparEspaco)
            Expanded(child: lista)
          else
            Flexible(child: lista),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: TextButton.icon(
              onPressed: _cadastrando ? null : _cadastrar,
              icon: const Icon(Icons.add_location_alt_outlined),
              label: Text(_eletro ? 'Não está na lista? Cadastrar este eletroposto' : 'Não está na lista? Cadastrar este posto'),
            ),
          ),
        ],
      ],
    );
  }
}

String distanciaLegivel(int metros) =>
    metros < 1000 ? '$metros m' : '${(metros / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';

class _DialogoNovoPosto extends StatefulWidget {
  const _DialogoNovoPosto({required this.eletro});

  final bool eletro;

  @override
  State<_DialogoNovoPosto> createState() => _DialogoNovoPostoState();
}

class _DialogoNovoPostoState extends State<_DialogoNovoPosto> {
  final _nome = TextEditingController();
  final _bandeira = TextEditingController();
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _bandeira.dispose();
    super.dispose();
  }

  void _confirmar() {
    final nome = _nome.text.trim();
    if (nome.isEmpty) return setState(() => _erro = 'Informe o nome.');
    final bandeira = _bandeira.text.trim();
    Navigator.of(context).pop((nome, bandeira.isEmpty ? null : bandeira));
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.eletro ? 'Cadastrar eletroposto' : 'Cadastrar posto',
              style: textos.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Ele fica salvo no lugar onde você está agora.',
              style: textos.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nome,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: widget.eletro ? 'Nome do eletroposto' : 'Nome do posto', errorText: _erro),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bandeira,
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _confirmar(),
              decoration: InputDecoration(
                labelText: widget.eletro ? 'Rede (opcional)' : 'Bandeira (opcional)',
                hintText: widget.eletro ? 'Shell Recharge, Zletric...' : 'Shell, Ipiranga, BR...',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _confirmar, child: const Text('Cadastrar')),
          ],
        ),
      ),
    );
  }
}

class _Lado extends StatelessWidget {
  const _Lado({required this.distancia, required this.mostrarPreco, this.preco});

  final String distancia;
  final bool mostrarPreco;
  final PrecoInformado? preco;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final preco = this.preco;
    if (!mostrarPreco) return Text(distancia, style: textos.labelMedium);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (preco != null) ...[
          Text(
            'R\$ ${Formato.paraCampo(preco.precoLitro, casas: 2)}',
            style: textos.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: esquema.primary),
          ),
          Text('${_idade(preco.data)} · $distancia', style: textos.labelSmall?.copyWith(color: esquema.onSurfaceVariant)),
        ] else ...[
          Text('R\$ --,--', style: textos.titleSmall?.copyWith(color: esquema.outline)),
          Text('sem preço · $distancia', style: textos.labelSmall?.copyWith(color: esquema.onSurfaceVariant)),
        ],
      ],
    );
  }

  static String _idade(DateTime data) {
    final dias = DateTime.now().difference(data).inDays;
    return switch (dias) {
      <= 0 => 'hoje',
      1 => 'ontem',
      _ => 'há $dias dias',
    };
  }
}
