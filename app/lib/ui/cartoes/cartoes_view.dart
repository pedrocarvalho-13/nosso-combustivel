import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/provedores.dart';
import '../comum/estado_vazio.dart';
import 'formulario_cartao.dart';

class CartoesView extends ConsumerWidget {
  const CartoesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartoes = ref.watch(cartoesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus cartões'),
        actions: [
          IconButton(
            tooltip: 'Adicionar cartão',
            icon: const Icon(Icons.add),
            onPressed: () => mostrarFormularioCartao(context, ref),
          ),
        ],
      ),
      body: cartoes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erro, _) => Center(child: Text('Não foi possível carregar: $erro')),
        data: (lista) => lista.isEmpty
            ? EstadoVazio(
                icone: Icons.credit_card,
                titulo: 'Nenhum cartão ainda',
                mensagem: 'Cadastre seus cartões de crédito com o dia de fechamento para o gasto do mês seguir a sua fatura.',
                rotuloAcao: 'Adicionar cartão',
                aoAcionar: () => mostrarFormularioCartao(context, ref),
              )
            : Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: lista.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, indice) {
                      final cartao = lista[indice];
                      return Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          leading: const Icon(Icons.credit_card),
                          title: Text(cartao.nome),
                          subtitle: Text([if (cartao.banco != null) cartao.banco!, 'fecha no dia ${cartao.diaFechamento}'].join(' · ')),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => mostrarFormularioCartao(context, ref, cartao: cartao),
                        ),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
