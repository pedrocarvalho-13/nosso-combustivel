import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provedores.dart';
import '../sessao/sessao_controller.dart';
import 'cliente_sync.dart';
import 'sincronizacao_local.dart';

enum SituacaoSync { ocioso, sincronizando, semConexao, erro }

class EstadoSincronizacao {
  const EstadoSincronizacao({
    this.situacao = SituacaoSync.ocioso,
    this.ultimaEm,
    this.recusados = 0,
  });

  final SituacaoSync situacao;
  final DateTime? ultimaEm;
  final int recusados;
}

final sincronizacaoLocalProvider = Provider<SincronizacaoLocal>(
  (ref) => SincronizacaoLocal(ref.watch(bancoLocalProvider)),
);

final pendentesProvider = StreamProvider<int>((ref) {
  final usuarioId = ref.watch(sessaoProvider.select((s) => s.value?.usuario.id));
  if (usuarioId == null) return Stream.value(0);
  return ref.watch(sincronizacaoLocalProvider).observarQuantidadePendente(usuarioId);
});

class SincronizacaoController extends Notifier<EstadoSincronizacao> {
  static const _espera = Duration(seconds: 2);
  static const _novaTentativa = Duration(seconds: 60);

  Timer? _agendada;
  Timer? _periodica;
  var _emAndamento = false;

  @override
  EstadoSincronizacao build() {
    final usuarioId = ref.watch(sessaoProvider.select((s) => s.value?.usuario.id));
    if (usuarioId == null) return const EstadoSincronizacao();

    ref.listen(pendentesProvider, (_, pendentes) {
      if ((pendentes.value ?? 0) > 0) _agendar();
    });
    final ciclo = AppLifecycleListener(onResume: sincronizar);
    _periodica = Timer.periodic(_novaTentativa, (_) {
      if (state.situacao != SituacaoSync.ocioso || (ref.read(pendentesProvider).value ?? 0) > 0) sincronizar();
    });
    ref.onDispose(() {
      ciclo.dispose();
      _agendada?.cancel();
      _periodica?.cancel();
    });

    Future.microtask(sincronizar);
    return const EstadoSincronizacao();
  }

  void _agendar() {
    _agendada?.cancel();
    _agendada = Timer(_espera, sincronizar);
  }

  Future<void> sincronizar() async {
    final usuarioId = ref.read(sessaoProvider).value?.usuario.id;
    if (usuarioId == null || _emAndamento) return;
    _emAndamento = true;
    state = EstadoSincronizacao(situacao: SituacaoSync.sincronizando, ultimaEm: state.ultimaEm);

    final local = ref.read(sincronizacaoLocalProvider);
    final cliente = ref.read(clienteSyncProvider);
    try {
      final lote = await local.pendentes(usuarioId);
      var recusados = 0;
      if (!lote.vazio) {
        recusados = (await cliente.enviar(lote.paraJson())).length;
        await local.marcarEnviados(lote);
      }
      final busca = await cliente.buscar(await local.cursor(usuarioId));
      await local.aplicarDoServidor(busca.alteracoes, usuarioId);
      await local.gravarCursor(usuarioId, busca.cursor);
      if (ref.mounted) {
        state = EstadoSincronizacao(ultimaEm: DateTime.now(), recusados: recusados);
      }
    } on DioException catch (erro) {
      if (ref.mounted) {
        final semConexao = erro.response == null;
        state = EstadoSincronizacao(
          situacao: semConexao ? SituacaoSync.semConexao : SituacaoSync.erro,
          ultimaEm: state.ultimaEm,
        );
      }
    } on Object {
      if (ref.mounted) {
        state = EstadoSincronizacao(situacao: SituacaoSync.erro, ultimaEm: state.ultimaEm);
      }
    } finally {
      _emAndamento = false;
    }
  }
}

final sincronizacaoProvider =
    NotifierProvider<SincronizacaoController, EstadoSincronizacao>(SincronizacaoController.new);
