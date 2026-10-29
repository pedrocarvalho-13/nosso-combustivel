import 'package:drift/drift.dart';

import '../../domain/combustivel.dart';
import '../../domain/veiculo.dart';
import '../banco/banco_local.dart';

class VeiculoRepositorio {
  VeiculoRepositorio(this._banco, this._agora);

  final BancoLocal _banco;
  final DateTime Function() _agora;

  Stream<List<Veiculo>> observarTodos() {
    final consulta = _banco.select(_banco.veiculos)
      ..where((v) => v.excluidoEm.isNull())
      ..orderBy([(v) => OrderingTerm.asc(v.criadoEm)]);
    return consulta.watch().map((linhas) => linhas.map(_paraDominio).toList());
  }

  Future<void> salvar(Veiculo veiculo) async {
    final agora = _agora();
    await _banco.into(_banco.veiculos).insert(
          VeiculosCompanion.insert(
            id: veiculo.id,
            criadoEm: agora,
            atualizadoEm: agora,
            apelido: veiculo.apelido,
            marca: veiculo.marca,
            modelo: veiculo.modelo,
            ano: Value(veiculo.ano),
            codigoFipe: Value(veiculo.codigoFipe),
            tipoEnergia: veiculo.tipoEnergia,
            combustiveis: veiculo.combustiveis.map((c) => c.name).join(','),
            capacidadeTanqueMl: Value(_milesimos(veiculo.capacidadeTanqueL)),
            capacidadeBateriaWh: Value(_milesimos(veiculo.capacidadeBateriaKwh)),
            odometroInicial: veiculo.odometroInicial,
          ),
          onConflict: DoUpdate((_) => VeiculosCompanion(
                atualizadoEm: Value(agora),
                apelido: Value(veiculo.apelido),
                capacidadeTanqueMl: Value(_milesimos(veiculo.capacidadeTanqueL)),
                capacidadeBateriaWh: Value(_milesimos(veiculo.capacidadeBateriaKwh)),
              )),
        );
  }

  static Veiculo _paraDominio(VeiculoLinha linha) => Veiculo(
        id: linha.id,
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

  static int? _milesimos(double? valor) => valor == null ? null : (valor * 1000).round();
}
