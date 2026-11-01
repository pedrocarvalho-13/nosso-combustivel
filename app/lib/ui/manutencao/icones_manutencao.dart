import 'package:flutter/material.dart';

import '../../core/formato.dart';
import '../../domain/calculos/calculo_manutencao.dart';
import '../../domain/categoria_manutencao.dart';
import '../../domain/servico.dart';

IconData iconeDaCategoria(CategoriaManutencao categoria) => switch (categoria) {
      CategoriaManutencao.oleo => Icons.water_drop_outlined,
      CategoriaManutencao.filtros => Icons.filter_alt_outlined,
      CategoriaManutencao.pneus => Icons.tire_repair_outlined,
      CategoriaManutencao.freios => Icons.album_outlined,
      CategoriaManutencao.correias => Icons.settings_outlined,
      CategoriaManutencao.velas => Icons.flash_on_outlined,
      CategoriaManutencao.bateria => Icons.battery_charging_full_outlined,
      CategoriaManutencao.eletrica => Icons.lightbulb_outline,
      CategoriaManutencao.suspensao => Icons.height,
      CategoriaManutencao.arCondicionado => Icons.ac_unit,
      CategoriaManutencao.arrefecimento => Icons.thermostat_outlined,
      CategoriaManutencao.cambio => Icons.tune,
      CategoriaManutencao.lataria => Icons.car_crash_outlined,
      CategoriaManutencao.tapecaria => Icons.event_seat_outlined,
      CategoriaManutencao.relacao => Icons.link,
      CategoriaManutencao.bateriaAltaTensao => Icons.electric_bolt_outlined,
      CategoriaManutencao.revisao => Icons.fact_check_outlined,
      CategoriaManutencao.outro => Icons.more_horiz,
    };

String rotulosDosServicos(Servico servico) {
  final rotulos = [
    for (final nome in servico.categorias)
      if (CategoriaManutencao.porNome(nome) case final categoria?) categoria.rotulo,
  ];
  if (rotulos.isEmpty) return 'Manutenção';
  if (rotulos.length == 1) return rotulos.first;
  return '${rotulos.sublist(0, rotulos.length - 1).join(', ')} e ${rotulos.last}';
}

String haQuantoTempo(DateTime data, DateTime agora) {
  final dias = DateUtils.dateOnly(agora).difference(DateUtils.dateOnly(data)).inDays;
  if (dias <= 0) return 'hoje';
  if (dias == 1) return 'ontem';
  if (dias < 30) return 'há $dias dias';
  final meses = (dias / 30.4).floor();
  if (meses < 12) return meses == 1 ? 'há 1 mês' : 'há $meses meses';
  final anos = (meses / 12).floor();
  return anos == 1 ? 'há 1 ano' : 'há $anos anos';
}

String quandoVence(ProximaTroca troca) {
  final km = troca.faltaKm;
  final dias = troca.faltaDias;
  final porKm = km == null ? null : (km >= 0 ? 'em ${Formato.km(km)}' : 'passou ${Formato.km(-km)}');
  final porData = dias == null
      ? null
      : dias >= 0
          ? (dias < 45 ? 'em $dias dias' : 'em ${(dias / 30.4).round()} meses')
          : 'venceu há ${-dias} dias';
  if (troca.situacao == SituacaoTroca.vencida) {
    if (km != null && km < 0) return porKm!;
    return porData ?? porKm ?? '';
  }
  if (porKm != null && porData != null) {
    final fracaoKm = troca.proximaKm == null || troca.feitaKm == null
        ? 0
        : 1 - km! / (troca.proximaKm! - troca.feitaKm!);
    return fracaoKm >= troca.fracao - 0.001 ? porKm : porData;
  }
  return porKm ?? porData ?? '';
}
