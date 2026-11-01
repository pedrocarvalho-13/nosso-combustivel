import 'ponte_notificacoes_stub.dart' if (dart.library.js_interop) 'ponte_notificacoes_web.dart';

enum EstadoNotificacoes { semSuporte, instalar, bloqueado, desativado, ativo }

class InscricaoAparelho {
  const InscricaoAparelho({required this.endpoint, required this.p256dh, required this.auth});

  final String endpoint;
  final String p256dh;
  final String auth;
}

class ErroPermissao implements Exception {
  const ErroPermissao({required this.bloqueado});

  final bool bloqueado;
}

abstract interface class PonteNotificacoes {
  Future<EstadoNotificacoes> estado();

  Future<InscricaoAparelho> ativar(String chavePublica);

  Future<String?> desativar();

  String aparelho();

  factory PonteNotificacoes() => criarPonteNotificacoes();
}
