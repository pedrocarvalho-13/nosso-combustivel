import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/provedores.dart';
import '../../domain/forma_pagamento.dart';
import '../cartoes/formulario_cartao.dart';
import 'campo_com_rotulo.dart';

class CampoPagamento extends ConsumerWidget {
  const CampoPagamento({super.key, required this.forma, required this.cartaoId, required this.aoMudar, this.erro});

  final FormaPagamento? forma;
  final String? cartaoId;
  final void Function(FormaPagamento? forma, String? cartaoId) aoMudar;
  final String? erro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartoes = ref.watch(cartoesProvider).value ?? const [];
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return CampoComRotulo(
      rotulo: 'Como você pagou?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final opcao in FormaPagamento.values)
                ChoiceChip(
                  label: Text(opcao.rotulo),
                  selected: forma == opcao,
                  onSelected: (marcado) {
                    if (!marcado) return aoMudar(null, null);
                    final cartao = opcao == FormaPagamento.credito
                        ? (cartoes.any((c) => c.id == cartaoId) ? cartaoId : cartoes.firstOrNull?.id)
                        : null;
                    aoMudar(opcao, cartao);
                  },
                ),
            ],
          ),
          if (forma == FormaPagamento.credito) ...[
            const SizedBox(height: 12),
            Text('Qual cartão?', style: textos.bodySmall?.copyWith(color: esquema.onSurfaceVariant)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final cartao in cartoes)
                  ChoiceChip(
                    avatar: const Icon(Icons.credit_card, size: 18),
                    label: Text('${cartao.nome} · fecha dia ${cartao.diaFechamento}'),
                    selected: cartaoId == cartao.id,
                    onSelected: (_) => aoMudar(FormaPagamento.credito, cartao.id),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: Text(cartoes.isEmpty ? 'Cadastrar cartão' : 'Novo cartão'),
                  onPressed: () async {
                    final novo = await mostrarFormularioCartao(context, ref);
                    if (novo != null) aoMudar(FormaPagamento.credito, novo.id);
                  },
                ),
              ],
            ),
          ],
          if (erro != null) ...[
            const SizedBox(height: 6),
            Text(erro!, style: textos.bodySmall?.copyWith(color: esquema.error)),
          ],
        ],
      ),
    );
  }
}
