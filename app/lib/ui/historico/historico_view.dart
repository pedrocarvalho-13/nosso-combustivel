import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/rotas/rotas.dart';

import '../../core/tema/cores_base.dart';
import '../../domain/registro_energia.dart';
import '../comum/estado_vazio.dart';
import '../comum/registro_tile.dart';
import 'historico_view_model.dart';

class HistoricoView extends ConsumerWidget {
  const HistoricoView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(historicoViewModelProvider);
    final vm = ref.read(historicoViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: estado.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erro, _) => Center(child: Text('Não foi possível carregar: $erro')),
        data: (estado) {
          if (estado.veiculo == null || estado.vazio) {
            return const EstadoVazio(
              icone: Icons.history,
              titulo: 'Nenhum registro ainda',
              mensagem: 'Os abastecimentos e as recargas do carro ativo aparecem aqui.',
            );
          }
          final textos = Theme.of(context).textTheme;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              if (estado.mostrarFiltro) ...[
                SegmentedButton<FiltroHistorico>(
                  segments: const [
                    ButtonSegment(value: FiltroHistorico.todos, label: Text('Todos')),
                    ButtonSegment(value: FiltroHistorico.abastecimentos, label: Text('Abastecimentos')),
                    ButtonSegment(value: FiltroHistorico.recargas, label: Text('Recargas')),
                  ],
                  selected: {estado.filtro},
                  showSelectedIcon: false,
                  onSelectionChanged: (selecao) => vm.filtrar(selecao.first),
                ),
                const SizedBox(height: 8),
              ],
              for (final grupo in estado.grupos) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                  child: Text(
                    grupo.titulo.toUpperCase(),
                    style: textos.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                for (final item in grupo.itens)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Dismissible(
                      key: ValueKey(item.registro.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(color: CoresBase.alerta, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      confirmDismiss: (_) => _confirmarExclusao(context, item.registro),
                      onDismissed: (_) async {
                        await vm.excluir(item.registro);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro excluído.')));
                        }
                      },
                      child: RegistroTile(
                        registro: item.registro,
                        consumo: item.consumo,
                        alerta: item.alerta,
                        aoTocar: () => context.push(_rotaDeEdicao(item.registro)),
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 8),
              Text(
                'Toque num registro para editar ou arraste para a esquerda para excluir.',
                textAlign: TextAlign.center,
                style: textos.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _rotaDeEdicao(RegistroEnergia registro) => registro is Abastecimento
      ? Rotas.editarAbastecimento(registro.id)
      : Rotas.editarRecarga(registro.id);

  Future<bool> _confirmarExclusao(BuildContext context, RegistroEnergia registro) async {
    final tipo = registro is Abastecimento ? 'este abastecimento' : 'esta recarga';
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: Text('Excluir $tipo?'),
        content: const Text('O consumo e os gastos serão recalculados sem ele.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(contexto).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(contexto).pop(true), child: const Text('Excluir')),
        ],
      ),
    );
    return confirmou ?? false;
  }
}
