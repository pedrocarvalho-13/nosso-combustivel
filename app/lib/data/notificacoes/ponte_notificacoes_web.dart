import 'dart:convert';
import 'dart:js_interop';

import 'ponte_notificacoes.dart';

@JS('pitNotificacoes')
external JSObject? get _ponte;

@JS('pitNotificacoes.estado')
external JSPromise<JSString> _estado();

@JS('pitNotificacoes.ativar')
external JSPromise<JSString> _ativar(JSString chave);

@JS('pitNotificacoes.desativar')
external JSPromise<JSString> _desativar();

@JS('pitNotificacoes.aparelho')
external JSString _aparelho();

PonteNotificacoes criarPonteNotificacoes() => const _PonteWeb();

class _PonteWeb implements PonteNotificacoes {
  const _PonteWeb();

  @override
  Future<EstadoNotificacoes> estado() async {
    if (_ponte == null) return EstadoNotificacoes.semSuporte;
    final nome = (await _estado().toDart).toDart;
    return EstadoNotificacoes.values.where((e) => e.name == nome).firstOrNull ?? EstadoNotificacoes.semSuporte;
  }

  @override
  Future<InscricaoAparelho> ativar(String chavePublica) async {
    final json = jsonDecode((await _ativar(chavePublica.toJS).toDart).toDart) as Map<String, dynamic>;
    final erro = json['erro'];
    if (erro != null) throw ErroPermissao(bloqueado: erro == 'bloqueado');
    final chaves = (json['keys'] as Map).cast<String, dynamic>();
    return InscricaoAparelho(
      endpoint: json['endpoint'] as String,
      p256dh: chaves['p256dh'] as String,
      auth: chaves['auth'] as String,
    );
  }

  @override
  Future<String?> desativar() async {
    if (_ponte == null) return null;
    final endpoint = (await _desativar().toDart).toDart;
    return endpoint.isEmpty ? null : endpoint;
  }

  @override
  String aparelho() => _ponte == null ? 'Navegador' : _aparelho().toDart;
}
