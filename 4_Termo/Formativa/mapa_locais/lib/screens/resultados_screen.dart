import 'package:flutter/material.dart';

import '../dialogs/confirm_delete.dart';
import '../models/local.dart';
import '../services/local_service.dart';
import '../utils/constantes.dart';
import '../utils/filtros.dart';
import '../widgets/local_card.dart';
import '../widgets/local_form.dart';
import 'detalhes_screen.dart';

class ResultadosScreen extends StatefulWidget {
  final String cidade;
  final String pesquisa;
  final bool somenteFavoritos;

  const ResultadosScreen({
    super.key,
    required this.cidade,
    this.pesquisa = '',
    this.somenteFavoritos = false,
  });

  @override
  State<ResultadosScreen> createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  final LocalService service = LocalService();
  late final TextEditingController pesquisaController;
  late final Stream<List<Local>> _streamLocais;

  late String cidadeSelecionada;
  String categoriaSelecionada = todasCategorias;
  late bool somenteFavoritos;

  @override
  void initState() {
    super.initState();
    pesquisaController = TextEditingController(text: widget.pesquisa);
    cidadeSelecionada = widget.cidade;
    somenteFavoritos = widget.somenteFavoritos;
    _streamLocais = service.listarLocais();
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  void mostrarMensagem(String texto, {bool erro = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          backgroundColor: erro ? Colors.red : null,
        ),
      );
  }

  Future<void> abrirFormulario({Local? local}) async {
    final salvou = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => LocalForm(
        local: local,
        cidadeInicial:
            cidadeSelecionada == todasCidades ? cidades.first : cidadeSelecionada,
      ),
    );

