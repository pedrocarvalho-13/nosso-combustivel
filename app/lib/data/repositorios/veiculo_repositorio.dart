import 'package:drift/drift.dart';

import '../../domain/combustivel.dart';
import '../../domain/veiculo.dart';
import '../banco/banco_local.dart';

class VeiculoRepositorio {
  VeiculoRepositorio(this._banco, this._agora);

  final BancoLocal _banco;
  final DateTime Function() _agora;

  Stream<List<Veiculo>> observarDoUsuario(String usuarioId) {
    final consulta = _banco.select(_banco.veiculos)
      ..where((v) => v.excluidoEm.isNull() & v.usuarioId.equals(usuarioId))
      ..orderBy([(v) => OrderingTerm.asc(v.criadoEm)]);
    return consulta.watch().map((linhas) => linhas.map(_paraDominio).toList());
  }

  Future<Veiculo?> obter(String id) async {
    final linha = await (_banco.select(_banco.veiculos)..where((v) => v.id.equals(id) & v.excluidoEm.isNull()))
        .getSingleOrNull();
    return linha == null ? null : _paraDominio(linha);
  }

  Future<void> adotarSemDono(String usuarioId) =>
      (_banco.update(_banco.veiculos)..where((v) => v.usuarioId.isNull()))
          .write(VeiculosCompanion(
            usuarioId: Value(usuarioId),
            atualizadoEm: Value(_agora()),
            pendente: const Value(true),
          ));

  Future<void> salvar(Veiculo veiculo, {required String usuarioId}) async {
    final agora = _agora();
    await _banco.into(_banco.veiculos).insert(
          VeiculosCompanion.insert(
            id: veiculo.id,
            usuarioId: Value(usuarioId),
            criadoEm: agora,
            atualizadoEm: agora,
            tipoVeiculo: Value(veiculo.tipoVeiculo),
            apelido: veiculo.apelido,
            marca: veiculo.marca,
            modelo: veiculo.modelo,
            ano: Value(veiculo.ano),
            codigoFipe: Value(veiculo.codigoFipe),
            tipoEnergia: veiculo.tipoEnergia,
            combustiveis: _combustiveis(veiculo),
            capacidadeTanqueMl: Value(_milesimos(veiculo.capacidadeTanqueL)),
            capacidadeBateriaWh: Value(_milesimos(veiculo.capacidadeBateriaKwh)),
            odometroInicial: veiculo.odometroInicial,
          ),
          onConflict: DoUpdate((_) => _alteracao(veiculo, agora)),
        );
  }

  Future<void> atualizar(Veiculo veiculo) =>
      (_banco.update(_banco.veiculos)..where((v) => v.id.equals(veiculo.id))).write(_alteracao(veiculo, _agora()));

  Future<void> excluir(String id) => _banco.transaction(() async {
        final agora = _agora();
        await (_banco.update(_banco.veiculos)..where((v) => v.id.equals(id)))
            .write(VeiculosCompanion(excluidoEm: Value(agora), atualizadoEm: Value(agora), pendente: const Value(true)));
        await (_banco.update(_banco.abastecimentos)..where((a) => a.veiculoId.equals(id) & a.excluidoEm.isNull()))
            .write(AbastecimentosCompanion(excluidoEm: Value(agora), atualizadoEm: Value(agora), pendente: const Value(true)));
        await (_banco.update(_banco.recargas)..where((r) => r.veiculoId.equals(id) & r.excluidoEm.isNull()))
            .write(RecargasCompanion(excluidoEm: Value(agora), atualizadoEm: Value(agora), pendente: const Value(true)));
      });

  static VeiculosCompanion _alteracao(Veiculo veiculo, DateTime agora) => VeiculosCompanion(
        atualizadoEm: Value(agora),
        pendente: const Value(true),
        apelido: Value(veiculo.apelido),
        marca: Value(veiculo.marca),
        modelo: Value(veiculo.modelo),
        ano: Value(veiculo.ano),
        tipoEnergia: Value(veiculo.tipoEnergia),
        combustiveis: Value(_combustiveis(veiculo)),
        capacidadeTanqueMl: Value(_milesimos(veiculo.capacidadeTanqueL)),
        capacidadeBateriaWh: Value(_milesimos(veiculo.capacidadeBateriaKwh)),
        odometroInicial: Value(veiculo.odometroInicial),
      );

  static Veiculo _paraDominio(VeiculoLinha linha) => Veiculo(
        id: linha.id,
        tipoVeiculo: linha.tipoVeiculo,
        apelido: linha.apelido,
        marca: linha.marca,
        modelo: linha.modelo,
        ano: linha.ano,
        codigoFipe: linha.codigoFipe,
        tipoEnergia: linha.tipoEnergia,
        combustiveis: linha.combustiveis.isEmpty
            ? const []
            : linha.combustiveis.split(',').map(Combustivel.values.byName).toList(),
        capacidadeTanqueL: linha.capacidadeTanqueMl == null ? null : linha.capacidadeTanqueMl! / 1000,
        capacidadeBateriaKwh: linha.capacidadeBateriaWh == null ? null : linha.capacidadeBateriaWh! / 1000,
        odometroInicial: linha.odometroInicial,
      );

  static String _combustiveis(Veiculo veiculo) => veiculo.combustiveis.map((c) => c.name).join(',');

  static int? _milesimos(double? valor) => valor == null ? null : (valor * 1000).round();
}
