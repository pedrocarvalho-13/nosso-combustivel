import 'ponte_notificacoes.dart';

PonteNotificacoes criarPonteNotificacoes() => const _PonteSemSuporte();

class _PonteSemSuporte implements PonteNotificacoes {
  const _PonteSemSuporte();

  @override
  Future<EstadoNotificacoes> estado() async => EstadoNotificacoes.semSuporte;

  @override
  Future<InscricaoAparelho> ativar(String chavePublica) => throw UnsupportedError('Sem notificações aqui.');

  @override
  Future<String?> desativar() async => null;

  @override
  String aparelho() => 'Aparelho';
}
