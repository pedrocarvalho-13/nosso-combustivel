import 'forma_pagamento.dart';
import 'registro_energia.dart';
import 'servico.dart';

enum TipoCusto {
  ipva('IPVA', 'IPVA'),
  licenciamento('Licenciamento', 'licenciamento'),
  seguro('Seguro', 'seguro'),
  multa('Multa', 'multa'),
  financiamento('Financiamento', 'financiamento'),
  estacionamento('Estacionamento', 'estacionamento'),
  pedagio('Pedágio', 'pedágio'),
  despachante('Despachante', 'despachante'),
  outro('Outro', 'custo');

  const TipoCusto(this.rotulo, this.nomeNaFrase);

  final String rotulo;
  final String nomeNaFrase;

  bool get rapido => this == estacionamento || this == pedagio;

  bool get temParcelas => this == ipva || this == seguro;

  bool get temAno => this == ipva || this == licenciamento;

  static TipoCusto de(Servico servico) =>
      values.where((t) => t.name == servico.categorias.firstOrNull).firstOrNull ?? outro;
}

enum DescontoMulta {
  nenhum('Sem desconto', 0),
  vinte('20% pagando até o vencimento', 20),
  sne('40% pelo SNE', 40);

  const DescontoMulta(this.rotulo, this.percentual);

  final String rotulo;
  final int percentual;

  int aplicar(int centavos) => (centavos * (100 - percentual) / 100).round();

  static DescontoMulta de(Object? nome) => values.where((d) => d.name == nome).firstOrNull ?? nenhum;
}

class ParcelaCusto {
  const ParcelaCusto({required this.numero, required this.vencimento, required this.valorCentavos, this.pagaEm});

  final int numero;
  final DateTime vencimento;
  final int valorCentavos;
  final DateTime? pagaEm;

  bool get paga => pagaEm != null;

  ParcelaCusto copiar({DateTime? vencimento, int? valorCentavos, DateTime? pagaEm, bool limparPagamento = false}) =>
      ParcelaCusto(
        numero: numero,
        vencimento: vencimento ?? this.vencimento,
        valorCentavos: valorCentavos ?? this.valorCentavos,
        pagaEm: limparPagamento ? null : (pagaEm ?? this.pagaEm),
      );

  Map<String, dynamic> paraJson() => {
    'n': numero,
    'vence': _dia(vencimento),
    'valor': valorCentavos,
    if (pagaEm != null) 'paga': _dia(pagaEm!),
  };

  static ParcelaCusto deJson(Map<String, dynamic> json) => ParcelaCusto(
    numero: (json['n'] as num).toInt(),
    vencimento: DateTime.parse(json['vence'] as String),
    valorCentavos: (json['valor'] as num).toInt(),
    pagaEm: json['paga'] == null ? null : DateTime.parse(json['paga'] as String),
  );

  static String _dia(DateTime data) =>
      '${data.year.toString().padLeft(4, '0')}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
}

class ContaCusto {
  const ContaCusto({required this.custo, required this.parcela, required this.totalParcelas});

  final Servico custo;
  final ParcelaCusto parcela;
  final int totalParcelas;

  TipoCusto get tipo => TipoCusto.de(custo);

  String get titulo {
    final base = CalculoCustos.titulo(custo);
    return totalParcelas > 1 ? '$base · ${parcela.numero}/$totalParcelas' : base;
  }
}

class ParcelaPaga implements GastoComPagamento {
  const ParcelaPaga({required this.custo, required this.parcela});

  final Servico custo;
  final ParcelaCusto parcela;

  @override
  DateTime get data => parcela.pagaEm!;

  @override
  int get valorCentavos => parcela.valorCentavos;

  @override
  FormaPagamento? get formaPagamento => custo.formaPagamento;

  @override
  String? get cartaoId => custo.cartaoId;

  @override
  int get parcelas => 1;
}

class ResumoCustos {
  const ResumoCustos({required this.atrasadas, required this.proximas, required this.aPagarCentavos});

  final List<ContaCusto> atrasadas;
  final List<ContaCusto> proximas;
  final int aPagarCentavos;

  int get quantidade => atrasadas.length + proximas.length;
}

abstract final class CalculoCustos {
  static const diasDoPainel = 30;

  static List<ParcelaCusto> parcelas(Servico custo) => [
    for (final item in (custo.detalhes['contas'] as List?) ?? const [])
      if (item is Map) ParcelaCusto.deJson(item.cast<String, dynamic>()),
  ]..sort((a, b) => a.numero.compareTo(b.numero));

