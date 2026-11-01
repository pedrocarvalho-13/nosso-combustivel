abstract final class HorarioPosto {
  static const _dias = {
    'Mo': 'Seg',
    'Tu': 'Ter',
    'We': 'Qua',
    'Th': 'Qui',
    'Fr': 'Sex',
    'Sa': 'Sáb',
    'Su': 'Dom',
    'PH': 'Feriado',
  };

  static String? legivel(String? bruto) {
    if (bruto == null || bruto.trim().isEmpty) return null;
    final texto = bruto.trim();
    if (texto == '24/7' || texto == 'Mo-Su 00:00-24:00') return 'Aberto 24 horas';
    var traduzido = texto;
    _dias.forEach((ingles, portugues) => traduzido = traduzido.replaceAll(RegExp('\\b$ingles\\b'), portugues));
    return traduzido
        .replaceAll(RegExp(r'\boff\b'), 'fechado')
        .replaceAll('00:00-24:00', '24 horas')
        .replaceAll(';', ' ·')
        .replaceAll(',', ', ');
  }
}
