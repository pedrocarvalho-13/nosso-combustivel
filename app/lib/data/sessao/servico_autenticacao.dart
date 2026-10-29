import 'package:dio/dio.dart';

import '../../domain/sessao.dart';

class ErroAutenticacao implements Exception {
  const ErroAutenticacao(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

class ServicoAutenticacao {
  ServicoAutenticacao(this._dio);

  final Dio _dio;

  Future<Sessao> criarConta({required String nome, required String email, required String senha}) =>
      _sessao('/contas', {'nome': nome, 'email': email, 'senha': senha});

  Future<Sessao> entrar({required String email, required String senha}) =>
      _sessao('/sessoes', {'email': email, 'senha': senha});

  Future<Sessao> renovar(String refreshToken) => _sessao('/sessoes/renovar', {'refreshToken': refreshToken});

  Future<void> sair(String refreshToken) => _dio.post<void>('/sessoes/sair', data: {'refreshToken': refreshToken});

  Future<Sessao> _sessao(String caminho, Map<String, dynamic> corpo) async {
    try {
      final resposta = await _dio.post<Map<String, dynamic>>(caminho, data: corpo);
      return Sessao.deJson(resposta.data!);
    } on DioException catch (erro) {
      final dados = erro.response?.data;
      if (dados is Map && dados['title'] is String) throw ErroAutenticacao(dados['title'] as String);
      if (erro.response == null) {
        throw const ErroAutenticacao('Sem conexão com o servidor. Verifique a internet e tente de novo.');
      }
      throw const ErroAutenticacao('Algo deu errado. Tente de novo em instantes.');
    }
  }
}
