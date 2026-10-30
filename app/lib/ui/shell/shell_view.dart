import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/sync/sincronizacao_controller.dart';

class ShellView extends ConsumerWidget {
  const ShellView({super.key, required this.navegacao});

  final StatefulNavigationShell navegacao;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sincronizacaoProvider);
    return Scaffold(
      body: SafeArea(child: navegacao),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navegacao.currentIndex,
        onDestinationSelected: (indice) => navegacao.goBranch(
          indice,
          initialLocation: indice == navegacao.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Relatórios',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Veículos',
          ),
        ],
      ),
    );
  }
}
