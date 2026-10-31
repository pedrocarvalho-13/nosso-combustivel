class Cartao {
  const Cartao({required this.id, required this.nome, required this.diaFechamento, this.banco});

  final String id;
  final String nome;
  final int diaFechamento;
  final String? banco;
}
