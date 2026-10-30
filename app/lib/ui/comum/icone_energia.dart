import 'package:flutter/material.dart';

import '../../core/tema/paleta_energia.dart';
import '../../domain/registro_energia.dart';
import '../../domain/tipo_energia.dart';
import '../../domain/tipo_veiculo.dart';
import '../../domain/veiculo.dart';

IconData iconeDoTipo(TipoEnergia tipo) => switch (tipo) {
      TipoEnergia.combustao => Icons.local_gas_station_outlined,
      TipoEnergia.hibridoComum || TipoEnergia.hibridoPlugin => Icons.electric_car_outlined,
      TipoEnergia.eletrico => Icons.bolt,
    };

IconData iconeDoVeiculo(Veiculo veiculo) =>
    veiculo.tipoVeiculo == TipoVeiculo.moto ? Icons.two_wheeler : iconeDoTipo(veiculo.tipoEnergia);

IconData iconeDoRegistro(RegistroEnergia registro) => switch (registro) {
      Abastecimento() => Icons.local_gas_station_outlined,
      Recarga(local: LocalRecarga.casa) => Icons.home_outlined,
      Recarga() => Icons.bolt,
    };

class IconeEnergia extends StatelessWidget {
  const IconeEnergia({super.key, required this.icone, this.tipo, this.tamanho = 36});

  final IconData icone;
  final TipoEnergia? tipo;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final cor = tipo == null ? Theme.of(context).colorScheme.primary : PaletaEnergia.de(tipo!).principal;
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(tamanho * 0.28),
      ),
      child: Icon(icone, color: cor, size: tamanho * 0.5),
    );
  }
}
