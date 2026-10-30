namespace NossoCombustivel.Application.Ia;

public static class ConferenciaLeitura
{
    private sealed record Faixas(decimal PrecoMinimo, decimal PrecoMaximo, decimal QuantidadeMaxima);

    private static readonly Faixas Combustivel = new(2m, 15m, 300m);
    private static readonly Faixas Energia = new(0.2m, 6m, 200m);

    private const int HodometroMaximo = 2_000_000;

    public static LeituraFoto Conferir(LeituraFoto leitura, TipoLeitura tipo)
    {
        if (tipo == TipoLeitura.Hodometro)
        {
            var hodometro = leitura.Odometro is > 0 and < HodometroMaximo ? leitura.Odometro : null;
            return new LeituraFoto(null, null, null, null, null, hodometro, null);
        }

        var abastecimento = tipo == TipoLeitura.Abastecimento;
        var faixas = abastecimento ? Combustivel : Energia;
        var (quantidade, preco, total) = Ajustar(
            abastecimento ? leitura.Litros : leitura.Kwh,
            abastecimento ? leitura.PrecoLitro : leitura.PrecoKwh,
            leitura.ValorTotal,
            faixas);

        return abastecimento
            ? leitura with { Litros = quantidade, PrecoLitro = preco, ValorTotal = total, Kwh = null, PrecoKwh = null, Odometro = null }
            : leitura with
            {
                Kwh = quantidade, PrecoKwh = preco, ValorTotal = total, Litros = null, PrecoLitro = null, Combustivel = null, Odometro = null
            };
    }

    private static (decimal? Quantidade, decimal? Preco, decimal? Total) Ajustar(
        decimal? quantidade, decimal? preco, decimal? total, Faixas faixas)
    {
        preco = NaFaixa(preco, faixas.PrecoMinimo, faixas.PrecoMaximo);
        if (quantidade > faixas.QuantidadeMaxima) quantidade = null;

        if (quantidade is { } q && preco is { } p && total is { } t && !Coerente(q, p, t))
        {
            var corrigida = t / p;
            quantidade = corrigida <= faixas.QuantidadeMaxima ? decimal.Round(corrigida, 3) : quantidade;
            if (quantidade == q) total = decimal.Round(q * p, 2);
        }

        if (quantidade is null && preco is { } p2 && total is { } t2)
        {
            var calculada = t2 / p2;
            if (calculada <= faixas.QuantidadeMaxima) quantidade = decimal.Round(calculada, 3);
        }
        if (total is null && quantidade is { } q3 && preco is { } p3) total = decimal.Round(q3 * p3, 2);
        if (preco is null && quantidade is { } q4 and > 0 && total is { } t4)
            preco = NaFaixa(decimal.Round(t4 / q4, 3), faixas.PrecoMinimo, faixas.PrecoMaximo);

        return (quantidade, preco, total);
    }

    private static bool Coerente(decimal quantidade, decimal preco, decimal total) =>
        Math.Abs(quantidade * preco - total) <= Math.Max(0.05m, total * 0.02m);

    private static decimal? NaFaixa(decimal? preco, decimal minimo, decimal maximo)
    {
        if (preco is not { } valor) return null;
        for (var tentativas = 0; valor > maximo && tentativas < 3; tentativas++) valor /= 10;
        return valor >= minimo && valor <= maximo ? valor : null;
    }
}
