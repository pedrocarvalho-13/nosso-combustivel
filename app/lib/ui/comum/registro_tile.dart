import 'package:flutter/material.dart';

import '../../core/formato.dart';
import '../../core/tema/cores_base.dart';
import '../../domain/registro_energia.dart';
import 'icone_energia.dart';

class RegistroTile extends StatelessWidget {
  const RegistroTile({super.key, required this.registro, this.consumo, this.alerta = false});

  final RegistroEnergia registro;
  final String? consumo;
  final bool alerta;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconeEnergia(icone: iconeDoRegistro(registro)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_titulo, style: textos.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(_detalhes, style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant)),
                  if (consumo != null && !alerta) ...[
                    const SizedBox(height: 2),
                    Text(consumo!, style: textos.bodySmall),
                  ],
                  if (consumo != null && alerta) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 16, color: CoresBase.alerta),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '▼ $consumo · abaixo da média',
                            style: textos.bodySmall?.copyWith(color: CoresBase.alerta, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(Formato.moeda(registro.valorCentavos), style: textos.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  String get _titulo => switch (registro) {
        Abastecimento(:final combustivel, :final litros) => '${combustivel.rotulo} · ${Formato.decimal(litros)} L',
        Recarga(:final local, :final kwh) => '${_onde(local)} · ${Formato.decimal(kwh)} kWh',
      };

  String get _detalhes {
    final partes = [Formato.dataCurta(registro.data)];
    switch (registro) {
      case Abastecimento(:final posto, :final tanqueCheio):
        if (posto != null && posto.isNotEmpty) partes.add(posto);
        partes.add(tanqueCheio ? 'tanque cheio' : 'parcial');
      case Recarga(:final cargaCompleta):
        partes.add(cargaCompleta ? 'até 100%' : 'parcial');
    }
    partes.add(Formato.km(registro.odometro));
    return partes.join(' · ');
  }

  static String _onde(LocalRecarga local) => switch (local) {
        LocalRecarga.casa => 'Recarga em casa',
        LocalRecarga.trabalho => 'Recarga no trabalho',
        LocalRecarga.eletroposto => 'Eletroposto',
      };
}
