using NossoCombustivel.Application.Comum;
using NossoCombustivel.Domain;
using NossoCombustivel.Domain.Registros;
using NossoCombustivel.Domain.Veiculos;

namespace NossoCombustivel.Application.Sincronizacao;

public sealed class ServicoSincronizacao(IRepositorioSincronizacao repositorio, IRelogio relogio)
{
    private static readonly TimeSpan MargemDoCursor = TimeSpan.FromSeconds(5);
    private const string CarroDeOutraConta = "Este carro não pertence à sua conta.";

    public async Task<RespostaEnvio> EnviarAsync(Guid usuarioId, LoteSync lote, CancellationToken cancelamento)
    {
        var agora = relogio.Agora;
        var rejeitados = new List<Rejeitado>();

        var existentes = (await repositorio.ObterVeiculosAsync(lote.Veiculos.Select(v => v.Id).ToList(), cancelamento))
            .ToDictionary(v => v.Id);
        foreach (var dto in lote.Veiculos)
        {
            Tentar(dto.Id, rejeitados, () =>
            {
                var dados = ParaDados(dto);
                if (!existentes.TryGetValue(dto.Id, out var veiculo))
                    repositorio.Adicionar(Veiculo.Criar(dto.Id, usuarioId, dados, dto.CriadoEm, agora));
                else if (veiculo.DonoId != usuarioId)
                    throw new ExcecaoDeDominio(CarroDeOutraConta);
                else
                    veiculo.Aplicar(dados, agora);
            });
        }

        var permitidos = await repositorio.IdsDosVeiculosDoUsuarioAsync(usuarioId, cancelamento);
        permitidos.UnionWith(lote.Veiculos.Where(v => rejeitados.All(r => r.Id != v.Id)).Select(v => v.Id));

        var abastecimentos = (await repositorio.ObterAbastecimentosAsync(lote.Abastecimentos.Select(a => a.Id).ToList(), cancelamento))
            .ToDictionary(a => a.Id);
        foreach (var dto in lote.Abastecimentos)
        {
            Tentar(dto.Id, rejeitados, () =>
            {
                var existente = abastecimentos.GetValueOrDefault(dto.Id);
                ExigirCarroPermitido(existente?.VeiculoId ?? dto.VeiculoId, permitidos);
                var dados = new DadosAbastecimento(dto.Data, dto.Odometro, dto.Combustivel, dto.Litros, dto.PrecoLitro,
                    dto.ValorTotal, dto.TanqueCheio, dto.Posto, dto.AtualizadoEm, dto.ExcluidoEm);
                if (existente is null)
                    repositorio.Adicionar(Abastecimento.Criar(dto.Id, dto.VeiculoId, usuarioId, dados, dto.CriadoEm, agora));
                else
                    existente.Aplicar(dados, agora);
            });
        }

        var recargas = (await repositorio.ObterRecargasAsync(lote.Recargas.Select(r => r.Id).ToList(), cancelamento))
            .ToDictionary(r => r.Id);
        foreach (var dto in lote.Recargas)
        {
            Tentar(dto.Id, rejeitados, () =>
            {
                var existente = recargas.GetValueOrDefault(dto.Id);
                ExigirCarroPermitido(existente?.VeiculoId ?? dto.VeiculoId, permitidos);
                var dados = new DadosRecarga(dto.Data, dto.Odometro, dto.Local, dto.Kwh, dto.PrecoKwh,
                    dto.ValorTotal, dto.CargaCompleta, dto.AtualizadoEm, dto.ExcluidoEm);
                if (existente is null)
                    repositorio.Adicionar(Recarga.Criar(dto.Id, dto.VeiculoId, usuarioId, dados, dto.CriadoEm, agora));
                else
                    existente.Aplicar(dados, agora);
            });
        }

        await repositorio.SalvarAsync(cancelamento);
        return new RespostaEnvio(rejeitados);
    }

    public async Task<RespostaBusca> BuscarAsync(Guid usuarioId, DateTimeOffset? desde, CancellationToken cancelamento)
    {
        var cursor = relogio.Agora;
        var aPartir = desde?.Subtract(MargemDoCursor);
        var idsDosVeiculos = await repositorio.IdsDosVeiculosDoUsuarioAsync(usuarioId, cancelamento);

        var veiculos = await repositorio.VeiculosAlteradosAsync(usuarioId, aPartir, cancelamento);
        var abastecimentos = await repositorio.AbastecimentosAlteradosAsync(idsDosVeiculos, aPartir, cancelamento);
        var recargas = await repositorio.RecargasAlteradasAsync(idsDosVeiculos, aPartir, cancelamento);

        return new RespostaBusca(
            new LoteSync(
                veiculos.Select(ParaDto).ToList(),
                abastecimentos.Select(ParaDto).ToList(),
                recargas.Select(ParaDto).ToList()),
            cursor);
    }

    private static void Tentar(Guid id, List<Rejeitado> rejeitados, Action acao)
    {
        try
        {
            acao();
        }
        catch (ExcecaoDeDominio erro)
        {
            rejeitados.Add(new Rejeitado(id, erro.Message));
        }
    }

    private static void ExigirCarroPermitido(Guid veiculoId, HashSet<Guid> permitidos)
    {
        if (!permitidos.Contains(veiculoId))
            throw new ExcecaoDeDominio(CarroDeOutraConta);
    }

    private static DadosVeiculo ParaDados(VeiculoSync dto) => new(
        dto.Apelido, dto.Marca, dto.Modelo, dto.Ano, dto.CodigoFipe, dto.TipoEnergia, dto.Combustiveis,
        dto.CapacidadeTanqueL, dto.CapacidadeBateriaKwh, dto.OdometroInicial, dto.AtualizadoEm, dto.ExcluidoEm);

    private static VeiculoSync ParaDto(Veiculo v) => new(
        v.Id, v.Apelido, v.Marca, v.Modelo, v.Ano, v.CodigoFipe, v.TipoEnergia, v.ListaCombustiveis,
        v.CapacidadeTanqueL, v.CapacidadeBateriaKwh, v.OdometroInicial, v.CriadoEm, v.AtualizadoEm, v.ExcluidoEm);

    private static AbastecimentoSync ParaDto(Abastecimento a) => new(
        a.Id, a.VeiculoId, a.Data, a.Odometro, a.Combustivel, a.Litros, a.PrecoLitro, a.ValorTotal,
        a.TanqueCheio, a.Posto, a.CriadoEm, a.AtualizadoEm, a.ExcluidoEm);

    private static RecargaSync ParaDto(Recarga r) => new(
        r.Id, r.VeiculoId, r.Data, r.Odometro, r.Local, r.Kwh, r.PrecoKwh, r.ValorTotal,
        r.CargaCompleta, r.CriadoEm, r.AtualizadoEm, r.ExcluidoEm);
}
