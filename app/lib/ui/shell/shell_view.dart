import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/sync/sincronizacao_controller.dart';

class _Destino {
  const _Destino(this.rotulo, this.icone, this.iconeSelecionado);

  final String rotulo;
  final IconData icone;
  final IconData iconeSelecionado;
}

const _destinos = [
  _Destino('Início', Icons.home_outlined, Icons.home_rounded),
  _Destino('Histórico', Icons.history_rounded, Icons.history_rounded),
  _Destino('Relatórios', Icons.bar_chart_outlined, Icons.bar_chart_rounded),
  _Destino('Veículos', Icons.directions_car_outlined, Icons.directions_car_rounded),
  _Destino('Ajustes', Icons.settings_outlined, Icons.settings_rounded),
];

class ShellView extends ConsumerWidget {
  const ShellView({super.key, required this.navegacao});

  static const larguraParaBarraLateral = 840.0;

  final StatefulNavigationShell navegacao;

  void _ir(int indice) => navegacao.goBranch(indice, initialLocation: indice == navegacao.currentIndex);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sincronizacaoProvider);
    final largo = MediaQuery.sizeOf(context).width >= larguraParaBarraLateral;

    if (largo) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              _BarraLateral(selecionado: navegacao.currentIndex, aoSelecionar: _ir),
              Expanded(child: navegacao),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(bottom: false, child: navegacao),
      bottomNavigationBar: _BarraFlutuante(selecionado: navegacao.currentIndex, aoSelecionar: _ir),
    );
  }
}

class _BarraFlutuante extends StatelessWidget {
  const _BarraFlutuante({required this.selecionado, required this.aoSelecionar});

  final int selecionado;
  final ValueChanged<int> aoSelecionar;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final inferior = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, inferior > 0 ? inferior : 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: escuro ? 0.45 : 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 64,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: esquema.surfaceContainer.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: esquema.outlineVariant.withValues(alpha: 0.6), width: 0.5),
              ),
              child: Row(
                children: [
                  for (final (indice, destino) in _destinos.indexed)
                    Expanded(
                      child: _ItemFlutuante(
                        destino: destino,
                        selecionado: indice == selecionado,
                        aoTocar: () => aoSelecionar(indice),
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
}

class _ItemFlutuante extends StatelessWidget {
  const _ItemFlutuante({required this.destino, required this.selecionado, required this.aoTocar});

  final _Destino destino;
  final bool selecionado;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final cor = selecionado ? esquema.primary : esquema.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selecionado,
      label: destino.rotulo,
      excludeSemantics: true,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(26),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: selecionado ? esquema.primary.withValues(alpha: 0.14) : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selecionado ? destino.iconeSelecionado : destino.icone, color: cor, size: 24),
              const SizedBox(height: 2),
              FittedBox(
                child: Text(
                  destino.rotulo,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cor,
                    fontWeight: selecionado ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarraLateral extends StatefulWidget {
  const _BarraLateral({required this.selecionado, required this.aoSelecionar});

  final int selecionado;
  final ValueChanged<int> aoSelecionar;

  @override
  State<_BarraLateral> createState() => _BarraLateralState();
}

class _BarraLateralState extends State<_BarraLateral> {
  var _recolhida = false;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: _recolhida ? 72 : 232,
        decoration: BoxDecoration(
          color: esquema.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: esquema.outlineVariant.withValues(alpha: 0.6), width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, limites) {
            final mostrarTexto = limites.maxWidth > 160;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                  child: Row(
                    children: [
                      Image.asset('assets/logo.png', width: 36, height: 36, semanticLabel: 'Logo do Nosso Combustível'),
                      if (mostrarTexto) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Nosso Combustível',
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: textos.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                for (final (indice, destino) in _destinos.indexed)
                  _ItemLateral(
                    destino: destino,
                    selecionado: indice == widget.selecionado,
                    mostrarTexto: mostrarTexto,
                    aoTocar: () => widget.aoSelecionar(indice),
                  ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: mostrarTexto ? Alignment.centerRight : Alignment.center,
                    child: IconButton(
                      tooltip: _recolhida ? 'Expandir menu' : 'Recolher menu',
                      onPressed: () => setState(() => _recolhida = !_recolhida),
                      icon: Icon(_recolhida ? Icons.keyboard_double_arrow_right : Icons.keyboard_double_arrow_left),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ItemLateral extends StatelessWidget {
  const _ItemLateral({
    required this.destino,
    required this.selecionado,
    required this.mostrarTexto,
    required this.aoTocar,
  });

  final _Destino destino;
  final bool selecionado;
  final bool mostrarTexto;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final cor = selecionado ? esquema.primary : esquema.onSurfaceVariant;
    final item = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: selecionado ? esquema.primary.withValues(alpha: 0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: aoTocar,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 46,
            child: Row(
              mainAxisAlignment: mostrarTexto ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                if (mostrarTexto) const SizedBox(width: 12),
                Icon(selecionado ? destino.iconeSelecionado : destino.icone, color: cor),
                if (mostrarTexto) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      destino.rotulo,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: selecionado ? esquema.onSurface : esquema.onSurfaceVariant,
                        fontWeight: selecionado ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    return Semantics(
      button: true,
      selected: selecionado,
      label: destino.rotulo,
      excludeSemantics: true,
      child: mostrarTexto ? item : Tooltip(message: destino.rotulo, child: item),
    );
  }
}
