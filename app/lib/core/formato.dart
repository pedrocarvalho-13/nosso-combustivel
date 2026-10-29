abstract final class Formato {
  static const _meses = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
  static const _mesesPorExtenso = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
  ];

  static String moeda(int centavos) {
    final reais = centavos.abs() ~/ 100;
    final resto = (centavos.abs() % 100).toString().padLeft(2, '0');
    return '${centavos < 0 ? '-' : ''}R\$ ${milhar(reais)},$resto';
  }

  static String moedaPorKm(double valor) => 'R\$ ${decimal(valor, casas: 2)}';

  static String milhar(int valor) {
    final digitos = valor.abs().toString();
    final saida = StringBuffer(valor < 0 ? '-' : '');
    for (var i = 0; i < digitos.length; i++) {
      if (i > 0 && (digitos.length - i) % 3 == 0) saida.write('.');
      saida.write(digitos[i]);
    }
    return saida.toString();
  }

  static String decimal(double valor, {int casas = 1}) {
    final partes = valor.toStringAsFixed(casas).split('.');
    final inteiro = milhar(int.parse(partes[0]));
    return casas == 0 ? inteiro : '$inteiro,${partes[1]}';
  }

  static String km(int km) => '${milhar(km)} km';

  static String dataCurta(DateTime data) => '${data.day.toString().padLeft(2, '0')} ${_meses[data.month - 1]}';

  static String dataCompleta(DateTime data) =>
      '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';

  static String mes(DateTime data) => _mesesPorExtenso[data.month - 1];

  static String mesAno(DateTime data) => '${_mesesPorExtenso[data.month - 1]} de ${data.year}';

  static double? lerDecimal(String texto) {
    var limpo = texto.trim().replaceAll(' ', '');
    if (limpo.isEmpty) return null;
    if (limpo.contains(',')) limpo = limpo.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(limpo);
  }

  static int? lerInteiro(String texto) {
    final digitos = texto.replaceAll(RegExp(r'[^0-9]'), '');
    return digitos.isEmpty ? null : int.parse(digitos);
  }

  static String paraCampo(double valor, {int casas = 2}) => valor.toStringAsFixed(casas).replaceAll('.', ',');
}
