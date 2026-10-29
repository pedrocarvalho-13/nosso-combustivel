import 'package:flutter/material.dart';

import '../comum/estado_vazio.dart';

class RelatoriosView extends StatelessWidget {
  const RelatoriosView({super.key});

  @override
  Widget build(BuildContext context) {
    return const EstadoVazio(
      icone: Icons.bar_chart,
      titulo: 'Sem dados para relatório',
      mensagem: 'Depois de alguns registros, você vê o gasto por mês e o consumo por tanque.',
    );
  }
}