  static List<ParcelaCusto> dividir({
    required int totalCentavos,
    required int vezes,
    required DateTime primeiroVencimento,
  }) {
    final quantidade = vezes < 1 ? 1 : vezes;
    final base = totalCentavos ~/ quantidade;
    final resto = totalCentavos - base * quantidade;
    return [
      for (var i = 0; i < quantidade; i++)
        ParcelaCusto(
          numero: i + 1,
          vencimento: _somarMeses(primeiroVencimento, i),
          valorCentavos: base + (i < resto ? 1 : 0),
        ),
    ];
  }

  static List<ParcelaCusto> financiamento({
    required int valorParcelaCentavos,
    required int parcelaAtual,
    required int totalParcelas,
    required DateTime proximoVencimento,
  }) {
    final inicio = parcelaAtual < 1 ? 1 : parcelaAtual;
    return [
      for (var n = inicio; n <= totalParcelas; n++)
        ParcelaCusto(
          numero: n,
          vencimento: _somarMeses(proximoVencimento, n - inicio),
          valorCentavos: valorParcelaCentavos,
        ),
    ];
  }

  static List<ContaCusto> contas(Servico custo) {
    final lista = parcelas(custo);
    final total = TipoCusto.de(custo) == TipoCusto.financiamento
        ? (custo.detalhes['totalParcelas'] as num?)?.toInt() ?? lista.length
        : lista.length;
    return [for (final p in lista) ContaCusto(custo: custo, parcela: p, totalParcelas: total)];
  }

  static List<GastoComPagamento> gastos(Iterable<Servico> custos) => [
    for (final custo in custos)
      for (final parcela in parcelas(custo))
        if (parcela.paga) ParcelaPaga(custo: custo, parcela: parcela),
  ];

  static ResumoCustos resumo(Iterable<Servico> custos, DateTime agora) {
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final limite = hoje.add(const Duration(days: diasDoPainel));
    final abertas = [
      for (final custo in custos)
        for (final conta in contas(custo))
          if (!conta.parcela.paga && !conta.parcela.vencimento.isAfter(limite)) conta,
    ]..sort((a, b) => a.parcela.vencimento.compareTo(b.parcela.vencimento));
    final atrasadas = abertas.where((c) => c.parcela.vencimento.isBefore(hoje)).toList();
    final proximas = abertas.where((c) => !c.parcela.vencimento.isBefore(hoje)).toList();
    return ResumoCustos(
      atrasadas: atrasadas,
      proximas: proximas,
      aPagarCentavos: abertas.fold(0, (soma, c) => soma + c.parcela.valorCentavos),
    );
  }

  static int diasPara(DateTime data, DateTime agora) =>
      DateTime(data.year, data.month, data.day).difference(DateTime(agora.year, agora.month, agora.day)).inDays;

  static String titulo(Servico custo) {
    final tipo = TipoCusto.de(custo);
    final detalhes = custo.detalhes;
    final ano = (detalhes['ano'] as num?)?.toInt();
    final descricao = (detalhes['descricao'] as String?)?.trim();
    final complemento = switch (tipo) {
      TipoCusto.ipva || TipoCusto.licenciamento => ano?.toString(),
      TipoCusto.seguro => (detalhes['seguradora'] as String?)?.trim(),
      TipoCusto.multa => (detalhes['infracao'] as String?)?.trim(),
      TipoCusto.financiamento || TipoCusto.despachante || TipoCusto.outro => descricao,
      TipoCusto.estacionamento || TipoCusto.pedagio => custo.lugarNome,
    };
    if (complemento == null || complemento.isEmpty) return tipo.rotulo;
    return tipo.temAno ? '${tipo.rotulo} $complemento' : '${tipo.rotulo} · $complemento';
  }

  static Servico marcarPaga(Servico custo, int numero, DateTime? pagaEm) {
    final atualizadas = [
      for (final p in parcelas(custo))
        p.numero == numero ? p.copiar(pagaEm: pagaEm, limparPagamento: pagaEm == null) : p,
    ];
    return comParcelas(custo, atualizadas);
  }

  static Servico comParcelas(Servico custo, List<ParcelaCusto> parcelas) => Servico(
    id: custo.id,
    veiculoId: custo.veiculoId,
    tipo: custo.tipo,
    data: custo.data,
    categorias: custo.categorias,
    valorCentavos: custo.valorCentavos,
    detalhes: {
      ...custo.detalhes,
      'contas': [for (final p in parcelas) p.paraJson()],
    },
    lugarId: custo.lugarId,
    lugarNome: custo.lugarNome,
    formaPagamento: custo.formaPagamento,
    cartaoId: custo.cartaoId,
    observacao: custo.observacao,
  );

  static DateTime _somarMeses(DateTime data, int meses) {
    final alvo = DateTime(data.year, data.month + meses);
    final ultimoDia = DateTime(alvo.year, alvo.month + 1, 0).day;
    return DateTime(alvo.year, alvo.month, data.day > ultimoDia ? ultimoDia : data.day);
  }
}
