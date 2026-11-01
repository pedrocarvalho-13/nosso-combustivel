import 'package:drift/drift.dart';

import '../../domain/registro_energia.dart';
import '../banco/banco_local.dart';

class RegistroRepositorio {
  RegistroRepositorio(this._banco, this._agora);

  final BancoLocal _banco;
  final DateTime Function() _agora;

  Stream<List<RegistroEnergia>> observarDoVeiculo(String veiculoId) async* {
    yield await _carregar(veiculoId);
    final mudancas = _banco.tableUpdates(TableUpdateQuery.onAllTables([_banco.abastecimentos, _banco.recargas]));
    await for (final _ in mudancas) {
      yield await _carregar(veiculoId);
    }
  }

  Future<List<RegistroEnergia>> listarDoVeiculo(String veiculoId) => _carregar(veiculoId);

  Future<RegistroEnergia?> obter(String veiculoId, String id) async =>
      (await _carregar(veiculoId)).where((r) => r.id == id).firstOrNull;

  Future<void> salvarAbastecimento(Abastecimento abastecimento) async {
    final agora = _agora();
    await _banco.into(_banco.abastecimentos).insertOnConflictUpdate(AbastecimentosCompanion.insert(
          id: abastecimento.id,
          criadoEm: agora,
          atualizadoEm: agora,
          veiculoId: abastecimento.veiculoId,
          data: abastecimento.data,
          odometro: abastecimento.odometro,
          combustivel: abastecimento.combustivel,
          litrosMl: (abastecimento.litros * 1000).round(),
          precoLitroMilesimos: (abastecimento.precoLitro * 1000).round(),
          valorCentavos: abastecimento.valorCentavos,
          tanqueCheio: abastecimento.tanqueCheio,
          posto: Value(abastecimento.posto),
          postoId: Value(abastecimento.postoId),
          formaPagamento: Value(abastecimento.formaPagamento),
          cartaoId: Value(abastecimento.cartaoId),
          contaNaMedia: Value(abastecimento.contaNaMedia),
          pendente: const Value(true),
        ));
  }

  Future<void> salvarRecarga(Recarga recarga) async {
    final agora = _agora();
    await _banco.into(_banco.recargas).insertOnConflictUpdate(RecargasCompanion.insert(
          id: recarga.id,
          criadoEm: agora,
          atualizadoEm: agora,
          veiculoId: recarga.veiculoId,
          data: recarga.data,
          odometro: recarga.odometro,
          local: recarga.local,
          energiaWh: (recarga.kwh * 1000).round(),
          precoKwhMilesimos: (recarga.precoKwh * 1000).round(),
          valorCentavos: recarga.valorCentavos,
          cargaCompleta: recarga.cargaCompleta,
          formaPagamento: Value(recarga.formaPagamento),
          cartaoId: Value(recarga.cartaoId),
          contaNaMedia: Value(recarga.contaNaMedia),
          pendente: const Value(true),
        ));
  }

  Future<void> excluir(RegistroEnergia registro) async {
    final agora = _agora();
    switch (registro) {
      case Abastecimento():
        await (_banco.update(_banco.abastecimentos)..where((a) => a.id.equals(registro.id)))
            .write(AbastecimentosCompanion(excluidoEm: Value(agora), atualizadoEm: Value(agora), pendente: const Value(true)));
      case Recarga():
        await (_banco.update(_banco.recargas)..where((r) => r.id.equals(registro.id)))
            .write(RecargasCompanion(excluidoEm: Value(agora), atualizadoEm: Value(agora), pendente: const Value(true)));
    }
  }

  Future<List<RegistroEnergia>> _carregar(String veiculoId) async {
    final abastecimentos = await (_banco.select(_banco.abastecimentos)
          ..where((a) => a.veiculoId.equals(veiculoId) & a.excluidoEm.isNull()))
        .get();
    final recargas = await (_banco.select(_banco.recargas)
          ..where((r) => r.veiculoId.equals(veiculoId) & r.excluidoEm.isNull()))
        .get();

    final registros = <RegistroEnergia>[
      for (final a in abastecimentos)
        Abastecimento(
          id: a.id,
          veiculoId: a.veiculoId,
          data: a.data,
          odometro: a.odometro,
          valorCentavos: a.valorCentavos,
          combustivel: a.combustivel,
          litros: a.litrosMl / 1000,
          precoLitro: a.precoLitroMilesimos / 1000,
          tanqueCheio: a.tanqueCheio,
          posto: a.posto,
          postoId: a.postoId,
          formaPagamento: a.formaPagamento,
          cartaoId: a.cartaoId,
          contaNaMedia: a.contaNaMedia,
        ),
      for (final r in recargas)
        Recarga(
          id: r.id,
          veiculoId: r.veiculoId,
          data: r.data,
          odometro: r.odometro,
          valorCentavos: r.valorCentavos,
          local: r.local,
          kwh: r.energiaWh / 1000,
          precoKwh: r.precoKwhMilesimos / 1000,
          cargaCompleta: r.cargaCompleta,
          formaPagamento: r.formaPagamento,
          cartaoId: r.cartaoId,
          contaNaMedia: r.contaNaMedia,
        ),
    ];
    registros.sort((a, b) {
      final porData = b.data.compareTo(a.data);
      return porData != 0 ? porData : b.odometro.compareTo(a.odometro);
    });
    return registros;
  }
}
