import 'package:flutter/material.dart';

import '../models/local.dart';
import '../services/local_service.dart';
import '../utils/constantes.dart';

/// Formulário usado para CADASTRAR (local == null) e EDITAR (local != null).
/// É aberto dentro de um showModalBottomSheet (seções 17 e 18 do tutorial).
///
/// Fecha retornando true quando salva com sucesso.
class LocalForm extends StatefulWidget {
  final Local? local;
  final String cidadeInicial;

  const LocalForm({super.key, this.local, this.cidadeInicial = 'São Paulo'});

  @override
  State<LocalForm> createState() => _LocalFormState();
}

class _LocalFormState extends State<LocalForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = LocalService();

  late final TextEditingController nomeController;
  late final TextEditingController avaliacaoController;
  late final TextEditingController distanciaController;
  late final TextEditingController horarioController;
  late final TextEditingController descricaoController;

  late String categoriaSelecionada;
  late String cidadeSelecionada;

  bool salvando = false;
  String? erro;

  bool get editando => widget.local != null;

  @override
  void initState() {
    super.initState();
    final local = widget.local;

    nomeController = TextEditingController(text: local?.nome ?? '');
    avaliacaoController =
        TextEditingController(text: local != null ? '${local.avaliacao}' : '');
    distanciaController =
        TextEditingController(text: local != null ? '${local.distancia}' : '');
    horarioController = TextEditingController(text: local?.horario ?? '');
    descricaoController = TextEditingController(text: local?.descricao ?? '');

    categoriaSelecionada = local?.categoria ?? categorias.first;
    cidadeSelecionada = local?.cidade ??
        (cidades.contains(widget.cidadeInicial)
            ? widget.cidadeInicial
            : cidades.first);
  }

  @override
  void dispose() {
    nomeController.dispose();
    avaliacaoController.dispose();
    distanciaController.dispose();
    horarioController.dispose();
    descricaoController.dispose();
    super.dispose();
  }

  double? _lerNumero(String texto) =>
      double.tryParse(texto.trim().replaceAll(',', '.'));

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      salvando = true;
      erro = null;
    });

    final local = Local(
      id: widget.local?.id ?? '',
      nome: nomeController.text.trim(),
      categoria: categoriaSelecionada,
      cidade: cidadeSelecionada,
      avaliacao: _lerNumero(avaliacaoController.text) ?? 0,
      distancia: _lerNumero(distanciaController.text) ?? 0,
      horario: horarioController.text.trim(),
      descricao: descricaoController.text.trim(),
      favorito: widget.local?.favorito ?? false,
    );

    try {
      if (editando) {
        await _service.atualizar(local); // Update
      } else {
        await _service.adicionar(local); // Create
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        salvando = false;
        erro = 'Erro ao salvar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Garante que valores antigos do banco apareçam no dropdown.
    final opcoesCategoria = {...categorias, categoriaSelecionada}.toList();
    final opcoesCidade = {...cidades, cidadeSelecionada}.toList();

    return Padding(
      // Sobe o formulário quando o teclado abre.
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                editando ? 'Editar local' : 'Cadastrar local',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: categoriaSelecionada,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder(),
                      ),
                      items: opcoesCategoria
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => categoriaSelecionada = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: cidadeSelecionada,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Cidade',
                        border: OutlineInputBorder(),
                      ),
                      items: opcoesCidade
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => cidadeSelecionada = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: avaliacaoController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Avaliação (0 a 5)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final n = _lerNumero(v ?? '');
                        if (n == null) return 'Número inválido';
                        if (n < 0 || n > 5) return 'Entre 0 e 5';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: distanciaController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Distância (km)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final n = _lerNumero(v ?? '');
                        if (n == null) return 'Número inválido';
                        if (n < 0) return 'Não pode ser negativa';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: horarioController,
                decoration: const InputDecoration(
                  labelText: 'Horário (ex.: 06:00 - 22:00)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
              ),
              if (erro != null) ...[
                const SizedBox(height: 12),
                Text(erro!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: salvando ? null : salvar,
                icon: salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(editando ? 'Salvar alterações' : 'Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
