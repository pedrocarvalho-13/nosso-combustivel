import 'package:flutter/material.dart';

import '../comum/estado_vazio.dart';

class HistoricoView extends StatelessWidget {
  const HistoricoView({super.key});

  @override
  Widget build(BuildContext context) {
    return const EstadoVazio(
      icone: Icons.history,
      titulo: 'Nenhum registro ainda',
      mensagem: 'Os abastecimentos e as recargas aparecem aqui.',
    );
  }
}
