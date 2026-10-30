import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/rotas/rotas.dart';
import '../../core/tema/cores_base.dart';
import '../comum/campo_com_rotulo.dart';
import 'formulario_conta_view_model.dart';

class ContaView extends ConsumerStatefulWidget {
  const ContaView({super.key, required this.criandoConta});

  final bool criandoConta;

  @override
  ConsumerState<ContaView> createState() => _ContaViewState();
}

class _ContaViewState extends ConsumerState<ContaView> {
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  var _senhaVisivel = false;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    TextInput.finishAutofillContext();
    final vm = ref.read(formularioContaViewModelProvider.notifier);
    if (widget.criandoConta) {
      await vm.criarConta(nome: _nome.text, email: _email.text, senha: _senha.text);
    } else {
      await vm.entrar(email: _email.text, senha: _senha.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(formularioContaViewModelProvider);
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final criando = widget.criandoConta;

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: esquema.copyWith(
          primary: CoresMarca.azul,
          primaryContainer: CoresMarca.azul.withValues(alpha: 0.16),
        ),
        inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: CoresMarca.azul, width: 1.5),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(cursorColor: CoresMarca.azul),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 72,
                      height: 72,
                      semanticLabel: 'Logo do Nosso Combustível',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nosso Combustível',
                    textAlign: TextAlign.center,
                    style: textos.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    criando ? 'Crie sua conta para começar' : 'Entre para ver os gastos dos seus veículos',
                    textAlign: TextAlign.center,
                    style: textos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
                  ),
                  const SizedBox(height: 28),
                  AutofillGroup(
                    child: Column(
                      children: [
                        if (criando) ...[
                          CampoComRotulo(
                            rotulo: 'Nome',
                            child: TextField(
                              controller: _nome,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.name],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        CampoComRotulo(
                          rotulo: 'E-mail',
                          child: TextField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            autofillHints: const [AutofillHints.email],
                          ),
                        ),
                        const SizedBox(height: 14),
                        CampoComRotulo(
                          rotulo: 'Senha',
                          child: TextField(
                            controller: _senha,
                            obscureText: !_senhaVisivel,
                            textInputAction: TextInputAction.done,
                            autofillHints: [criando ? AutofillHints.newPassword : AutofillHints.password],
                            onSubmitted: (_) => _enviar(),
                            decoration: InputDecoration(
                              helperText: criando ? 'Mínimo de 8 caracteres, com letra minúscula e número.' : null,
                              suffixIcon: IconButton(
                                tooltip: _senhaVisivel ? 'Esconder senha' : 'Mostrar senha',
                                icon: Icon(_senhaVisivel ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (estado.erro != null) ...[
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline, size: 18, color: CoresBase.alerta),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(estado.erro!, style: textos.bodyMedium?.copyWith(color: CoresBase.alerta)),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: CoresMarca.azul,
                      disabledBackgroundColor: CoresMarca.azul,
                      foregroundColor: CoresBase.fundoEscuro,
                    ),
                    onPressed: estado.enviando ? null : _enviar,
                    child: estado.enviando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: CoresBase.fundoEscuro),
                          )
                        : Text(criando ? 'Criar conta' : 'Entrar'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: CoresMarca.azul),
                    onPressed: estado.enviando ? null : () => context.go(criando ? Rotas.entrar : Rotas.criarConta),
                    child: Text(criando ? 'Já tenho conta' : 'Ainda não tenho conta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
