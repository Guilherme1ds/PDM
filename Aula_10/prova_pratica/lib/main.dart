import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppCadastro(),
    );
  }
}

class AppCadastro extends StatefulWidget {
  @override
  _AppCadastroState createState() => _AppCadastroState();
}

class _AppCadastroState extends State<AppCadastro> {
  TextEditingController tituloController = TextEditingController();
  TextEditingController descricaoController = TextEditingController();
  List<Map<String, dynamic>> itens = [];
  Map<String, dynamic>? editingItem;

  Future<Database> criarBanco() async {
    final caminho = await getDatabasesPath();
    final path = join(caminho, "banco.db");

    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE dados(id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT, descricao TEXT, data TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<void> inserirItem(String titulo, String descricao) async {
    try {
      final db = await criarBanco();
      String data = DateTime.now().toIso8601String();
      await db.insert("dados", {"titulo": titulo, "descricao": descricao, "data": data});
      carregarItens();
    } catch (e) {
      print("Erro ao inserir item: $e");
    }
  }

  Future<void> carregarItens() async {
    try {
      final db = await criarBanco();
      final lista = await db.query("dados", orderBy: "titulo ASC");
      setState(() {
        itens = lista;
      });
    } catch (e) {
      print("Erro ao carregar itens: $e");
      setState(() {
        itens = [];
      });
    }
  }

  Future<void> atualizarItem(int id, String titulo, String descricao) async {
    try {
      final db = await criarBanco();
      await db.update("dados", {"titulo": titulo, "descricao": descricao}, where: "id = ?", whereArgs: [id]);
      carregarItens();
    } catch (e) {
      print("Erro ao atualizar item: $e");
    }
  }

  Future<void> deletarItem(int id) async {
    try {
      final db = await criarBanco();
      await db.delete("dados", where: "id = ?", whereArgs: [id]);
      carregarItens();
    } catch (e) {
      print("Erro ao deletar item: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    carregarItens();
  }

  void salvarOuAtualizar() {
    String titulo = tituloController.text.trim();
    String descricao = descricaoController.text.trim();
    if (titulo.isEmpty || descricao.isEmpty) return;

    if (editingItem == null) {
      inserirItem(titulo, descricao);
    } else {
      atualizarItem(editingItem!['id'], titulo, descricao);
      setState(() {
        editingItem = null;
      });
    }
    tituloController.clear();
    descricaoController.clear();
  }

  void editarItem(Map<String, dynamic> item) {
    setState(() {
      editingItem = item;
      tituloController.text = item['titulo'];
      descricaoController.text = item['descricao'];
    });
  }

  void cancelarEdicao() {
    tituloController.clear();
    descricaoController.clear();
    setState(() {
      editingItem = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gerenciador de Itens")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: tituloController,
              decoration: InputDecoration(
                labelText: "Título",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: descricaoController,
              decoration: InputDecoration(
                labelText: "Descrição",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: salvarOuAtualizar,
                  child: Text(editingItem == null ? "Salvar" : "Atualizar"),
                ),
              ),
              if (editingItem != null) ...[
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: cancelarEdicao,
                    child: Text("Cancelar"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: itens.isEmpty
                ? Center(
                    child: Text(
                      "Nenhum item cadastrado",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: itens.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(itens[index]["titulo"]),
                          subtitle: Text(itens[index]["descricao"]),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => editarItem(itens[index]),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => deletarItem(itens[index]["id"]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}