import 'package:drift/drift.dart';

import '../../domain/combustivel.dart';
import '../../domain/registro_energia.dart';
import '../../domain/tipo_energia.dart';
import '../../domain/tipo_veiculo.dart';
import '../banco/banco_local.dart';

class LoteLocal {
  const LoteLocal({required this.veiculos, required this.abastecimentos, required this.recargas});

  final List<VeiculoLinha> veiculos;
  final List<AbastecimentoLinha> abastecimentos;
  final List<RecargaLinha> recargas;

  bool get vazio => veiculos.isEmpty && abastecimentos.isEmpty && recargas.isEmpty;

  Map<String, dynamic> paraJson() => {
        'veiculos': [
          for (final v in veiculos)
            {
              'id': v.id,
              'tipoVeiculo': v.tipoVeiculo.name,
              'apelido': v.apelido,
              'marca': v.marca,
              'modelo': v.modelo,
              'ano': v.ano,
              'codigoFipe': v.codigoFipe,
              'tipoEnergia': v.tipoEnergia.name,
              'combustiveis': v.combustiveis.isEmpty ? <String>[] : v.combustiveis.split(','),
              'capacidadeTanqueL': _decimal(v.capacidadeTanqueMl),
              'capacidadeBateriaKwh': _decimal(v.capacidadeBateriaWh),
              'odometroInicial': v.odometroInicial,
              ..._datas(v.criadoEm, v.atualizadoEm, v.excluidoEm),
            },
        ],
        'abastecimentos': [
          for (final a in abastecimentos)
            {
              'id': a.id,
              'veiculoId': a.veiculoId,
              'data': _data(a.data),
              'odometro': a.odometro,
              'combustivel': a.combustivel.name,
              'litros': a.litrosMl / 1000,
              'precoLitro': a.precoLitroMilesimos / 1000,
              'valorTotal': a.valorCentavos / 100,
              'tanqueCheio': a.tanqueCheio,
              'posto': a.posto,
              ..._datas(a.criadoEm, a.atualizadoEm, a.excluidoEm),
            },
        ],
        'recargas': [
          for (final r in recargas)
            {
              'id': r.id,
              'veiculoId': r.veiculoId,
              'data': _data(r.data),
              'odometro': r.odometro,
              'local': r.local.name,
              'kwh': r.energiaWh / 1000,
              'precoKwh': r.precoKwhMilesimos / 1000,
              'valorTotal': r.valorCentavos / 100,
              'cargaCompleta': r.cargaCompleta,
              ..._datas(r.criadoEm, r.atualizadoEm, r.excluidoEm),
            },
        ],
      };

  static double? _decimal(int? milesimos) => milesimos == null ? null : milesimos / 1000;

  static String _data(DateTime data) => data.toUtc().toIso8601String();

  static Map<String, dynamic> _datas(DateTime criadoEm, DateTime atualizadoEm, DateTime? excluidoEm) => {
        'criadoEm': _data(criadoEm),
        'atualizadoEm': _data(atualizadoEm),
        'excluidoEm': excluidoEm == null ? null : _data(excluidoEm),
      };
}

class SincronizacaoLocal {
  SincronizacaoLocal(this._banco);

  final BancoLocal _banco;

  Future<LoteLocal> pendentes(String usuarioId) async {
    final ids = await _idsDosVeiculos(usuarioId);
    return LoteLocal(
      veiculos: await (_banco.select(_banco.veiculos)
            ..where((v) => v.usuarioId.equals(usuarioId) & v.pendente.equals(true)))
          .get(),
      abastecimentos: await (_banco.select(_banco.abastecimentos)
            ..where((a) => a.veiculoId.isIn(ids) & a.pendente.equals(true)))
          .get(),
      recargas: await (_banco.select(_banco.recargas)
            ..where((r) => r.veiculoId.isIn(ids) & r.pendente.equals(true)))
          .get(),
    );
  }

  Stream<int> observarQuantidadePendente(String usuarioId) async* {
    yield await _contarPendentes(usuarioId);
    final mudancas = _banco.tableUpdates(
      TableUpdateQuery.onAllTables([_banco.veiculos, _banco.abastecimentos, _banco.recargas]),
    );
    await for (final _ in mudancas) {
      yield await _contarPendentes(usuarioId);
    }
  }

  Future<void> marcarEnviados(LoteLocal lote) => _banco.transaction(() async {
        for (final v in lote.veiculos) {
          await (_banco.update(_banco.veiculos)..where((t) => t.id.equals(v.id) & t.atualizadoEm.equals(v.atualizadoEm)))
              .write(const VeiculosCompanion(pendente: Value(false)));
        }
        for (final a in lote.abastecimentos) {
          await (_banco.update(_banco.abastecimentos)
                ..where((t) => t.id.equals(a.id) & t.atualizadoEm.equals(a.atualizadoEm)))
              .write(const AbastecimentosCompanion(pendente: Value(false)));
        }
        for (final r in lote.recargas) {
          await (_banco.update(_banco.recargas)..where((t) => t.id.equals(r.id) & t.atualizadoEm.equals(r.atualizadoEm)))
              .write(const RecargasCompanion(pendente: Value(false)));
        }
      });

