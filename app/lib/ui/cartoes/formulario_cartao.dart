import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/provedores.dart';
import '../../data/sessao/sessao_controller.dart';
import '../../domain/cartao.dart';
import '../comum/campo_com_rotulo.dart';
import '../comum/formulario_registro.dart';

Future<Cartao?> mostrarFormularioCartao(BuildContext context, WidgetRef ref, {Cartao? cartao}) {
  return showModalBottomSheet<Cartao>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (contexto) => _FormularioCartao(cartao: cartao),
  );
}

class _FormularioCartao extends ConsumerStatefulWidget {
  const _FormularioCartao({this.cartao});

  final Cartao? cartao;

  @override
  ConsumerState<_FormularioCartao> createState() => _FormularioCartaoState();
}

class _FormularioCartaoState extends ConsumerState<_FormularioCartao> {
  late final _nome = TextEditingController(text: widget.cartao?.nome ?? '');
  late final _banco = TextEditingController(text: widget.cartao?.banco ?? '');
  late int? _dia = widget.cartao?.diaFechamento;
  String? _erroNome;
  String? _erroDia;

  @override
  void dispose() {
    _nome.dispose();
    _banco.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final nome = _nome.text.trim();
    setState(() {
      _erroNome = nome.isEmpty ? 'Dê um nome para o cartão.' : null;
      _erroDia = _dia == null ? 'Escolha o dia de fechamento.' : null;
    });
    final usuarioId = ref.read(sessaoProvider).value?.usuario.id;
    if (_erroNome != null || _erroDia != null || usuarioId == null) return;
    final cartao = Cartao(
      id: widget.cartao?.id ?? ref.read(geradorIdProvider)(),
      nome: nome,
      banco: _banco.text.trim().isEmpty ? null : _banco.text.trim(),
      diaFechamento: _dia!,
    );
    await ref.read(cartaoRepositorioProvider).salvar(cartao, usuarioId: usuarioId);
    if (mounted) Navigator.of(context).pop(cartao);
  }

  Future<void> _excluir() async {
    final cartao = widget.cartao;
    if (cartao == null) return;
    final confirmou = await confirmarExclusao(
      context,
      titulo: 'Excluir o cartão ${cartao.nome}?',
      mensagem: 'Os abastecimentos já feitos com ele continuam, mas saem da conta da fatura.',
    );
    if (!confirmou || !mounted) return;
    final repositorio = ref.read(cartaoRepositorioProvider);
    await repositorio.excluir(cartao.id);
    if (!mounted) return;
    avisarExclusao(context, 'Cartão excluído.', () => repositorio.restaurar(cartao.id));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final editando = widget.cartao != null;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(editando ? 'Editar cartão' : 'Novo cartão de crédito', style: textos.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            CampoComRotulo(
              rotulo: 'Banco (opcional)',
              child: TextField(
                controller: _banco,
                autofocus: !editando,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Ex.: Nubank'),
              ),
            ),
            const SizedBox(height: 12),
            CampoComRotulo(
              rotulo: 'Nome do cartão',
              child: TextField(
                controller: _nome,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(hintText: 'Ex.: Roxinho', errorText: _erroNome),
              ),
            ),
            const SizedBox(height: 12),
            CampoComRotulo(
              rotulo: 'Dia de fechamento da fatura',
              child: DropdownButtonFormField<int>(
                initialValue: _dia,
                items: [for (var dia = 1; dia <= 31; dia++) DropdownMenuItem(value: dia, child: Text('Dia $dia'))],
                onChanged: (dia) => setState(() {
                  _dia = dia;
                  _erroDia = null;
                }),
                decoration: InputDecoration(
                  errorText: _erroDia,
                  helperText: 'Abastecimentos a partir desse dia entram na fatura do mês seguinte.',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Só para organizar seus gastos. O app não pede número, validade nem senha do cartão.',
              style: textos.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _salvar, child: Text(editando ? 'Salvar alterações' : 'Salvar cartão')),
            if (editando) ...[
              const SizedBox(height: 8),
              TextButton(onPressed: _excluir, child: const Text('Excluir cartão')),
            ],
          ],
        ),
      ),
    );
  }
}
