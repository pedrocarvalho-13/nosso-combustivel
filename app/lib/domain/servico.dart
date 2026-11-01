import 'forma_pagamento.dart';
import 'registro_energia.dart';

enum TipoServico { manutencao, estetica, custo }

class Servico implements GastoComPagamento {
  const Servico({
    required this.id,
    required this.veiculoId,
    required this.tipo,
    required this.data,
    required this.categorias,
    required this.valorCentavos,
    this.odometro,
    this.detalhes = const {},
    this.pecasCentavos,
    this.maoDeObraCentavos,
    this.lugarId,
    this.lugarNome,
    this.formaPagamento,
    this.cartaoId,
    this.observacao,
  });

  final String id;
  final String veiculoId;
  final TipoServico tipo;
  @override
  final DateTime data;
  final int? odometro;
  final List<String> categorias;
  final Map<String, dynamic> detalhes;
  @override
  final int valorCentavos;
  final int? pecasCentavos;
  final int? maoDeObraCentavos;
  final String? lugarId;
  final String? lugarNome;
  @override
  final FormaPagamento? formaPagamento;
  @override
  final String? cartaoId;
  final String? observacao;

  @override
  int get parcelas {
    if (tipo == TipoServico.custo) return 1;
    final valor = (detalhes['parcelas'] as num?)?.toInt() ?? 1;
    return formaPagamento == FormaPagamento.credito && valor > 1 ? valor : 1;
  }

  Map<String, dynamic> detalhesDe(String categoria) =>
      (detalhes[categoria] as Map?)?.cast<String, dynamic>() ?? const {};
}
