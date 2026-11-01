import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sync/cliente_sync.dart';
import 'ponte_notificacoes.dart';

class ErroNotificacoes implements Exception {
  const ErroNotificacoes(this.mensagem);

  final String mensagem;
}

class ClienteNotificacoes {
  ClienteNotificacoes(this._dio);

  final Dio _dio;

  Future<String> chavePublica() => _chamar(() async {
    final resposta = await _dio.get<Map<String, dynamic>>('/notificacoes/chave');
    return resposta.data!['chavePublica'] as String;
  });

  Future<void> inscrever(InscricaoAparelho inscricao, String aparelho) => _chamar(
    () => _dio.post<void>(
      '/notificacoes/inscricao',
      data: {'endpoint': inscricao.endpoint, 'p256dh': inscricao.p256dh, 'auth': inscricao.auth, 'aparelho': aparelho},
    ),
  );

  Future<void> cancelar(String endpoint) =>
      _chamar(() => _dio.post<void>('/notificacoes/cancelamento', data: {'endpoint': endpoint}));

  Future<int> enviarTeste() => _chamar(() async {
    final resposta = await _dio.post<Map<String, dynamic>>('/notificacoes/teste');
    return (resposta.data!['enviados'] as num).toInt();
  });

  Future<T> _chamar<T>(Future<T> Function() acao) async {
    try {
      return await acao();
    } on DioException catch (erro) {
      final dados = erro.response?.data;
      final titulo = dados is Map ? dados['title'] as String? : null;
      throw ErroNotificacoes(switch (erro.response?.statusCode) {
        null => 'Sem conexão com a internet.',
        429 => 'Muitos testes seguidos. Espere um minuto.',
        _ => titulo ?? 'Não deu para falar com o servidor agora.',
      });
    }
  }
}

final clienteNotificacoesProvider = Provider<ClienteNotificacoes>(
  (ref) => ClienteNotificacoes(ref.watch(dioApiProvider)),
);

final ponteNotificacoesProvider = Provider<PonteNotificacoes>((ref) => PonteNotificacoes());

class NotificacoesController extends AsyncNotifier<EstadoNotificacoes> {
  String? _chave;

  PonteNotificacoes get _ponte => ref.read(ponteNotificacoesProvider);

  ClienteNotificacoes get _cliente => ref.read(clienteNotificacoesProvider);

  @override
  Future<EstadoNotificacoes> build() async {
    final estado = await _ponte.estado();
    if (estado == EstadoNotificacoes.desativado) {
      _cliente.chavePublica().then((chave) => _chave = chave, onError: (_) {});
    }
    return estado;
  }

  Future<String?> ativar() async {
    try {
      final chave = _chave ?? await _cliente.chavePublica();
      _chave = chave;
      final inscricao = await _ponte.ativar(chave);
      await _cliente.inscrever(inscricao, _ponte.aparelho());
      state = const AsyncData(EstadoNotificacoes.ativo);
      return null;
    } on ErroPermissao catch (erro) {
      if (erro.bloqueado) state = const AsyncData(EstadoNotificacoes.bloqueado);
      return erro.bloqueado ? null : 'Você não permitiu as notificações. Toque em Ativar de novo quando quiser.';
    } on ErroNotificacoes catch (erro) {
      return erro.mensagem;
    } catch (_) {
      return 'Não deu para ativar neste aparelho.';
    }
  }

  Future<String?> desativar() async {
    try {
      final endpoint = await _ponte.desativar();
      state = const AsyncData(EstadoNotificacoes.desativado);
      if (endpoint != null) await _cliente.cancelar(endpoint);
      return null;
    } on ErroNotificacoes catch (erro) {
      return erro.mensagem;
    } catch (_) {
      return 'Não deu para desativar agora.';
    }
  }

  Future<String> enviarTeste() async {
    try {
      final enviados = await _cliente.enviarTeste();
      return enviados == 1 ? 'Notificação enviada. Ela chega em alguns segundos.' : 'Enviada para $enviados aparelhos.';
    } on ErroNotificacoes catch (erro) {
      return erro.mensagem;
    }
  }
}

final notificacoesProvider = AsyncNotifierProvider<NotificacoesController, EstadoNotificacoes>(
  NotificacoesController.new,
);
