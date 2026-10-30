import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/ia/cliente_ia.dart';

class BotaoLerFoto extends ConsumerStatefulWidget {
  const BotaoLerFoto({super.key, required this.tipo, required this.aoLer});

  final TipoLeitura tipo;
  final void Function(LeituraFoto leitura) aoLer;

  @override
  ConsumerState<BotaoLerFoto> createState() => _BotaoLerFotoState();
}

class _BotaoLerFotoState extends ConsumerState<BotaoLerFoto> {
  var _lendo = false;

  void _avisar(String mensagem) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));

  Future<ImageSource?> _escolherOrigem() => showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    builder: (contexto) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Tirar foto'),
            onTap: () => Navigator.pop(contexto, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Escolher da galeria'),
            onTap: () => Navigator.pop(contexto, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );

  Future<void> _ler() async {
    final origem = await _escolherOrigem();
    if (origem == null) return;
    final foto = await ImagePicker().pickImage(source: origem, maxWidth: 1600, maxHeight: 1600, imageQuality: 80);
    if (foto == null || !mounted) return;
    setState(() => _lendo = true);
    try {
      final bytes = await foto.readAsBytes();
      final leitura = await ref.read(clienteIaProvider).lerFoto(bytes, _tipoMime(foto), widget.tipo);
      if (!mounted) return;
      widget.aoLer(leitura);
      _avisar('Valores preenchidos pela foto. Confira antes de salvar.');
    } on ErroIa catch (erro) {
      if (mounted) _avisar(erro.mensagem);
    } finally {
      if (mounted) setState(() => _lendo = false);
    }
  }

  static String _tipoMime(XFile foto) {
    final informado = foto.mimeType;
    if (informado != null && informado.startsWith('image/')) return informado;
    final nome = foto.name.toLowerCase();
    if (nome.endsWith('.png')) return 'image/png';
    if (nome.endsWith('.webp')) return 'image/webp';
    if (nome.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }

  @override
  Widget build(BuildContext context) {
    final texto = widget.tipo == TipoLeitura.abastecimento
        ? 'Foto da bomba, do comprovante ou do painel'
        : 'Foto do carregador, do comprovante ou do painel';
    return Tooltip(
      message: texto,
      child: OutlinedButton.icon(
        onPressed: _lendo ? null : _ler,
        icon: _lendo
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.document_scanner_outlined),
        label: Text(_lendo ? 'Lendo a foto...' : 'Preencher com foto'),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      ),
    );
  }
}
