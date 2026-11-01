import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/servico.dart';
import '../banco/banco_local.dart';

class ServicoRepositorio {
  ServicoRepositorio(this._banco, this._agora);

  final BancoLocal _banco;
  final DateTime Function() _agora;

  Stream<List<Servico>> observarDoVeiculo(String veiculoId, TipoServico tipo) {
    final consulta = _banco.select(_banco.servicos)
      ..where((s) => s.veiculoId.equals(veiculoId) & s.tipo.equals(tipo.name) & s.excluidoEm.isNull())
      ..orderBy([(s) => OrderingTerm.desc(s.data)]);
    return consulta.watch().map((linhas) => linhas.map(_paraDominio).toList());
  }

  Future<Servico?> obter(String id) async {
    final linha = await (_banco.select(_banco.servicos)..where((s) => s.id.equals(id))).getSingleOrNull();
    return linha == null || linha.excluidoEm != null ? null : _paraDominio(linha);
  }

  Future<void> salvar(Servico servico) async {
    final agora = _agora();
    final existente = await (_banco.select(_banco.servicos)..where((s) => s.id.equals(servico.id))).getSingleOrNull();
    await _banco.into(_banco.servicos).insertOnConflictUpdate(ServicosCompanion.insert(
          id: servico.id,
          veiculoId: servico.veiculoId,
          tipo: servico.tipo.name,
          data: servico.data,
          odometro: Value(servico.odometro),
          categorias: servico.categorias.join(','),
          detalhes: Value(servico.detalhes.isEmpty ? null : jsonEncode(servico.detalhes)),
          valorCentavos: servico.valorCentavos,
          pecasCentavos: Value(servico.pecasCentavos),
          maoDeObraCentavos: Value(servico.maoDeObraCentavos),
          lugarId: Value(servico.lugarId),
          lugarNome: Value(servico.lugarNome),
          formaPagamento: Value(servico.formaPagamento),
          cartaoId: Value(servico.cartaoId),
          observacao: Value(servico.observacao),
          criadoEm: existente?.criadoEm ?? agora,
          atualizadoEm: agora,
          pendente: const Value(true),
        ));
  }

  Future<void> excluir(String id) {
    final agora = _agora();
    return (_banco.update(_banco.servicos)..where((s) => s.id.equals(id)))
        .write(ServicosCompanion(excluidoEm: Value(agora), atualizadoEm: Value(agora), pendente: const Value(true)));
  }

  static Servico _paraDominio(ServicoLinha linha) => Servico(
        id: linha.id,
        veiculoId: linha.veiculoId,
        tipo: TipoServico.values.where((t) => t.name == linha.tipo).firstOrNull ?? TipoServico.manutencao,
        data: linha.data,
        odometro: linha.odometro,
        categorias: linha.categorias.isEmpty ? const [] : linha.categorias.split(','),
        detalhes: linha.detalhes == null ? const {} : (jsonDecode(linha.detalhes!) as Map).cast<String, dynamic>(),
        valorCentavos: linha.valorCentavos,
        pecasCentavos: linha.pecasCentavos,
        maoDeObraCentavos: linha.maoDeObraCentavos,
        lugarId: linha.lugarId,
        lugarNome: linha.lugarNome,
        formaPagamento: linha.formaPagamento,
        cartaoId: linha.cartaoId,
        observacao: linha.observacao,
      );
}
