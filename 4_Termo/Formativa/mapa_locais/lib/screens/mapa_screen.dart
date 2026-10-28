import 'package:flutter/material.dart';

import '../models/local.dart';
import '../services/local_service.dart';
import '../utils/constantes.dart';
import 'detalhes_screen.dart';
import 'resultados_screen.dart';

/// Tela 1 — Mapa principal.
/// Seletor de cidade, campo de pesquisa e uma representação de mapa
/// com marcadores dos locais da cidade (lidos do Firestore).
class MapaScreen extends StatefulWidget {
  /// Local que deve aparecer destacado (vindo do botão "Ver no mapa").
  final Local? localDestaque;

  const MapaScreen({super.key, this.localDestaque});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final LocalService service = LocalService();
  final TextEditingController pesquisaController = TextEditingController();
  late final Stream<List<Local>> _streamLocais;

  late String cidadeSelecionada;

  @override
  void initState() {
    super.initState();
    cidadeSelecionada = widget.localDestaque?.cidade ?? cidades.first;
    if (!cidades.contains(cidadeSelecionada)) cidadeSelecionada = cidades.first;
    _streamLocais = service.listarLocais();
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  // ---------- Navegação ----------

  void abrirResultados({bool somenteFavoritos = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultadosScreen(
          cidade: cidadeSelecionada,
          pesquisa: pesquisaController.text,
          somenteFavoritos: somenteFavoritos,
        ),
      ),
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
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Selecione a cidade',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ...cidades.map((c) {
              return ListTile(
                leading: const Icon(Icons.location_city),
                title: Text(c),
                trailing:
                    c == cidadeSelecionada ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, c),
              );
            }),
          ],
        ),
      ),
    );
    if (escolhida != null) setState(() => cidadeSelecionada = escolhida);
  }

  void mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  // ---------- Interface ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Cidade selecionada
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: InkWell(
                onTap: escolherCidade,
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 28),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cidade selecionada',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade700)),
                        Row(
                          children: [
                            Text(cidadeSelecionada,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Pesquisa
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: pesquisaController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => abrirResultados(),
                decoration: InputDecoration(
                  hintText: 'Buscar locais, endereços ou categorias...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    tooltip: 'Pesquisar',
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: abrirResultados,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  isDense: true,
                ),
              ),
            ),

            // Mapa
            Expanded(
              child: StreamBuilder<List<Local>>(
                stream: _streamLocais,
                builder: (context, snapshot) {
                  final locaisCidade = (snapshot.data ?? [])
                      .where((l) => l.cidade == cidadeSelecionada)
                      .toList();

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: _MapaPainter()),
                      ),
                      Positioned.fill(
                        child: LayoutBuilder(
                          builder: (context, area) => Stack(
                            children: [
                              _localizacaoUsuario(area),
                              ...locaisCidade.map(
                                (l) => _marcador(l, area),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Avisos sobre o carregamento
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Center(child: CircularProgressIndicator()),
                      if (snapshot.hasError)
                        _aviso('Erro ao carregar os locais do Firestore.'),
                      if (snapshot.hasData && locaisCidade.isEmpty)
                        _aviso('Nenhum local cadastrado em $cidadeSelecionada.'),

                      // Botões flutuantes do mapa
                      Positioned(
                        right: 12,
                        bottom: 76,
                        child: Column(
                          children: [
                            _botaoMapa(Icons.my_location, 'Minha localização',
                                () => mostrarMensagem(
                                    'Você está no centro de $cidadeSelecionada')),
                            const SizedBox(height: 10),
                            _botaoMapa(Icons.layers_outlined, 'Camadas',
                                () => mostrarMensagem(
                                    '${locaisCidade.length} locais no mapa')),
                          ],
                        ),
                      ),

                      // Botão para acessar os resultados
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 12,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          onPressed: abrirResultados,
                          icon: const Icon(Icons.list),
                          label: const Text('Ver resultados'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (indice) {
          if (indice == 1) abrirResultados(somenteFavoritos: true);
          if (indice == 2) mostrarMensagem('Perfil: em breve');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Mapa'),
          NavigationDestination(
              icon: Icon(Icons.favorite_border), label: 'Favoritos'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }

  /// Posição "fixa" de cada local no mapa, calculada a partir do id,
  /// para o marcador não mudar de lugar a cada atualização.
  Offset _posicao(Local local, BoxConstraints area) {
    var hash = 7;
    for (final c in local.id.codeUnits) {
      hash = (hash * 31 + c) & 0x7fffffff;
    }
    final x = 0.08 + (hash % 1000) / 1000 * 0.75;
    final y = 0.06 + ((hash ~/ 1000) % 1000) / 1000 * 0.62;
    return Offset(x * area.maxWidth, y * area.maxHeight);
  }

  Widget _marcador(Local local, BoxConstraints area) {
    final pos = _posicao(local, area);
    final destacado = widget.localDestaque?.id == local.id;

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: GestureDetector(
        onTap: () => abrirDetalhes(local),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              size: destacado ? 44 : 34,
              color: destacado ? Colors.red : Colors.grey.shade800,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 3),
                ],
              ),
              child: Text(
                local.nome,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: destacado ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _localizacaoUsuario(BoxConstraints area) {
    return Positioned(
      left: area.maxWidth / 2 - 18,
      top: area.maxHeight / 2 - 18,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue.withValues(alpha: 0.2),
        ),
        child: Center(
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _botaoMapa(IconData icone, String dica, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: IconButton(tooltip: dica, icon: Icon(icone), onPressed: onTap),
    );
  }

  Widget _aviso(String texto) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Text(texto),
      ),
    );
  }
}

/// Desenha um "mapa" simples: ruas, um parque e um rio.
class _MapaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fundo
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE8E8E8));

    // Parque
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.62,
            size.width * 0.28, size.height * 0.18),
        const Radius.circular(12),
      ),
      Paint()..color = const Color(0xFFD4E8D0),
    );

    // Ruas
    final rua = Paint()
      ..color = Colors.white
      ..strokeWidth = 8;
    final ruaFina = Paint()
      ..color = Colors.white
      ..strokeWidth = 4;

    for (var i = 1; i < 6; i++) {
      final y = size.height * i / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 20),
          i.isEven ? rua : ruaFina);
    }
    for (var i = 1; i < 5; i++) {
      final x = size.width * i / 5;
      canvas.drawLine(Offset(x, 0), Offset(x - 30, size.height),
          i.isOdd ? rua : ruaFina);
    }

    // Rio
    final rio = Path()
      ..moveTo(0, size.height * 0.35)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.45,
          size.width * 0.55, size.height * 0.7)
      ..quadraticBezierTo(
          size.width * 0.7, size.height * 0.9, size.width, size.height * 0.95);
    canvas.drawPath(
      rio,
      Paint()
        ..color = const Color(0xFFB9C3CC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
