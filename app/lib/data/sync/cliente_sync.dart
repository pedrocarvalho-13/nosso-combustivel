import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sessao/sessao_controller.dart';

class InterceptorSessao extends QueuedInterceptor {
  InterceptorSessao(this._ref);

  static const _antecedencia = Duration(seconds: 30);
  static const _repetida = 'repetida';

  final Ref _ref;
  final _repeticao = Dio();

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    var sessao = _ref.read(sessaoProvider).value;
    if (sessao != null && sessao.acessoExpiraEm.isBefore(DateTime.now().add(_antecedencia))) {
      sessao = await _ref.read(sessaoProvider.notifier).renovar();
    }
    if (sessao != null) options.headers['Authorization'] = 'Bearer ${sessao.tokenAcesso}';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final opcoes = err.requestOptions;
    if (err.response?.statusCode != 401 || opcoes.extra[_repetida] == true) return handler.next(err);

    final nova = await _ref.read(sessaoProvider.notifier).renovar();
    if (nova == null) return handler.next(err);
    try {
      opcoes
        ..extra[_repetida] = true
        ..headers['Authorization'] = 'Bearer ${nova.tokenAcesso}';
      handler.resolve(await _repeticao.fetch<dynamic>(opcoes));
    } on DioException catch (novoErro) {
      handler.next(novoErro);
    }
  }
}

class ClienteSync {
  ClienteSync(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> enviar(Map<String, dynamic> lote) async {
    final resposta = await _dio.post<Map<String, dynamic>>('/sync', data: lote);
    return (resposta.data!['rejeitados'] as List).cast<Map<String, dynamic>>();
  }

  Future<({Map<String, dynamic> alteracoes, String cursor})> buscar(DateTime? desde) async {
    final resposta = await _dio.get<Map<String, dynamic>>(
      '/sync',
      queryParameters: {if (desde != null) 'desde': desde.toUtc().toIso8601String()},
    );
    return (
      alteracoes: resposta.data!['alteracoes'] as Map<String, dynamic>,
      cursor: resposta.data!['cursor'] as String,
    );
  }
}

final dioApiProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: urlApi,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );
  dio.interceptors.add(InterceptorSessao(ref));
  return dio;
});

final clienteSyncProvider = Provider<ClienteSync>((ref) => ClienteSync(ref.watch(dioApiProvider)));
