import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/rotas/rotas.dart';
import '../comum/estado_vazio.dart';
import 'inicio_view_model.dart';

class InicioView extends ConsumerWidget {
  const InicioView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(inicioViewModelProvider);

    if (estado.semCarro) {
      return EstadoVazio(
        icone: Icons.local_gas_station_outlined,
        titulo: 'Cadastre seu primeiro carro',
        mensagem: 'Com o carro cadastrado, você acompanha o gasto da semana, do mês e quanto ele faz por litro ou por kWh.',
        rotuloAcao: 'Adicionar carro',
        aoAcionar: () => context.go(Rotas.carros),
      );
    }

    return Center(child: Text(estado.apelidoCarroAtivo!));
  }
}
