using System.Globalization;
using NossoCombustivel.Application.Comum;
using NossoCombustivel.Domain;
using NossoCombustivel.Domain.Postos;

namespace NossoCombustivel.Application.Postos;

public sealed class ServicoPostos(IBuscaPostos busca, IRepositorioPostos repositorio, IRelogio relogio)
{
    public const int RaioPadrao = 1500;
    public const int RaioMaximo = 5000;
    private const int DistanciaDuplicadoMetros = 80;
    private static readonly TimeSpan ValidadeDaBusca = TimeSpan.FromDays(7);
    private static readonly TimeSpan IdadeMaximaDoPreco = TimeSpan.FromDays(60);

    public async Task<Resultado<PostosProximos>> BuscarProximosAsync(
        double latitude, double longitude, int? raioMetros, CancellationToken cancelamento)
    {
        if (!LocalizacaoValida(latitude, longitude))
            return Resultado<PostosProximos>.Falha(TipoErro.Validacao, "Localização inválida.");
        var raio = Math.Clamp(raioMetros ?? RaioPadrao, 100, RaioMaximo);
        var agora = relogio.Agora;

        var buscaCompleta = true;
        var chave = ChaveDaArea(busca.Origem, latitude, longitude, raio);
        if (!await repositorio.AreaBuscadaDesdeAsync(chave, agora - ValidadeDaBusca, cancelamento))
        {
            try
            {
                var encontrados = await busca.BuscarProximosAsync(latitude, longitude, raio, cancelamento);
                await GuardarAsync(encontrados, agora, cancelamento);
                await repositorio.MarcarAreaBuscadaAsync(chave, agora, cancelamento);
                await repositorio.SalvarAsync(cancelamento);
            }
            catch (BuscaPostosIndisponivelException)
            {
                buscaCompleta = false;
            }
        }

        var postos = await PertoAsync(latitude, longitude, raio, cancelamento);
        var precos = postos.Count == 0
            ? []
            : await repositorio.PrecosDesdeAsync(postos.Select(p => p.Id).ToList(), agora - IdadeMaximaDoPreco, cancelamento);
        var ultimos = precos
            .GroupBy(p => (p.PostoId, p.Combustivel))
            .Select(g => g.MaxBy(p => p.Data)!)
            .ToLookup(p => p.PostoId, p => new PrecoInformado(p.Combustivel, p.PrecoLitro, p.Data));
        var comPrecos = postos.Select(p => p with { Precos = ultimos[p.Id].ToList() }).ToList();
        return Resultado<PostosProximos>.Ok(new PostosProximos(comPrecos, buscaCompleta));
    }

    public async Task<Resultado<PostoProximo>> CadastrarAsync(Guid usuarioId, DadosPosto dados, CancellationToken cancelamento)
    {
        if (!LocalizacaoValida(dados.Latitude, dados.Longitude))
            return Resultado<PostoProximo>.Falha(TipoErro.Validacao, "Localização inválida.");

        var parecido = (await PertoAsync(dados.Latitude, dados.Longitude, DistanciaDuplicadoMetros, cancelamento))
            .FirstOrDefault(p => Normalizar(p.Nome) == Normalizar(dados.Nome ?? string.Empty));
        if (parecido is not null)
            return Resultado<PostoProximo>.Ok(parecido);

        Posto posto;
        try
        {
            posto = Posto.Criar(Guid.CreateVersion7(), OrigemPosto.Manual, null, dados, usuarioId, relogio.Agora);
        }
        catch (ExcecaoDeDominio erro)
        {
            return Resultado<PostoProximo>.Falha(TipoErro.Validacao, erro.Message);
        }
        repositorio.Adicionar(posto);
        await repositorio.SalvarAsync(cancelamento);
        return Resultado<PostoProximo>.Ok(ParaProximo(posto, 0));
    }

    private async Task GuardarAsync(IReadOnlyList<PostoEncontrado> encontrados, DateTimeOffset agora, CancellationToken cancelamento)
    {
        foreach (var grupo in encontrados.GroupBy(e => e.Origem))
        {
            var unicos = grupo.DistinctBy(e => e.IdExterno).ToList();
            var existentes = (await repositorio.ObterPorExternosAsync(grupo.Key, unicos.Select(e => e.IdExterno).ToList(), cancelamento))
                .ToDictionary(p => p.IdExterno!);
            foreach (var encontrado in unicos)
            {
                var dados = new DadosPosto(encontrado.Nome, encontrado.Bandeira, encontrado.Endereco, encontrado.Latitude, encontrado.Longitude);
                try
                {
                    if (existentes.TryGetValue(encontrado.IdExterno, out var posto))
                        posto.Atualizar(dados, agora);
                    else
                        repositorio.Adicionar(Posto.Criar(Guid.CreateVersion7(), grupo.Key, encontrado.IdExterno, dados, null, agora));
                }
                catch (ExcecaoDeDominio)
                {
                }
            }
        }
    }

    private async Task<List<PostoProximo>> PertoAsync(double latitude, double longitude, int raio, CancellationToken cancelamento)
    {
        var grausLatitude = raio / 111_320d;
        var grausLongitude = raio / (111_320d * Math.Max(Math.Cos(latitude * Math.PI / 180), 0.01));
        var naArea = await repositorio.NaAreaAsync(
            latitude - grausLatitude, latitude + grausLatitude, longitude - grausLongitude, longitude + grausLongitude, cancelamento);
        return naArea
            .Select(p => ParaProximo(p, DistanciaMetros(latitude, longitude, p.Latitude, p.Longitude)))
            .Where(p => p.DistanciaMetros <= raio)
            .OrderBy(p => p.DistanciaMetros)
            .ToList();
    }

    public static int DistanciaMetros(double latitude1, double longitude1, double latitude2, double longitude2)
    {
        const double raioTerra = 6_371_000;
        static double Radianos(double graus) => graus * Math.PI / 180;
        var dLat = Radianos(latitude2 - latitude1);
        var dLng = Radianos(longitude2 - longitude1);
        var a = Math.Pow(Math.Sin(dLat / 2), 2) +
                Math.Cos(Radianos(latitude1)) * Math.Cos(Radianos(latitude2)) * Math.Pow(Math.Sin(dLng / 2), 2);
        return (int)Math.Round(raioTerra * 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a)));
    }

    private static bool LocalizacaoValida(double latitude, double longitude) =>
        latitude is >= -90 and <= 90 && longitude is >= -180 and <= 180;

    private static string ChaveDaArea(OrigemPosto origem, double latitude, double longitude, int raio) =>
        string.Create(CultureInfo.InvariantCulture, $"{origem}:{latitude:F2}:{longitude:F2}:{raio}");

    private static string Normalizar(string texto) =>
        string.Join(' ', texto.ToLowerInvariant().Split(' ', StringSplitOptions.RemoveEmptyEntries));

    private static PostoProximo ParaProximo(Posto p, int distancia) =>
        new(p.Id, p.Nome, p.Bandeira, p.Endereco, p.Latitude, p.Longitude, distancia);
}
