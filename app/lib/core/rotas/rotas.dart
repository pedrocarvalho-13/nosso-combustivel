import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/sessao/sessao_controller.dart';
import '../../ui/abastecimento/novo_abastecimento_view.dart';
import '../../ui/carros/cadastro_carro_view.dart';
import '../../ui/carros/carros_view.dart';
import '../../ui/conta/conta_view.dart';
import '../../ui/historico/historico_view.dart';
import '../../ui/inicio/inicio_view.dart';
import '../../ui/recarga/nova_recarga_view.dart';
import '../../ui/relatorios/relatorios_view.dart';
import '../../ui/shell/shell_view.dart';

abstract final class Rotas {
  static const carregando = '/carregando';
  static const entrar = '/entrar';
  static const criarConta = '/criar-conta';
  static const inicio = '/inicio';
  static const historico = '/historico';
  static const relatorios = '/relatorios';
  static const carros = '/carros';
  static const novoCarro = '/carro/novo';
  static const novoAbastecimento = '/abastecimento/novo';
  static const novaRecarga = '/recarga/nova';
}

final rotasProvider = Provider<GoRouter>((ref) {
  final sessaoMudou = ValueNotifier(0);
  ref.listen(sessaoProvider, (_, _) => sessaoMudou.value++);

  final rotas = GoRouter(
    initialLocation: Rotas.inicio,
    refreshListenable: sessaoMudou,
    redirect: (context, state) {
      final sessao = ref.read(sessaoProvider);
      final local = state.matchedLocation;
      if (sessao.isLoading && !sessao.hasValue) return local == Rotas.carregando ? null : Rotas.carregando;

      final logado = sessao.value != null;
      final telaDeConta = local == Rotas.entrar || local == Rotas.criarConta;
      if (!logado) return telaDeConta ? null : Rotas.entrar;
      if (telaDeConta || local == Rotas.carregando) return Rotas.inicio;
      return null;
    },
    routes: [
      GoRoute(
        path: Rotas.carregando,
        builder: (_, _) => const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(path: Rotas.entrar, builder: (_, _) => const ContaView(criandoConta: false)),
      GoRoute(path: Rotas.criarConta, builder: (_, _) => const ContaView(criandoConta: true)),
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
  ref.onDispose(() {
    rotas.dispose();
    sessaoMudou.dispose();
  });
  return rotas;
});
