import 'package:flutter/material.dart';

import '../comum/estado_vazio.dart';

class CarrosView extends StatelessWidget {
  const CarrosView({super.key});

  @override
  Widget build(BuildContext context) {
    return const EstadoVazio(
      icone: Icons.directions_car_outlined,
      titulo: 'Nenhum carro ainda',
      mensagem: 'O cadastro pela tabela FIPE chega na próxima etapa.',
    );
  }
}
