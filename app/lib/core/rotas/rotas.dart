import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ui/abastecimento/novo_abastecimento_view.dart';
import '../../ui/carros/cadastro_carro_view.dart';
import '../../ui/carros/carros_view.dart';
import '../../ui/historico/historico_view.dart';
import '../../ui/inicio/inicio_view.dart';
import '../../ui/recarga/nova_recarga_view.dart';
import '../../ui/relatorios/relatorios_view.dart';
import '../../ui/shell/shell_view.dart';

abstract final class Rotas {
  static const inicio = '/inicio';
  static const historico = '/historico';
  static const relatorios = '/relatorios';
  static const carros = '/carros';
  static const novoCarro = '/carro/novo';
  static const novoAbastecimento = '/abastecimento/novo';
  static const novaRecarga = '/recarga/nova';
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
      GoRoute(path: Rotas.novoCarro, builder: (_, _) => const CadastroCarroView()),
      GoRoute(path: Rotas.novoAbastecimento, builder: (_, _) => const NovoAbastecimentoView()),
      GoRoute(path: Rotas.novaRecarga, builder: (_, _) => const NovaRecargaView()),
    ],
  );
  ref.onDispose(rotas.dispose);
  return rotas;
});
