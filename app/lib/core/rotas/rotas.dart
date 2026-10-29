import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ui/carros/carros_view.dart';
import '../../ui/historico/historico_view.dart';
import '../../ui/inicio/inicio_view.dart';
import '../../ui/relatorios/relatorios_view.dart';
import '../../ui/shell/shell_view.dart';

abstract final class Rotas {
  static const inicio = '/inicio';
  static const historico = '/historico';
  static const relatorios = '/relatorios';
  static const carros = '/carros';
}

final rotasProvider = Provider<GoRouter>((ref) {
  final rotas = GoRouter(
    initialLocation: Rotas.inicio,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navegacao) => ShellView(navegacao: navegacao),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: Rotas.inicio, builder: (_, _) => const InicioView()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Rotas.historico, builder: (_, _) => const HistoricoView()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Rotas.relatorios, builder: (_, _) => const RelatoriosView()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Rotas.carros, builder: (_, _) => const CarrosView()),
          ]),
        ],
      ),
    ],
  );
  ref.onDispose(rotas.dispose);
  return rotas;
});
