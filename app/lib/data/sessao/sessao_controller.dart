import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/sessao.dart';
import '../provedores.dart';
import 'armazenamento_sessao.dart';
import 'servico_autenticacao.dart';

const urlApi = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:5081');

final armazenamentoSessaoProvider = Provider<ArmazenamentoSessao>((ref) => ArmazenamentoSessaoSeguro());

final servicoAutenticacaoProvider = Provider<ServicoAutenticacao>(
  (ref) => ServicoAutenticacao(Dio(BaseOptions(baseUrl: urlApi, connectTimeout: const Duration(seconds: 15)))),
);

class SessaoController extends AsyncNotifier<Sessao?> {
  ArmazenamentoSessao get _armazenamento => ref.read(armazenamentoSessaoProvider);
  ServicoAutenticacao get _servico => ref.read(servicoAutenticacaoProvider);

  @override
  Future<Sessao?> build() => _armazenamento.ler();

  Future<void> entrar({required String email, required String senha}) async =>
      _abrir(await _servico.entrar(email: email, senha: senha));

  Future<void> criarConta({required String nome, required String email, required String senha}) async =>
      _abrir(await _servico.criarConta(nome: nome, email: email, senha: senha));

  Future<Sessao?> renovar() async {
    final atual = state.value;
    if (atual == null) return null;
    try {
      final nova = await _servico.renovar(atual.refreshToken);
      await _armazenamento.gravar(nova);
      state = AsyncData(nova);
      return nova;
    } on ErroAutenticacao {
      await sair();
      return null;
    }
  }

  Future<void> sair() async {
    final atual = state.value;
    state = const AsyncData(null);
    await _armazenamento.limpar();
    if (atual == null) return;
    try {
      await _servico.sair(atual.refreshToken);
    } catch (_) {}
  }

  Future<void> _abrir(Sessao sessao) async {
    await _armazenamento.gravar(sessao);
    await ref.read(veiculoRepositorioProvider).adotarSemDono(sessao.usuario.id);
    state = AsyncData(sessao);
  }
}

final sessaoProvider = AsyncNotifierProvider<SessaoController, Sessao?>(SessaoController.new);
