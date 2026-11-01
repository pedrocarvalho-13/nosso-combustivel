import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/tema/cores_base.dart';
import '../../data/sync/sincronizacao_controller.dart';

class IndicadorSincronizacao extends ConsumerWidget {
  const IndicadorSincronizacao({super.key, this.alinharDireita = false});

  final bool alinharDireita;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(sincronizacaoProvider);
    final pendentes = ref.watch(pendentesProvider).value ?? 0;
    final esquema = Theme.of(context).colorScheme;
    final (icone, texto, cor) = _aparencia(estado, pendentes, esquema);

    final conteudo = Semantics(
      button: true,
      label: '$texto. Toque para sincronizar agora.',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: estado.situacao == SituacaoSync.sincronizando
            ? null
            : () => ref.read(sincronizacaoProvider.notifier).sincronizar(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: alinharDireita
              ? IntrinsicWidth(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _icone(estado, icone, cor),
                      const SizedBox(width: 6),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          texto,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cor),
                        ),
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    _icone(estado, icone, cor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        texto,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
    return conteudo;
  }

  static Widget _icone(EstadoSincronizacao estado, IconData icone, Color cor) =>
      estado.situacao == SituacaoSync.sincronizando
      ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: cor))
      : Icon(icone, size: 16, color: cor);

  static (IconData, String, Color) _aparencia(EstadoSincronizacao estado, int pendentes, ColorScheme esquema) {
    final quieta = esquema.onSurfaceVariant;
    final aguardando = pendentes == 1 ? '1 alteração aguardando' : '$pendentes alterações aguardando';
    return switch (estado.situacao) {
      SituacaoSync.sincronizando => (Icons.sync, 'Sincronizando…', quieta),
      SituacaoSync.semConexao => (
        Icons.cloud_off_outlined,
        pendentes > 0 ? 'Sem conexão · $aguardando' : 'Sem conexão com o servidor',
        quieta,
      ),
      SituacaoSync.erro => (Icons.error_outline, 'Não foi possível sincronizar · tocar para tentar', CoresBase.alerta),
      SituacaoSync.ocioso when estado.recusados > 0 => (
        Icons.warning_amber_rounded,
        'Sincronizado, mas ${estado.recusados} registro(s) recusado(s) pelo servidor',
        CoresBase.atencao,
      ),
      SituacaoSync.ocioso when pendentes > 0 => (Icons.cloud_upload_outlined, '$aguardando · sincronizar', quieta),
      SituacaoSync.ocioso when estado.ultimaEm != null => (
        Icons.cloud_done_outlined,
        'Sincronizado às ${_hora(estado.ultimaEm!)}',
        quieta,
      ),
      SituacaoSync.ocioso => (Icons.cloud_outlined, 'Toque para sincronizar', quieta),
    };
  }

  static String _hora(DateTime data) =>
      '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
}
