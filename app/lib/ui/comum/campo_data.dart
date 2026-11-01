import 'package:flutter/material.dart';

import '../../core/formato.dart';
import 'campo_com_rotulo.dart';

class CampoData extends StatelessWidget {
  const CampoData({super.key, required this.data, required this.aoMudar, this.rotulo = 'Data'});

  final DateTime data;
  final ValueChanged<DateTime> aoMudar;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return CampoComRotulo(
      rotulo: rotulo,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final escolhida = await escolherData(context, inicial: data, titulo: rotulo);
          if (escolhida != null) {
            aoMudar(DateTime(escolhida.year, escolhida.month, escolhida.day, data.hour, data.minute));
          }
        },
        child: InputDecorator(
          decoration: const InputDecoration(suffixIcon: Icon(Icons.calendar_today_outlined, size: 18)),
          child: Text(rotuloDaData(data)),
        ),
      ),
    );
  }
}

String rotuloDaData(DateTime data) {
  final hoje = DateUtils.dateOnly(DateTime.now());
  final dia = DateUtils.dateOnly(data);
  final diferenca = hoje.difference(dia).inDays;
  final prefixo = switch (diferenca) {
    0 => 'Hoje, ',
    1 => 'Ontem, ',
    _ => '',
  };
  return '$prefixo${Formato.dataCompleta(data)}';
}

Future<DateTime?> escolherData(BuildContext context, {required DateTime inicial, String titulo = 'Data'}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _SeletorData(inicial: inicial, titulo: titulo),
  );
}

class _SeletorData extends StatefulWidget {
  const _SeletorData({required this.inicial, required this.titulo});

  final DateTime inicial;
  final String titulo;

  @override
  State<_SeletorData> createState() => _SeletorDataState();
}

class _SeletorDataState extends State<_SeletorData> {
  late var _escolhida = DateUtils.dateOnly(widget.inicial);
  var _versao = 0;

  void _atalho(int diasAtras) {
    setState(() {
      _escolhida = DateUtils.dateOnly(DateTime.now()).subtract(Duration(days: diasAtras));
      _versao++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final hoje = DateUtils.dateOnly(DateTime.now());
    final atalhos = [(0, 'Hoje'), (1, 'Ontem'), (2, 'Anteontem')];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(widget.titulo, style: textos.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            ),
            CalendarDatePicker(
              key: ValueKey(_versao),
              initialDate: _escolhida,
              firstDate: DateTime(2000),
              lastDate: hoje,
              onDateChanged: (data) => setState(() => _escolhida = data),
            ),
            Wrap(
              spacing: 8,
              children: [
                for (final (dias, rotulo) in atalhos)
                  ChoiceChip(
                    label: Text(rotulo),
                    selected: _escolhida == hoje.subtract(Duration(days: dias)),
                    onSelected: (_) => _atalho(dias),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_escolhida),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }
}
