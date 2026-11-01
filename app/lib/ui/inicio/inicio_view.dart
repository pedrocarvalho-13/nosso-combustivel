import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formato.dart';
import '../../core/rotas/rotas.dart';
import '../../core/tema/cores_base.dart';
import '../../data/sessao/sessao_controller.dart';
import '../../domain/calculos/calculo_consumo.dart';
import '../../domain/registro_energia.dart';
import '../comum/estado_vazio.dart';
import '../comum/indicador_sincronizacao.dart';
import 'inicio_view_model.dart';

class InicioView extends ConsumerWidget {
  const InicioView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(inicioViewModelProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (erro, _) => Center(child: Text('Não foi possível carregar: $erro')),
          data: (estado) {
            if (estado == null) {
              return EstadoVazio(
                icone: Icons.local_gas_station_outlined,
                titulo: 'Cadastre seu primeiro veículo',
                mensagem:
                    'Com o veículo cadastrado, você acompanha o gasto da semana, do mês e quanto ele faz por litro ou por kWh.',
                rotuloAcao: 'Adicionar veículo',
                aoAcionar: () => context.push(Rotas.novoCarro),
              );
            }
            final nome = ref.watch(sessaoProvider).value?.usuario.nome ?? '';
            return _Painel(estado: estado, primeiroNome: nome.trim().split(' ').first);
          },
        );
  }
}

class _Painel extends StatelessWidget {
  const _Painel({required this.estado, required this.primeiroNome});

  final InicioEstado estado;
  final String primeiroNome;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final veiculo = estado.veiculo;
    final abastece = veiculo.tipoEnergia.abastece;
    final recarrega = veiculo.tipoEnergia.recarrega;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _saudacao(primeiroNome),
                    overflow: TextOverflow.ellipsis,
                    style: textos.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                _BotaoRedondo(
                  icone: Icons.location_on_outlined,
                  cor: esquema.primary,
                  dica: abastece ? 'Postos perto' : 'Eletropostos perto',
                  aoTocar: () => context.push(Rotas.postos),
                ),
                const SizedBox(width: 8),
                _BotaoRedondo(
                  icone: Icons.notifications_none_rounded,
                  dica: 'Notificações',
                  aoTocar: () => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('As notificações chegam em breve.'))),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => context.go(Rotas.carros),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                veiculo.apelido,
                                overflow: TextOverflow.ellipsis,
                                style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.expand_more, size: 20, color: esquema.onSurfaceVariant),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.55),
                  child: const IndicadorSincronizacao(alinharDireita: true),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _CartaoGasto(estado: estado),
            for (final consumo in estado.consumos) ...[const SizedBox(height: 10), _CarrosselConsumo(consumo: consumo)],
            const SizedBox(height: 10),
            Row(
              children: [
                if (abastece)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.push(Rotas.novoAbastecimento),
                      icon: const Icon(Icons.local_gas_station),
                      label: Text(recarrega ? 'Abastecer' : 'Registrar abastecimento'),
                    ),
                  ),
                if (abastece && recarrega) const SizedBox(width: 10),
                if (recarrega)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.push(Rotas.novaRecarga),
                      icon: const Icon(Icons.bolt),
                      label: Text(abastece ? 'Recarregar' : 'Registrar recarga'),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text('Últimos registros', style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ),
                if (estado.ultimos.isNotEmpty)
                  TextButton(onPressed: () => context.go(Rotas.historico), child: const Text('Ver tudo')),
              ],
            ),
            if (estado.ultimos.isEmpty)
              Text(
                'Nenhum registro ainda. Use o botão acima no próximo abastecimento.',
                style: textos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
              )
            else
              _LinhaDoTempo(itens: estado.ultimos),
          ],
        ),
      ),
    );
  }
}

String _saudacao(String nome) {
  final hora = DateTime.now().hour;
  final periodo = hora >= 5 && hora < 12 ? 'Bom dia' : (hora >= 12 && hora < 18 ? 'Boa tarde' : 'Boa noite');
  return nome.isEmpty ? periodo : '$periodo, $nome';
}

