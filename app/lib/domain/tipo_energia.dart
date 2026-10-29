enum TipoEnergia {
  combustao('Combustão'),
  hibridoComum('Híbrido'),
  hibridoPlugin('Híbrido plug-in'),
  eletrico('Elétrico');

  const TipoEnergia(this.rotulo);

  final String rotulo;

  bool get abastece => this != eletrico;

  bool get recarrega => this == hibridoPlugin || this == eletrico;
}