  Future<void> aplicarDoServidor(Map<String, dynamic> alteracoes, String usuarioId) => _banco.transaction(() async {
        for (final json in (alteracoes['veiculos'] as List).cast<Map<String, dynamic>>()) {
          final local = await (_banco.select(_banco.veiculos)..where((t) => t.id.equals(json['id'] as String))).getSingleOrNull();
          if (_localMaisNovo(local?.pendente, local?.atualizadoEm, json)) continue;
          await _banco.into(_banco.veiculos).insertOnConflictUpdate(VeiculosCompanion.insert(
                id: json['id'] as String,
                usuarioId: Value(usuarioId),
                tipoVeiculo: Value(TipoVeiculo.values.byName((json['tipoVeiculo'] as String?) ?? 'carro')),
                apelido: json['apelido'] as String,
                marca: json['marca'] as String,
                modelo: json['modelo'] as String,
                ano: Value(json['ano'] as int?),
                codigoFipe: Value(json['codigoFipe'] as String?),
                tipoEnergia: TipoEnergia.values.byName(json['tipoEnergia'] as String),
                combustiveis: (json['combustiveis'] as List).cast<String>().map(Combustivel.values.byName).map((c) => c.name).join(','),
                capacidadeTanqueMl: Value(_milesimos(json['capacidadeTanqueL'])),
                capacidadeBateriaWh: Value(_milesimos(json['capacidadeBateriaKwh'])),
                odometroInicial: json['odometroInicial'] as int,
                criadoEm: _lerData(json['criadoEm'])!,
                atualizadoEm: _lerData(json['atualizadoEm'])!,
                excluidoEm: Value(_lerData(json['excluidoEm'])),
                pendente: const Value(false),
              ));
        }
        for (final json in (alteracoes['abastecimentos'] as List).cast<Map<String, dynamic>>()) {
          final local =
              await (_banco.select(_banco.abastecimentos)..where((t) => t.id.equals(json['id'] as String))).getSingleOrNull();
          if (_localMaisNovo(local?.pendente, local?.atualizadoEm, json)) continue;
          await _banco.into(_banco.abastecimentos).insertOnConflictUpdate(AbastecimentosCompanion.insert(
                id: json['id'] as String,
                veiculoId: json['veiculoId'] as String,
                data: _lerData(json['data'])!,
                odometro: json['odometro'] as int,
                combustivel: Combustivel.values.byName(json['combustivel'] as String),
                litrosMl: _milesimos(json['litros'])!,
                precoLitroMilesimos: _milesimos(json['precoLitro'])!,
                valorCentavos: ((json['valorTotal'] as num) * 100).round(),
                tanqueCheio: json['tanqueCheio'] as bool,
                posto: Value(json['posto'] as String?),
                criadoEm: _lerData(json['criadoEm'])!,
                atualizadoEm: _lerData(json['atualizadoEm'])!,
                excluidoEm: Value(_lerData(json['excluidoEm'])),
                pendente: const Value(false),
              ));
        }
        for (final json in (alteracoes['recargas'] as List).cast<Map<String, dynamic>>()) {
          final local = await (_banco.select(_banco.recargas)..where((t) => t.id.equals(json['id'] as String))).getSingleOrNull();
          if (_localMaisNovo(local?.pendente, local?.atualizadoEm, json)) continue;
          await _banco.into(_banco.recargas).insertOnConflictUpdate(RecargasCompanion.insert(
                id: json['id'] as String,
                veiculoId: json['veiculoId'] as String,
                data: _lerData(json['data'])!,
                odometro: json['odometro'] as int,
                local: LocalRecarga.values.byName(json['local'] as String),
                energiaWh: _milesimos(json['kwh'])!,
                precoKwhMilesimos: _milesimos(json['precoKwh'])!,
                valorCentavos: ((json['valorTotal'] as num) * 100).round(),
                cargaCompleta: json['cargaCompleta'] as bool,
                criadoEm: _lerData(json['criadoEm'])!,
                atualizadoEm: _lerData(json['atualizadoEm'])!,
                excluidoEm: Value(_lerData(json['excluidoEm'])),
                pendente: const Value(false),
              ));
        }
      });

  Future<DateTime?> cursor(String usuarioId) async {
    final linha = await (_banco.select(_banco.preferencias)..where((p) => p.chave.equals(_chaveCursor(usuarioId))))
        .getSingleOrNull();
    return linha == null ? null : DateTime.parse(linha.valor);
  }

  Future<void> gravarCursor(String usuarioId, String cursor) => _banco
      .into(_banco.preferencias)
      .insertOnConflictUpdate(PreferenciasCompanion.insert(chave: _chaveCursor(usuarioId), valor: cursor));

  Future<List<String>> _idsDosVeiculos(String usuarioId) async {
    final consulta = _banco.selectOnly(_banco.veiculos)
      ..addColumns([_banco.veiculos.id])
      ..where(_banco.veiculos.usuarioId.equals(usuarioId));
    return consulta.map((linha) => linha.read(_banco.veiculos.id)!).get();
  }

  Future<int> _contarPendentes(String usuarioId) async {
    final lote = await pendentes(usuarioId);
    return lote.veiculos.length + lote.abastecimentos.length + lote.recargas.length;
  }

  static bool _localMaisNovo(bool? pendente, DateTime? atualizadoEm, Map<String, dynamic> json) =>
      pendente == true && atualizadoEm != null && atualizadoEm.isAfter(_lerData(json['atualizadoEm'])!);

  static String _chaveCursor(String usuarioId) => 'sync_cursor_$usuarioId';

  static int? _milesimos(Object? valor) => valor == null ? null : ((valor as num) * 1000).round();

  static DateTime? _lerData(Object? valor) => valor == null ? null : DateTime.parse(valor as String).toLocal();
}