class _BotaoRedondo extends StatelessWidget {
  const _BotaoRedondo({required this.icone, required this.dica, required this.aoTocar, this.cor});

  final IconData icone;
  final String dica;
  final VoidCallback aoTocar;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Tooltip(
      message: dica,
      child: Material(
        color: esquema.surfaceContainerHigh,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: aoTocar,
          child: SizedBox(width: 44, height: 44, child: Icon(icone, size: 22, color: cor ?? esquema.onSurfaceVariant)),
        ),
      ),
    );
  }
}

class _CartaoGasto extends StatefulWidget {
  const _CartaoGasto({required this.estado});

  final InicioEstado estado;

  @override
  State<_CartaoGasto> createState() => _CartaoGastoState();
}

class _CartaoGastoState extends State<_CartaoGasto> {
  late final _paginas = PageController(initialPage: widget.estado.indiceDoMesAtual);
  late var _atual = widget.estado.indiceDoMesAtual;

  @override
  void didUpdateWidget(_CartaoGasto antigo) {
    super.didUpdateWidget(antigo);
    final mesesAntigos = antigo.estado.meses;
    final vendo = mesesAntigos[_atual.clamp(0, mesesAntigos.length - 1)].mes;
    final novo = widget.estado.meses.indexWhere((m) => m.mes == vendo);
    final destino = novo >= 0 ? novo : widget.estado.indiceDoMesAtual;
    if (destino == _atual) return;
    _atual = destino;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_paginas.hasClients) _paginas.jumpToPage(destino);
    });
  }

  @override
  void dispose() {
    _paginas.dispose();
    super.dispose();
  }

  void _irPara(int indice) =>
      _paginas.animateToPage(indice, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final meses = widget.estado.meses;
    final indice = _atual.clamp(0, meses.length - 1);
    final mes = meses[indice];

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 4, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Gasto em ${Formato.mes(mes.mes)}${mes.mes.year == DateTime.now().year ? '' : ' de ${mes.mes.year}'}',
                    style: textos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
                  ),
                ),
                IconButton(
                  tooltip: 'Mês anterior',
                  visualDensity: VisualDensity.compact,
                  onPressed: indice == 0 ? null : () => _irPara(indice - 1),
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  tooltip: 'Próximo mês',
                  visualDensity: VisualDensity.compact,
                  onPressed: indice == meses.length - 1 ? null : () => _irPara(indice + 1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 172,
            child: PageView(
              controller: _paginas,
              onPageChanged: (novo) => setState(() => _atual = novo),
              children: [
                for (final pagina in meses)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: switch (pagina.tipo) {
                      TipoMes.atual => _MesAtual(estado: widget.estado),
                      TipoMes.passado => _MesPassado(mes: pagina),
                      TipoMes.seguinte => _MesSeguinte(mes: pagina),
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ValorDoMes extends StatelessWidget {
  const _ValorDoMes({required this.centavos, this.etiqueta});

  final int centavos;
  final String? etiqueta;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    return Row(
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(Formato.moeda(centavos), style: textos.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
          ),
        ),
        if (etiqueta != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: esquema.primaryContainer, borderRadius: BorderRadius.circular(10)),
            child: Text(etiqueta!, style: textos.labelSmall?.copyWith(color: esquema.primary)),
          ),
        ],
      ],
    );
  }
}

class _MesAtual extends StatelessWidget {
  const _MesAtual({required this.estado});

