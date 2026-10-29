import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/sessao/servico_autenticacao.dart';
import '../../data/sessao/sessao_controller.dart';

class FormularioContaEstado {
  const FormularioContaEstado({this.enviando = false, this.erro});

  final bool enviando;
  final String? erro;
}

class FormularioContaViewModel extends Notifier<FormularioContaEstado> {
  @override
  FormularioContaEstado build() => const FormularioContaEstado();

  Future<bool> entrar({required String email, required String senha}) {
    if (email.trim().isEmpty || senha.isEmpty) return _falhar('Informe e-mail e senha.');
    return _enviar(() => ref.read(sessaoProvider.notifier).entrar(email: email.trim(), senha: senha));
  }

  Future<bool> criarConta({required String nome, required String email, required String senha}) {
    if (nome.trim().isEmpty || email.trim().isEmpty || senha.isEmpty) return _falhar('Preencha nome, e-mail e senha.');
    return _enviar(
      () => ref.read(sessaoProvider.notifier).criarConta(nome: nome.trim(), email: email.trim(), senha: senha),
    );
  }

  Future<bool> _falhar(String erro) async {
    state = FormularioContaEstado(erro: erro);
    return false;
  }

  Future<bool> _enviar(Future<void> Function() acao) async {
    state = const FormularioContaEstado(enviando: true);
    try {
      await acao();
      if (ref.mounted) state = const FormularioContaEstado();
      return true;
    } on ErroAutenticacao catch (erro) {
      if (ref.mounted) state = FormularioContaEstado(erro: erro.mensagem);
      return false;
    }
  }
}

final formularioContaViewModelProvider =
    NotifierProvider.autoDispose<FormularioContaViewModel, FormularioContaEstado>(FormularioContaViewModel.new);
