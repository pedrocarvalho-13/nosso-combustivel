import 'package:flutter/material.dart';

import '../../core/formato.dart';

class CampoData extends StatelessWidget {
  const CampoData({super.key, required this.data, required this.aoMudar, this.rotulo = 'Data'});

  final DateTime data;
  final ValueChanged<DateTime> aoMudar;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final escolhida = await showDatePicker(
          context: context,
          initialDate: data,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (escolhida != null) {
          aoMudar(DateTime(escolhida.year, escolhida.month, escolhida.day, data.hour, data.minute));
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: rotulo, suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18)),
        child: Text(Formato.dataCompleta(data)),
      ),
    );
  }
}
