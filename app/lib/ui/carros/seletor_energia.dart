import 'package:flutter/material.dart';

import '../../domain/calculos/identificacao_energia.dart';
import '../../domain/combustivel.dart';
import '../../domain/tipo_energia.dart';

Future<EnergiaIdentificada?> mostrarSeletorEnergia(BuildContext context, EnergiaIdentificada atual) {
  return showModalBottomSheet<EnergiaIdentificada>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _SeletorEnergia(atual: atual),
  );
}

class _SeletorEnergia extends StatefulWidget {
  const _SeletorEnergia({required this.atual});

  final EnergiaIdentificada atual;

  @override
  State<_SeletorEnergia> createState() => _SeletorEnergiaState();
}

class _SeletorEnergiaState extends State<_SeletorEnergia> {
  late TipoEnergia _tipo = widget.atual.tipo;
  late final Set<Combustivel> _combustiveis = {...widget.atual.combustiveis};

  bool get _valido => _tipo == TipoEnergia.eletrico || _combustiveis.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo de energia', style: textos.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tipo in TipoEnergia.values)
                  ChoiceChip(
                    label: Text(tipo.rotulo),
                    selected: _tipo == tipo,
                    onSelected: (_) => setState(() => _tipo = tipo),
                  ),
              ],
            ),
            if (_tipo != TipoEnergia.eletrico) ...[
              const SizedBox(height: 20),
              Text('Combustíveis que o carro aceita', style: textos.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final combustivel in Combustivel.values)
                    FilterChip(
                      label: Text(combustivel.rotulo),
                      selected: _combustiveis.contains(combustivel),
                      onSelected: (marcado) => setState(
                        () => marcado ? _combustiveis.add(combustivel) : _combustiveis.remove(combustivel),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _valido
                  ? () => Navigator.of(context).pop(EnergiaIdentificada(
                        _tipo,
                        _tipo == TipoEnergia.eletrico
                            ? const []
                            : Combustivel.values.where(_combustiveis.contains).toList(),
                      ))
                  : null,
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
  }
}
