using System.Globalization;
using System.Text;
using NossoCombustivel.Application.Comum;

namespace NossoCombustivel.Application.Ia;

public sealed class ServicoIa(IAssistenteIa assistente, IRepositorioCapacidades capacidades)
{
    private const string MensagemOcupada = "A IA do Google está ocupada agora. Tente de novo em alguns instantes.";
    public const int TamanhoMaximoImagem = 4 * 1024 * 1024;
    private static readonly string[] TiposAceitos = ["image/jpeg", "image/png", "image/webp", "image/heic"];

    public async Task<Resultado<CapacidadeEstimada>> EstimarCapacidadeAsync(
        VeiculoConsultado veiculo, string? codigoFipe, CancellationToken cancelamento)
    {
        if (string.IsNullOrWhiteSpace(veiculo.Marca) || string.IsNullOrWhiteSpace(veiculo.Modelo))
            return Resultado<CapacidadeEstimada>.Falha(TipoErro.Validacao, "Informe a marca e o modelo.");

        var chave = Chave(veiculo, codigoFipe);
        var guardada = await capacidades.ObterAsync(chave, cancelamento);
        if (guardada is not null) return Resultado<CapacidadeEstimada>.Ok(guardada);

        if (!assistente.Disponivel)
            return Resultado<CapacidadeEstimada>.Falha(TipoErro.Indisponivel, "A IA não está configurada.");

        CapacidadeEstimada? estimada;
        try
        {
            estimada = await assistente.EstimarCapacidadeAsync(veiculo, cancelamento);
        }
        catch (IaIndisponivelException)
        {
            return Resultado<CapacidadeEstimada>.Falha(TipoErro.Indisponivel, MensagemOcupada);
        }
        if (estimada is null || (estimada.TanqueL is null && estimada.BateriaKwh is null))
            return Resultado<CapacidadeEstimada>.Falha(TipoErro.NaoEncontrado, "A IA não soube a capacidade deste veículo.");

        var limpa = new CapacidadeEstimada(
            estimada.TanqueL is > 0 and < 500 ? decimal.Round(estimada.TanqueL.Value, 1) : null,
            estimada.BateriaKwh is > 0 and < 300 ? decimal.Round(estimada.BateriaKwh.Value, 1) : null);
        if (limpa.TanqueL is null && limpa.BateriaKwh is null)
            return Resultado<CapacidadeEstimada>.Falha(TipoErro.NaoEncontrado, "A IA não soube a capacidade deste veículo.");

        await capacidades.SalvarAsync(chave, veiculo, codigoFipe, limpa, cancelamento);
        return Resultado<CapacidadeEstimada>.Ok(limpa);
    }

    public async Task<Resultado<LeituraFoto>> LerFotoAsync(
        byte[] imagem, string tipoMime, TipoLeitura tipo, CancellationToken cancelamento)
    {
        if (imagem.Length == 0)
            return Resultado<LeituraFoto>.Falha(TipoErro.Validacao, "Envie uma foto.");
        if (imagem.Length > TamanhoMaximoImagem)
            return Resultado<LeituraFoto>.Falha(TipoErro.Validacao, "A foto é grande demais.");
        if (!TiposAceitos.Contains(tipoMime))
            return Resultado<LeituraFoto>.Falha(TipoErro.Validacao, "Formato de foto não aceito.");
        if (!assistente.Disponivel)
            return Resultado<LeituraFoto>.Falha(TipoErro.Indisponivel, "A IA não está configurada.");

        LeituraFoto? lida;
        try
        {
            lida = await assistente.LerFotoAsync(imagem, tipoMime, tipo, cancelamento);
        }
        catch (IaIndisponivelException)
        {
            return Resultado<LeituraFoto>.Falha(TipoErro.Indisponivel, MensagemOcupada);
        }
        var leitura = lida is null ? null : ConferenciaLeitura.Conferir(lida, tipo);
        var vazia = leitura is null || leitura == new LeituraFoto(null, null, null, null, null, null, null);
        return vazia
            ? Resultado<LeituraFoto>.Falha(TipoErro.NaoEncontrado, "Não consegui ler valores nessa foto. Tente outra mais nítida.")
            : Resultado<LeituraFoto>.Ok(leitura!);
    }

    public static string Chave(VeiculoConsultado veiculo, string? codigoFipe)
    {
        var ano = veiculo.Ano?.ToString(CultureInfo.InvariantCulture) ?? "-";
        if (!string.IsNullOrWhiteSpace(codigoFipe)) return $"fipe:{codigoFipe.Trim()}:{ano}";
        return $"texto:{veiculo.TipoVeiculo}:{Normalizar(veiculo.Marca)}:{Normalizar(veiculo.Modelo)}:{ano}";
    }

    private static string Normalizar(string texto)
    {
        var semAcento = new StringBuilder();
        foreach (var letra in texto.Trim().ToLowerInvariant().Normalize(NormalizationForm.FormD))
        {
            if (CharUnicodeInfo.GetUnicodeCategory(letra) != UnicodeCategory.NonSpacingMark) semAcento.Append(letra);
        }
        return string.Join(' ', semAcento.ToString().Split(' ', StringSplitOptions.RemoveEmptyEntries));
    }
}
