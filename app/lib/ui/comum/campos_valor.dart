import 'package:flutter/material.dart';

import '../../core/formato.dart';

class CamposValor {
  CamposValor() {
    quantidade.addListener(_aoMudarQuantidadeOuPreco);
    preco.addListener(_aoMudarQuantidadeOuPreco);
    total.addListener(_aoMudarTotal);
  }

  final quantidade = TextEditingController();
  final preco = TextEditingController();
  final total = TextEditingController();
  var _atualizando = false;

  double? get valorQuantidade => Formato.lerDecimal(quantidade.text);
  double? get valorPreco => Formato.lerDecimal(preco.text);
  double? get valorTotal => Formato.lerDecimal(total.text);

  void _aoMudarQuantidadeOuPreco() {
    if (_atualizando) return;
    final q = valorQuantidade;
    final p = valorPreco;
    if (q == null || p == null) return;
    _escrever(total, Formato.paraCampo(q * p));
  }

  void _aoMudarTotal() {
    if (_atualizando) return;
    final t = valorTotal;
    final p = valorPreco;
    if (t == null || p == null || p <= 0) return;
    _escrever(quantidade, Formato.paraCampo(t / p, casas: 3));
  }

  void preencher({double? quantidadeLida, double? precoLido, double? totalLido}) {
    if (precoLido != null) preco.text = Formato.paraCampo(precoLido, casas: 3);
    if (quantidadeLida != null) {
      quantidade.text = Formato.paraCampo(quantidadeLida, casas: 3);
      if (precoLido == null && totalLido != null) _escrever(total, Formato.paraCampo(totalLido));
    } else if (totalLido != null) {
      total.text = Formato.paraCampo(totalLido);
    }
  }

  void _escrever(TextEditingController controle, String texto) {
    _atualizando = true;
    controle.text = texto;
    _atualizando = false;
  }

  void dispose() {
    quantidade.dispose();
    preco.dispose();
    total.dispose();
  }
}