    if (salvou == true) {
      mostrarMensagem(local == null
          ? 'Local cadastrado com sucesso!'
          : 'Local atualizado com sucesso!');
    }
  }

  Future<void> excluir(Local local) async {
    final confirmou = await confirmarExclusao(context, local.nome);
    if (!confirmou) return;

    try {
      await service.excluir(local.id);
      mostrarMensagem('Local excluído com sucesso!');
    } catch (e) {
      mostrarMensagem('Erro ao excluir: $e', erro: true);
    }
  }

  Future<void> carregarExemplos() async {
    final exemplos = <Local>[
      _ex('Academia Fitness', 'Academia', 'São Paulo', 4.8, 1.2, '06:00 - 22:00',
          'Musculação, funcional, aulas coletivas e personal trainer.'),
      _ex('Smart Fit', 'Academia', 'São Paulo', 4.5, 2.4, '05:00 - 23:00',
          'Rede de academias com ótimo custo-benefício.'),
      _ex('Cantina Bella', 'Restaurante', 'São Paulo', 4.6, 0.8, '11:00 - 23:00',
          'Massas artesanais e ambiente familiar.'),
      _ex('Hospital Central', 'Hospital', 'São Paulo', 4.2, 3.5, '24 horas',
          'Pronto atendimento e especialidades.'),
      _ex('Drogaria Saúde', 'Farmácia', 'São Paulo', 4.0, 0.5, '07:00 - 22:00',
          'Medicamentos, perfumaria e entrega rápida.'),
      _ex('Body Center', 'Academia', 'Campinas', 4.3, 3.1, '06:00 - 22:00',
          'Academia completa com piscina.'),
      _ex('Sabor Mineiro', 'Restaurante', 'Campinas', 4.7, 1.9, '11:00 - 15:00',
          'Comida mineira no fogão a lenha.'),
      _ex('Hospital Campinas', 'Hospital', 'Campinas', 4.1, 4.2, '24 horas',
          'Hospital geral com UTI.'),
      _ex('Mercado Bom Preço', 'Mercado', 'Campinas', 4.4, 1.1, '07:00 - 22:00',
          'Hortifruti, açougue e padaria.'),
      _ex('Farma Campinas', 'Farmácia', 'Campinas', 4.2, 2.0, '24 horas',
          'Farmácia 24 horas.'),
      _ex('Iron Gym', 'Academia', 'Jundiaí', 4.2, 5.2, '06:00 - 23:00',
          'Foco em musculação e crossfit.'),
      _ex('Proforma Academia', 'Academia', 'Jundiaí', 4.0, 4.7, '06:00 - 22:00',
          'Aulas de dança, pilates e musculação.'),
      _ex('Cantinho da Serra', 'Restaurante', 'Jundiaí', 4.8, 2.6, '11:30 - 22:00',
          'Culinária italiana com vista para a serra.'),
      _ex('Hospital São Vicente', 'Hospital', 'Jundiaí', 4.3, 3.3, '24 horas',
          'Atendimento de urgência e emergência.'),
      _ex('Super Jundiaí', 'Mercado', 'Jundiaí', 4.1, 1.5, '08:00 - 21:00',
          'Supermercado de bairro.'),
    ];

    try {
      for (final local in exemplos) {
        await service.adicionar(local);
      }
      mostrarMensagem('${exemplos.length} locais de exemplo cadastrados!');
    } catch (e) {
      mostrarMensagem('Erro ao cadastrar exemplos: $e', erro: true);
    }
  }

  Local _ex(String nome, String categoria, String cidade, double avaliacao,
      double distancia, String horario, String descricao) {
    return Local(
      id: '',
      nome: nome,
      categoria: categoria,
      cidade: cidade,
      avaliacao: avaliacao,
      distancia: distancia,
      horario: horario,
      descricao: descricao,
      favorito: false,
    );
  }

  void abrirDetalhes(Local local) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalhesScreen(local: local)),
    );
  }

  Future<void> escolherCidade() async {
    final escolhida = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [todasCidades, ...cidades].map((c) {
            return ListTile(
              leading: const Icon(Icons.location_city),
              title: Text(c == todasCidades ? 'Todas as cidades' : c),
              trailing: c == cidadeSelecionada ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, c),
            );
          }).toList(),
        ),
      ),
    );
    if (escolhida != null) setState(() => cidadeSelecionada = escolhida);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(somenteFavoritos ? 'Favoritos' : 'Resultados'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: somenteFavoritos ? 'Mostrar todos' : 'Somente favoritos',
            icon: Icon(
              somenteFavoritos ? Icons.favorite : Icons.favorite_border,
              color: somenteFavoritos ? Colors.red : null,
            ),
            onPressed: () =>
                setState(() => somenteFavoritos = !somenteFavoritos),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Cadastrar'),
      ),
      body: Column(
        children: [
          // Pesquisa
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: pesquisaController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou categoria',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: pesquisaController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          pesquisaController.clear();
                          setState(() {});
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
            ),
          ),

          // Filtro de cidade
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: escolherCidade,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cidadeSelecionada == todasCidades
                          ? 'Todas as cidades'
                          : cidadeSelecionada,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),

          // Filtro de categoria
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [todasCategorias, ...categorias].map((c) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: categoriaSelecionada == c,
                    onSelected: (_) => setState(() => categoriaSelecionada = c),
                  ),
                );
              }).toList(),
            ),
          ),

          // Lista vinda do Firestore (Read)
          Expanded(
            child: StreamBuilder<List<Local>>(
              stream: _streamLocais,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _mensagemCentral(
                    Icons.error_outline,
                    'Erro ao carregar os locais.\n${snapshot.error}',
                  );
                }

                final todos = snapshot.data ?? [];

                if (todos.isEmpty) {
                  return _mensagemCentral(
                    Icons.inbox_outlined,
                    'Nenhum local cadastrado no Firestore.',
                    acao: FilledButton.tonal(
                      onPressed: carregarExemplos,
                      child: const Text('Carregar locais de exemplo'),
                    ),
                  );
                }

                final locais = filtrarLocais(
                  todos,
                  pesquisaController.text,
                  cidadeSelecionada,
                  categoriaSelecionada,
                  somenteFavoritos: somenteFavoritos,
                );

                if (locais.isEmpty) {
                  return _mensagemCentral(
                    Icons.search_off,
                    'Nenhum local encontrado.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: locais.length,
                  itemBuilder: (context, index) {
                    final local = locais[index];
                    return LocalCard(
                      local: local,
                      onTap: () => abrirDetalhes(local),
                      onEditar: () => abrirFormulario(local: local),
                      onExcluir: () => excluir(local),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _mensagemCentral(IconData icone, String texto, {Widget? acao}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(texto, textAlign: TextAlign.center),
            if (acao != null) ...[const SizedBox(height: 16), acao],
          ],
        ),
      ),
    );
  }
}
