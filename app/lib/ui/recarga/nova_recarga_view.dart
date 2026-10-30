import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formato.dart';
import '../../domain/registro_energia.dart';
import '../comum/campo_com_rotulo.dart';
import '../comum/campo_data.dart';
import '../comum/campos_valor.dart';
import '../comum/formulario_registro.dart';
import 'nova_recarga_view_model.dart';

class NovaRecargaView extends ConsumerStatefulWidget {
  const NovaRecargaView({super.key, this.registroId});

  final String? registroId;

  @override
  ConsumerState<NovaRecargaView> createState() => _NovaRecargaViewState();
}

class _NovaRecargaViewState extends ConsumerState<NovaRecargaView> {
  final _valores = CamposValor();
  final _odometro = TextEditingController();
  var _data = DateTime.now();
  var _cargaCompleta = true;
  ErrosFormulario _erros = const {};

  bool get _editando => widget.registroId != null;

  NovaRecargaViewModel get _vm => ref.read(novaRecargaViewModelProvider(widget.registroId).notifier);

  @override
  void initState() {
    super.initState();
    for (final (controle, campo) in [
      (_odometro, CampoRegistro.odometro),
      (_valores.quantidade, CampoRegistro.quantidade),
      (_valores.preco, CampoRegistro.preco),
    ]) {
      controle.addListener(() => _limparErro(campo));
    }
    if (!_editando) {
      WidgetsBinding.instance.addPostFrameCallback((_) => mostrarOnboardingHodometro(context, ref, recarga: true));
    }
  }

  @override
  void dispose() {
    _valores.dispose();
    _odometro.dispose();
    super.dispose();
  }

  void _limparErro(CampoRegistro campo) {
    if (_erros.containsKey(campo)) setState(() => _erros = {..._erros}..remove(campo));
  }

  void _selecionarLocal(LocalRecarga local) {
    _vm.selecionarLocal(local);
    final tarifa = ref.read(novaRecargaViewModelProvider(widget.registroId)).tarifaCasa;
    if (local == LocalRecarga.casa && tarifa != null) _valores.preco.text = Formato.paraCampo(tarifa);
  }

  Future<void> _salvar() async {
    final resultado = await _vm.salvar(
      data: _data,
      odometro: Formato.lerInteiro(_odometro.text),
      kwh: _valores.valorQuantidade,
      preco: _valores.valorPreco,
      total: _valores.valorTotal,
      cargaCompleta: _cargaCompleta,
    );
    if (!mounted) return;
    setState(() => _erros = resultado.erros);
    if (resultado.mensagem != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultado.mensagem!)));
    }
    if (!resultado.sucesso) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_editando ? 'Recarga atualizada.' : 'Recarga salva.')),
    );
    context.pop();
  }

  Future<void> _excluir() async {
    final confirmou = await confirmarExclusao(
      context,
      titulo: 'Excluir esta recarga?',
      mensagem: 'O consumo e os gastos serão recalculados sem ela.',
    );
    if (!confirmou) return;
    await _vm.excluir();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recarga excluída.')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = novaRecargaViewModelProvider(widget.registroId);
    final estado = ref.watch(provider);
    final veiculo = estado.veiculo;
    ref.listen(provider, (anterior, atual) {
      final editando = atual.editando;
      if (anterior?.editando == null && editando != null) {
        setState(() {
          _data = editando.data;
          _cargaCompleta = editando.cargaCompleta;
        });
        _odometro.text = '${editando.odometro}';
        _valores.preco.text = Formato.paraCampo(editando.precoKwh, casas: 3);
        _valores.quantidade.text = Formato.paraCampo(editando.kwh, casas: 3);
        _valores.total.text = Formato.paraCampo(editando.valorCentavos / 100);
        return;
      }
      final carregouTarifa = anterior?.tarifaCasa == null && atual.tarifaCasa != null;
      if (carregouTarifa && !_editando && atual.local == LocalRecarga.casa && _valores.preco.text.isEmpty) {
        _valores.preco.text = Formato.paraCampo(atual.tarifaCasa!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_editando ? 'Editar recarga' : 'Nova recarga'),
            if (veiculo != null) Text(veiculo.apelido, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: [
          if (_editando)
            IconButton(tooltip: 'Excluir', icon: const Icon(Icons.delete_outline), onPressed: _excluir),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<LocalRecarga>(
              segments: [
                for (final local in LocalRecarga.values) ButtonSegment(value: local, label: Text(local.rotulo)),
              ],
              selected: {estado.local},
              showSelectedIcon: false,
              onSelectionChanged: (selecao) => _selecionarLocal(selecao.first),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: CampoData(data: _data, aoMudar: (data) => setState(() => _data = data))),
                const SizedBox(width: 12),
                Expanded(
                  child: CampoComRotulo(
                    rotulo: 'Hodômetro (km)',
                    child: TextField(
                      controller: _odometro,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        helperText: 'Último: ${Formato.km(estado.ultimoOdometro)}',
                        errorText: _erros[CampoRegistro.odometro],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CampoComRotulo(
                    rotulo: 'Energia (kWh)',
                    child: TextField(
                      controller: _valores.quantidade,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(errorText: _erros[CampoRegistro.quantidade]),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CampoComRotulo(
                    rotulo: 'Preço por kWh (R\$)',
                    child: TextField(
                      controller: _valores.preco,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        helperText: estado.local == LocalRecarga.casa ? 'Tarifa da conta de luz' : null,
                        errorText: _erros[CampoRegistro.preco],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CampoComRotulo(
              rotulo: 'Total (R\$)',
              child: TextField(
                controller: _valores.total,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Carregou até 100%?'),
              subtitle: const Text('O consumo desta carga aparece na próxima carga completa'),
              value: _cargaCompleta,
              onChanged: (valor) => setState(() => _cargaCompleta = valor),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: estado.salvando || veiculo == null ? null : _salvar,
              child: Text(_editando ? 'Salvar alterações' : 'Salvar recarga'),
            ),
          ],
        ),
      ),
    );
  }
}
