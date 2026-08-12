import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: ListaCompras()),
  );
}

class Item {
  final String nome;
  bool comprado;

  Item({required this.nome, this.comprado = false});
}

class ListaCompras extends StatefulWidget {
  const ListaCompras({super.key});

  @override
  State<ListaCompras> createState() => _ListaComprasState();
}

class _ListaComprasState extends State<ListaCompras> {
  final List<Item> itens = [];
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final nomes = prefs.getStringList('itens') ?? [];
    final comprados = prefs.getStringList('comprado') ?? [];

    setState(() {
      itens.clear();
      for (var i = 0; i < nomes.length; i++) {
        itens.add(
          Item(
            nome: nomes[i],
            comprado: i < comprados.length && comprados[i] == 'true',
          ),
        );
      }
    });
  }

  Future<void> _salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('itens', itens.map((item) => item.nome).toList());
    await prefs.setStringList(
      'comprado',
      itens.map((item) => item.comprado.toString()).toList(),
    );
  }

  void _adicionar() {
    final texto = controller.text.trim();
    if (texto.isEmpty) return;
    setState(() {
      itens.add(Item(nome: texto));
    });
    controller.clear();
    _salvarDados();
  }

  void _remover(int index) {
    setState(() {
      itens.removeAt(index);
    });
    _salvarDados();
  }

  void _toggle(int index) {
    setState(() {
      itens[index].comprado = !itens[index].comprado;
    });
    _salvarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Compras')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Novo item',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _adicionar(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _adicionar,
                  child: const Text('Adicionar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: itens.isEmpty
                ? const Center(
                    child: Text('Nenhum item ainda. Adicione um item acima.'),
                  )
                : ListView.builder(
                    itemCount: itens.length,
                    itemBuilder: (context, index) {
                      final item = itens[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.comprado
                              ? Colors.green
                              : Colors.blue,
                          child: Icon(
                            item.comprado ? Icons.check : Icons.shopping_cart,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          item.nome,
                          style: TextStyle(
                            decoration: item.comprado
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(item.comprado ? 'Comprado' : 'Pendente'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                item.comprado ? Icons.undo : Icons.check,
                                color: item.comprado
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                              onPressed: () => _toggle(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _remover(index),
                            ),
                          ],
                        ),
                        onTap: () => _toggle(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
