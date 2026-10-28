import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/local.dart';
import '../services/local_service.dart';
import '../utils/constantes.dart';
import 'mapa_screen.dart';

/// Tela 3 — Detalhes do local.
class DetalhesScreen extends StatefulWidget {
  final Local local;

  const DetalhesScreen({super.key, required this.local});

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  final LocalService service = LocalService();
  late bool favorito;
  bool salvandoFavorito = false;

  Local get local => widget.local;

  @override
  void initState() {
    super.initState();
    favorito = local.favorito;
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

  /// Altera o campo "favorito" do documento (seção 20 do tutorial).
  Future<void> alternarFavorito() async {
    setState(() => salvandoFavorito = true);
    try {
      await service.alterarFavorito(local.id, !favorito);
      if (!mounted) return;
      setState(() => favorito = !favorito);
      mostrarMensagem(
        favorito ? 'Adicionado aos favoritos' : 'Removido dos favoritos',
      );
    } catch (e) {
      mostrarMensagem('Erro ao atualizar favorito: $e', erro: true);
    } finally {
      if (mounted) setState(() => salvandoFavorito = false);
    }
  }

  Future<void> compartilhar() async {
    await Clipboard.setData(
      ClipboardData(text: '${local.nome} — ${local.categoria}, ${local.cidade}'),
    );
    mostrarMensagem('Informações copiadas para a área de transferência');
  }

  void verNoMapa() {
    // Volta para a tela de mapa (limpando a pilha) destacando este local.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MapaScreen(localDestaque: local)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final cinza = Colors.grey.shade700;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: favorito ? 'Remover dos favoritos' : 'Favoritar',
            onPressed: salvandoFavorito ? null : alternarFavorito,
            icon: Icon(
              favorito ? Icons.favorite : Icons.favorite_border,
              color: favorito ? Colors.red : null,
            ),
          ),
          IconButton(
            tooltip: 'Compartilhar',
            onPressed: compartilhar,
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          // Imagem principal
          Container(
            height: 190,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              iconeCategoria(local.categoria),
              size: 72,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),

          // Nome, categoria e avaliação
          Text(local.nome,
              style: textos.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          Text(local.categoria, style: TextStyle(color: cinza)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(local.avaliacao.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),

          // Distância, horário e cidade
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _info(Icons.location_on_outlined,
                  '${local.distancia.toStringAsFixed(1)} km'),
              _info(Icons.schedule,
                  local.horario.isEmpty ? 'Horário não informado' : local.horario),
              _info(Icons.location_city, local.cidade),
            ],
          ),
          const Divider(height: 32),

          // Ações rápidas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _acao(Icons.phone_outlined, 'Ligar'),
              _acao(Icons.near_me_outlined, 'Como chegar'),
              _acao(Icons.event_outlined, 'Agendar'),
            ],
          ),
          const Divider(height: 32),

          // Sobre
          Text('Sobre',
              style: textos.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(local.descricao.isEmpty ? 'Sem descrição.' : local.descricao),
          const Divider(height: 32),

          // Fotos
          Text('Fotos',
              style: textos.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: Container(
                  height: 70,
                  margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.image_outlined, color: Colors.grey.shade600),
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: verNoMapa,
            icon: const Icon(Icons.location_on),
            label: const Text('Ver no mapa'),
          ),
        ),
      ),
    );
  }

  Widget _info(IconData icone, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 4),
        Text(texto),
      ],
    );
  }

  Widget _acao(IconData icone, String rotulo) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => mostrarMensagem('$rotulo: função demonstrativa'),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: Icon(icone, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(rotulo, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