  final InicioEstado estado;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final secundario = textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant);
    final projecao = estado.projecaoCentavos;
    final meta = estado.metaCentavos;
    final referencia = meta ?? projecao;
    final fracao = referencia == null || referencia <= 0 ? null : estado.gastoMesCentavos / referencia;
    final corBarra = meta == null || fracao == null
        ? null
        : fracao > 1
        ? CoresBase.alerta
        : fracao >= 0.8
        ? CoresBase.atencao
        : null;
    final textoReferencia = meta != null
        ? 'Meta ${Formato.moeda(meta)} · ${(fracao! * 100).round()}%'
        : projecao == null
        ? 'Projeção após 7 dias de uso'
        : 'Projeção ${Formato.moeda(projecao)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ValorDoMes(centavos: estado.gastoMesCentavos),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: fracao?.clamp(0.0, 1.0) ?? 0,
            minHeight: 6,
            color: corBarra,
            backgroundColor: esquema.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                textoReferencia,
                style: corBarra == null
                    ? secundario
                    : secundario?.copyWith(
                        color: corBarra == CoresBase.atencao && Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFFA16207)
                            : corBarra,
                      ),
              ),
            ),
            Text('${Formato.km(estado.kmRodadosMes)} rodados', style: secundario),
          ],
        ),
        const Spacer(),
        Divider(height: 1, color: esquema.outlineVariant),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _Numero(rotulo: 'Esta semana', valor: Formato.moeda(estado.semanaCentavos)),
            ),
            Expanded(
              child: _Numero(
                rotulo: 'Custo por km',
                valor: estado.custoPorKm == null ? 'após 2 abastecimentos' : Formato.moedaPorKm(estado.custoPorKm!),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MesPassado extends StatelessWidget {
  const _MesPassado({required this.mes});

  final MesGasto mes;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final secundario = Theme.of(context).textTheme.bodySmall?.copyWith(color: esquema.onSurfaceVariant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ValorDoMes(centavos: mes.totalCentavos),
        const SizedBox(height: 8),
        Text('Mês fechado · ${Formato.km(mes.kmRodados)} rodados', style: secundario),
        const Spacer(),
        Divider(height: 1, color: esquema.outlineVariant),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _Numero(rotulo: 'Média por semana', valor: Formato.moeda(mes.mediaSemanalCentavos)),
            ),
            Expanded(
              child: _Numero(
                rotulo: 'Gasto por km rodado',
                valor: mes.custoPorKm == null ? '—' : Formato.moedaPorKm(mes.custoPorKm!),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MesSeguinte extends StatelessWidget {
  const _MesSeguinte({required this.mes});

  final MesGasto mes;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final secundario = textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant);
    final quantos = mes.registrosNoCredito;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ValorDoMes(centavos: mes.totalCentavos, etiqueta: 'já na fatura'),
        const SizedBox(height: 8),
        Text(
          quantos == 1
              ? '1 abastecimento no crédito cai neste mês'
              : '$quantos abastecimentos no crédito caem neste mês',
          style: secundario,
        ),
        const Spacer(),
        Text('Vale pelo dia de fechamento de cada cartão, em Ajustes · Meus cartões.', style: secundario),
      ],
    );
  }
}

class _Numero extends StatelessWidget {
  const _Numero({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo, style: textos.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(valor, style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _CarrosselConsumo extends StatefulWidget {
  const _CarrosselConsumo({required this.consumo});

  final ConsumoInicio consumo;

  @override
  State<_CarrosselConsumo> createState() => _CarrosselConsumoState();
}

class _CarrosselConsumoState extends State<_CarrosselConsumo> {
  static const _visoes = 3;
  final _paginas = PageController();
  var _atual = 0;

  @override
  void dispose() {
    _paginas.dispose();
    super.dispose();
  }

  void _irPara(int visao) =>
      _paginas.animateToPage(visao % _visoes, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final consumo = widget.consumo;

    return Column(
      children: [
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _irPara(_atual + 1),
            child: SizedBox(
              height: 104,
              child: PageView(
                controller: _paginas,
                onPageChanged: (visao) => setState(() => _atual = visao),
                children: [
                  _VisaoMedia(consumo: consumo),
                  _VisaoUltimo(consumo: consumo),
                  _VisaoGrafico(consumo: consumo),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _visoes; i++)
              Semantics(
                button: true,
                selected: i == _atual,
                label: const [
                  'Média dos últimos 30 dias',
                  'Último abastecimento',
                  'Gráfico dos últimos abastecimentos',
                ][i],
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _irPara(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _atual ? esquema.onSurface : Colors.transparent,
                        border: Border.all(color: i == _atual ? esquema.onSurface : esquema.onSurfaceVariant),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Visao extends StatelessWidget {
  const _Visao({required this.rotulo, required this.child});

  final String rotulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo, style: textos.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 2),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ValorConsumo extends StatelessWidget {
  const _ValorConsumo({required this.valor, required this.unidade, this.cor});

  final double? valor;
  final String unidade;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final esquema = Theme.of(context).colorScheme;
    if (valor == null) return Text('—', style: textos.headlineSmall?.copyWith(fontWeight: FontWeight.w600));
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: Formato.decimal(valor!),
            style: textos.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: cor),
          ),
          TextSpan(
            text: ' $unidade',
            style: textos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _VisaoMedia extends StatelessWidget {
  const _VisaoMedia({required this.consumo});

  final ConsumoInicio consumo;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final media = consumo.mediaMes;
    final unidadeQuantidade = consumo.unidade == 'km/l' ? 'L' : 'kWh';
    return _Visao(
      rotulo: 'Consumo médio · últimos ${consumo.dias} dias',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ValorConsumo(valor: media?.media, unidade: consumo.unidade),
          const Spacer(),
          Text(
            media == null
                ? 'Aparece no segundo abastecimento'
                : '${Formato.km(media.km)} ÷ ${Formato.decimal(media.quantidade)} $unidadeQuantidade de ${consumo.titulo}',
            style: textos.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _VisaoUltimo extends StatelessWidget {
  const _VisaoUltimo({required this.consumo});

  final ConsumoInicio consumo;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final ultimo = consumo.ultimo;
    final variacao = consumo.variacaoDoUltimo;
    final abaixo = variacao != null && variacao < -quedaParaDestacar;
    final unidadeQuantidade = consumo.unidade == 'km/l' ? 'L' : 'kWh';
    final comparacao = variacao == null
        ? ''
        : ' · ${(variacao.abs() * 100).round()}% ${variacao < 0 ? 'abaixo' : 'acima'} da média';
    return _Visao(
      rotulo: ultimo == null ? 'Último abastecimento' : 'Último abastecimento · ${Formato.dataCurta(ultimo.inicio)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ValorConsumo(valor: ultimo?.rendimento, unidade: consumo.unidade, cor: abaixo ? CoresBase.alerta : null),
          const Spacer(),
          Text(
            ultimo == null
                ? 'Aparece no segundo abastecimento'
                : '${Formato.km(ultimo.distanciaKm)} ÷ ${Formato.decimal(ultimo.quantidade)} $unidadeQuantidade$comparacao',
            style: textos.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _VisaoGrafico extends StatelessWidget {
  const _VisaoGrafico({required this.consumo});

  final ConsumoInicio consumo;

  @override
  Widget build(BuildContext context) {
    final ciclos = consumo.ultimos;
    return _Visao(
      rotulo: 'Últimos ${ciclos.length < 2 ? 5 : ciclos.length} abastecimentos · ${consumo.unidade}',
      child: ciclos.length < 2
          ? Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'O gráfico aparece a partir do terceiro abastecimento',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            )
          : CustomPaint(
              size: Size.infinite,
              painter: _PintorGrafico(
                ciclos: ciclos,
                media: consumo.mediaMes?.media,
                corLinha: Theme.of(context).colorScheme.primary,
                corTexto: Theme.of(context).colorScheme.onSurfaceVariant,
                corGuia: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
    );
  }
}

class _PintorGrafico extends CustomPainter {
  _PintorGrafico({
    required this.ciclos,
    required this.media,
    required this.corLinha,
    required this.corTexto,
    required this.corGuia,
  });

  final List<CicloConsumo> ciclos;
  final double? media;
  final Color corLinha;
  final Color corTexto;
  final Color corGuia;

  @override
  void paint(Canvas canvas, Size size) {
    const margemTopo = 12.0;
    const margemBase = 12.0;
    const margemLado = 14.0;
    final valores = ciclos.map((c) => c.rendimento).toList();
    final todos = [...valores, ?media];
    final minimo = todos.reduce((a, b) => a < b ? a : b);
    final maximo = todos.reduce((a, b) => a > b ? a : b);
    final faixa = (maximo - minimo).abs() < 0.001 ? 1.0 : maximo - minimo;
    final altura = size.height - margemTopo - margemBase;
    final passo = (size.width - margemLado * 2) / (valores.length - 1);
    double y(double v) => margemTopo + altura * (1 - (v - minimo) / faixa);
    final pontos = [for (var i = 0; i < valores.length; i++) Offset(margemLado + passo * i, y(valores[i]))];

    if (media != null) {
      final guia = Paint()
        ..color = corGuia
        ..strokeWidth = 1;
      final yMedia = y(media!);
      for (var x = 0.0; x < size.width; x += 7) {
        canvas.drawLine(Offset(x, yMedia), Offset(x + 3, yMedia), guia);
      }
    }

    final linha = Path()..moveTo(pontos.first.dx, pontos.first.dy);
    for (final ponto in pontos.skip(1)) {
      linha.lineTo(ponto.dx, ponto.dy);
    }
    canvas.drawPath(
      linha,
      Paint()
        ..color = corLinha
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    for (var i = 0; i < pontos.length; i++) {
      final ultimo = i == pontos.length - 1;
      final abaixo = media != null && valores[i] < media! * (1 - quedaParaDestacar);
      final cor = ultimo && abaixo ? CoresBase.alerta : corLinha;
      canvas.drawCircle(pontos[i], ultimo ? 3.5 : 3, Paint()..color = cor);
      _texto(canvas, Formato.decimal(valores[i]), pontos[i].translate(0, -11), cor == corLinha ? corTexto : cor);
      _texto(
        canvas,
        Formato.dataCurta(ciclos[i].inicio).split(' ').first,
        Offset(pontos[i].dx, size.height - 5),
        corTexto,
      );
    }
  }

  void _texto(Canvas canvas, String texto, Offset centro, Color cor) {
    final pintor = TextPainter(
      text: TextSpan(
        text: texto,
        style: TextStyle(color: cor, fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pintor.paint(canvas, centro - Offset(pintor.width / 2, pintor.height / 2));
  }

  @override
  bool shouldRepaint(_PintorGrafico antigo) =>
      antigo.ciclos != ciclos || antigo.media != media || antigo.corLinha != corLinha;
}

class _LinhaDoTempo extends StatelessWidget {
  const _LinhaDoTempo({required this.itens});

  final List<RegistroLinhaDoTempo> itens;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final secundario = textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant);

    return Container(
      margin: const EdgeInsets.only(left: 6),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: esquema.outlineVariant, width: 2)),
      ),
      child: Column(
        children: [
          for (final (indice, item) in itens.indexed)
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => context.push(
                item.registro is Abastecimento
                    ? Rotas.editarAbastecimento(item.registro.id)
                    : Rotas.editarRecarga(item.registro.id),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 4, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.translate(
                      offset: const Offset(-5, 5),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: indice == 0 ? esquema.primary : esquema.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(_titulo(item.registro), style: textos.bodyMedium)),
                              Text(
                                Formato.moeda(item.registro.valorCentavos),
                                style: textos.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text.rich(
                            TextSpan(
                              style: secundario,
                              children: [
                                TextSpan(text: _detalhes(item.registro)),
                                if (!item.registro.contaNaMedia) const TextSpan(text: ' · fora da média'),
                                if (item.consumo == null && indice == 0 && item.registro.contaNaMedia)
                                  const TextSpan(text: ' · aguardando o próximo'),
                                if (item.consumo != null)
                                  TextSpan(
                                    text: ' · ${Formato.decimal(item.consumo!)} ${item.unidade}',
                                    style: item.abaixo ? const TextStyle(color: CoresBase.alerta) : null,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _titulo(RegistroEnergia registro) {
    final data = Formato.dataCurta(registro.data);
    return switch (registro) {
      Abastecimento(:final combustivel, :final litros) =>
        '$data · ${combustivel.rotulo} · ${Formato.decimal(litros)} L',
      Recarga(:final kwh) => '$data · Recarga · ${Formato.decimal(kwh)} kWh',
    };
  }

  static String _detalhes(RegistroEnergia registro) {
    final partes = <String>[];
    if (registro case Abastecimento(:final posto?) when posto.isNotEmpty) partes.add(posto);
    if (registro.formaPagamento != null) partes.add(registro.formaPagamento!.rotulo);
    partes.add(Formato.km(registro.odometro));
    return partes.join(' · ');
  }
}
