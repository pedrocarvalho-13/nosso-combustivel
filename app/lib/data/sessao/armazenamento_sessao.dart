import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/sessao.dart';

abstract class ArmazenamentoSessao {
  Future<Sessao?> ler();
  Future<void> gravar(Sessao sessao);
  Future<void> limpar();
}

class ArmazenamentoSessaoSeguro implements ArmazenamentoSessao {
  static const _chave = 'sessao';

  final _armazenamento = const FlutterSecureStorage();

  @override
  Future<Sessao?> ler() async {
    try {
      final json = await _armazenamento.read(key: _chave);
      return json == null ? null : Sessao.deJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      await limpar();
      return null;
    }
  }

  @override
  Future<void> gravar(Sessao sessao) => _armazenamento.write(key: _chave, value: jsonEncode(sessao.paraJson()));

  @override
  Future<void> limpar() => _armazenamento.delete(key: _chave);
}
