import 'servico.dart';

enum ModalidadeEstetica {
  estetica('Levei numa estética', 'Lava-jato, estética automotiva'),
  casa('Lavei em casa', 'Usando produtos que já tenho'),
  produtos('Comprei produtos', 'Shampoo, cera, panos, aspirador...');

  const ModalidadeEstetica(this.rotulo, this.descricao);

  final String rotulo;
  final String descricao;

  static ModalidadeEstetica de(Servico servico) =>
      values.where((m) => m.name == servico.detalhes['modalidade']).firstOrNull ?? ModalidadeEstetica.estetica;
}

enum ServicoEstetica {
  lavagemSimples('Lavagem simples'),
  lavagemCompleta('Lavagem completa'),
  lavagemASeco('Lavagem a seco'),
  higienizacao('Higienização interna'),
  limpezaMotor('Limpeza de motor'),
  enceramento('Enceramento'),
  polimento('Polimento'),
  vitrificacao('Vitrificação'),
  oxiSanitizacao('Oxi-sanitização');

  const ServicoEstetica(this.rotulo);

  final String rotulo;
}

enum ParteLavagem {
  externa('Externa'),
  interna('Interna'),
  aspiracao('Aspiração'),
  pretinho('Pretinho nos pneus'),
  cera('Cera'),
  vidros('Vidros'),
  motor('Motor');

  const ParteLavagem(this.rotulo);

  final String rotulo;
}

enum ProdutoEstetica {
  shampoo('Shampoo'),
  cera('Cera'),
  pretinho('Pretinho'),
  limpaVidro('Limpa-vidro'),
  panos('Panos e esponjas'),
  hidratante('Hidratante de plásticos'),
  aspirador('Aspirador'),
  outro('Outro');

  const ProdutoEstetica(this.rotulo);

  final String rotulo;
}

class ResumoEstetica {
  const ResumoEstetica({
    required this.ultimaLavagem,
    required this.diasParaLavar,
    required this.intervaloDias,
    required this.gastoEsteticaCentavos,
    required this.servicosEstetica,
    required this.gastoProdutosCentavos,
    required this.lavagensEmCasa,
    required this.ultimaCompra,
  });

  final Servico? ultimaLavagem;
  final int? diasParaLavar;
  final int intervaloDias;
  final int gastoEsteticaCentavos;
  final int servicosEstetica;
  final int gastoProdutosCentavos;
  final int lavagensEmCasa;
  final Servico? ultimaCompra;

  int? get custoPorLavagemEmCasaCentavos =>
      lavagensEmCasa == 0 || gastoProdutosCentavos == 0 ? null : (gastoProdutosCentavos / lavagensEmCasa).round();
}

abstract final class CalculoEstetica {
  static const intervaloPadraoDias = 20;

  static ResumoEstetica resumo(List<Servico> servicos, DateTime agora) {
    final ordenados = [...servicos]..sort((a, b) => b.data.compareTo(a.data));
    final lavagens = ordenados.where((s) => ModalidadeEstetica.de(s) != ModalidadeEstetica.produtos).toList();
    final ultima = lavagens.firstOrNull;
    final intervalo = (ultima?.detalhes['lembreteDias'] as num?)?.toInt() ?? intervaloPadraoDias;
    final doAno = ordenados.where((s) => s.data.year == agora.year);
    final naEstetica = doAno.where((s) => ModalidadeEstetica.de(s) == ModalidadeEstetica.estetica);
    final compras = doAno.where((s) => ModalidadeEstetica.de(s) == ModalidadeEstetica.produtos);
    final emCasa = doAno.where((s) => ModalidadeEstetica.de(s) == ModalidadeEstetica.casa);
    return ResumoEstetica(
      ultimaLavagem: ultima,
      diasParaLavar: ultima == null
          ? null
          : intervalo - DateTime(agora.year, agora.month, agora.day).difference(
                DateTime(ultima.data.year, ultima.data.month, ultima.data.day)).inDays,
      intervaloDias: intervalo,
      gastoEsteticaCentavos: naEstetica.fold(0, (soma, s) => soma + s.valorCentavos),
      servicosEstetica: naEstetica.length,
      gastoProdutosCentavos: compras.fold(0, (soma, s) => soma + s.valorCentavos),
      lavagensEmCasa: emCasa.length,
      ultimaCompra: ordenados.where((s) => ModalidadeEstetica.de(s) == ModalidadeEstetica.produtos).firstOrNull,
    );
  }

  static String rotulos(Servico servico) {
    final modalidade = ModalidadeEstetica.de(servico);
    final nomes = [
      for (final nome in servico.categorias)
        switch (modalidade) {
          ModalidadeEstetica.estetica => ServicoEstetica.values.where((s) => s.name == nome).firstOrNull?.rotulo,
          ModalidadeEstetica.casa => ParteLavagem.values.where((s) => s.name == nome).firstOrNull?.rotulo,
          ModalidadeEstetica.produtos => ProdutoEstetica.values.where((s) => s.name == nome).firstOrNull?.rotulo,
        },
    ].whereType<String>().toList();
    final prefixo = switch (modalidade) {
      ModalidadeEstetica.estetica => '',
      ModalidadeEstetica.casa => 'Em casa: ',
      ModalidadeEstetica.produtos => 'Produtos: ',
    };
    if (nomes.isEmpty) return modalidade.rotulo;
    if (nomes.length == 1) return '$prefixo${nomes.first}';
    return '$prefixo${nomes.sublist(0, nomes.length - 1).join(', ')} e ${nomes.last}';
  }
}
