import 'package:flutter/material.dart';

import '../../domain/tipo_energia.dart';

class PaletaEnergia {
  const PaletaEnergia({
    required this.principal,
    required this.escura,
    required this.clara,
  });

  final Color principal;
  final Color escura;
  final Color clara;

  static const combustao = PaletaEnergia(
    principal: Color(0xFFF97316),
    escura: Color(0xFFC2410C),
    clara: Color(0xFFFFEDD5),
  );

  static const hibrido = PaletaEnergia(
    principal: Color(0xFF3B82F6),
    escura: Color(0xFF1D4ED8),
    clara: Color(0xFFDBEAFE),
  );

  static const eletrico = PaletaEnergia(
    principal: Color(0xFF10B981),
    escura: Color(0xFF047857),
    clara: Color(0xFFD1FAE5),
  );

  static PaletaEnergia de(TipoEnergia tipo) => switch (tipo) {
        TipoEnergia.combustao => combustao,
        TipoEnergia.hibridoComum || TipoEnergia.hibridoPlugin => hibrido,
        TipoEnergia.eletrico => eletrico,
      };
}
