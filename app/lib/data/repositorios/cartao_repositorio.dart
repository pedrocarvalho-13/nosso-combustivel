import 'package:drift/drift.dart';

import '../../domain/cartao.dart';
import '../banco/banco_local.dart';

class CartaoRepositorio {
  CartaoRepositorio(this._banco, this._agora);

  final BancoLocal _banco;
  final DateTime Function() _agora;

  Stream<List<Cartao>> observarDoUsuario(String usuarioId) {
    final consulta = _banco.select(_banco.cartoes)
      ..where((c) => c.usuarioId.equals(usuarioId) & c.excluidoEm.isNull())
      ..orderBy([(c) => OrderingTerm.asc(c.nome)]);
    return consulta.watch().map((linhas) => linhas.map(_paraDominio).toList());
  }

  Future<void> salvar(Cartao cartao, {required String usuarioId}) async {
    final agora = _agora();
    final existente = await (_banco.select(_banco.cartoes)..where((c) => c.id.equals(cartao.id))).getSingleOrNull();
    await _banco.into(_banco.cartoes).insertOnConflictUpdate(CartoesCompanion.insert(
          id: cartao.id,
          usuarioId: usuarioId,
          nome: cartao.nome.trim(),
          banco: Value(cartao.banco == null || cartao.banco!.trim().isEmpty ? null : cartao.banco!.trim()),
          diaFechamento: cartao.diaFechamento,
          criadoEm: existente?.criadoEm ?? agora,
          atualizadoEm: agora,
          pendente: const Value(true),
        ));
  }

  Future<void> restaurar(String id) {
    final agora = _agora();
    return (_banco.update(_banco.cartoes)..where((c) => c.id.equals(id)))
        .write(CartoesCompanion(excluidoEm: const Value(null), atualizadoEm: Value(agora), pendente: const Value(true)));
  }

  Future<void> excluir(String id) {
    final agora = _agora();
    return (_banco.update(_banco.cartoes)..where((c) => c.id.equals(id)))
        .write(CartoesCompanion(excluidoEm: Value(agora), atualizadoEm: Value(agora), pendente: const Value(true)));
  }

  static Cartao _paraDominio(CartaoLinha linha) =>
      Cartao(id: linha.id, nome: linha.nome, diaFechamento: linha.diaFechamento, banco: linha.banco);
}
