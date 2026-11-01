import '../cartao.dart';
import '../forma_pagamento.dart';
import '../registro_energia.dart';

abstract final class CalculoFatura {
  static DateTime mesDoGasto(GastoComPagamento registro, Map<String, Cartao> cartoes) {
    final data = registro.data;
    final cartao = registro.cartaoId == null ? null : cartoes[registro.cartaoId];
    if (registro.formaPagamento != FormaPagamento.credito || cartao == null) return DateTime(data.year, data.month);
    final ultimoDia = DateTime(data.year, data.month + 1, 0).day;
    final fechamento = cartao.diaFechamento > ultimoDia ? ultimoDia : cartao.diaFechamento;
    return data.day >= fechamento ? DateTime(data.year, data.month + 1) : DateTime(data.year, data.month);
  }

  static int gastoDoMes(Iterable<GastoComPagamento> registros, Map<String, Cartao> cartoes, DateTime mes) {
    final alvo = DateTime(mes.year, mes.month);
    return registros.fold(0, (soma, r) => soma + valorNoMes(r, cartoes, alvo));
  }

  static int valorNoMes(GastoComPagamento registro, Map<String, Cartao> cartoes, DateTime mes) {
    final primeiro = mesDoGasto(registro, cartoes);
    final indice = (mes.year - primeiro.year) * 12 + mes.month - primeiro.month;
    final parcelas = registro.parcelas < 1 ? 1 : registro.parcelas;
    if (indice < 0 || indice >= parcelas) return 0;
    final base = registro.valorCentavos ~/ parcelas;
    final resto = registro.valorCentavos - base * parcelas;
    return base + (indice < resto ? 1 : 0);
  }
}
