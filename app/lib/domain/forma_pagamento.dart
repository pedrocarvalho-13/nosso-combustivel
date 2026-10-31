enum FormaPagamento {
  credito('Crédito'),
  debito('Débito'),
  pix('Pix'),
  dinheiro('Dinheiro');

  const FormaPagamento(this.rotulo);

  final String rotulo;
}
