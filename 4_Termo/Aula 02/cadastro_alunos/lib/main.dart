import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: TelaPrincipal()));
}

// Pense: Por que precisamos inicializar o Firebase antes de executar o aplicativo?
// R: Precisamos inicializar o Firebase antes de rodar a interface (runApp) para
// que os canais de comunicação entre a plataforma nativa (Android/iOS) e a nuvem
// do Firebase estejam estabelecidos antes que qualquer Widget tente ler ou gravar dados.

class TelaPrincipal extends StatefulWidget {
  @override
  _TelaPrincipalState createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  TextEditingController nomeController = TextEditingController();
  TextEditingController idadeController = TextEditingController();
  TextEditingController cursoController = TextEditingController();
  TextEditingController emailController = TextEditingController(); // Atividade 5
  TextEditingController pesquisaController = TextEditingController(); // Atividade 6

  String textoPesquisa = "";

  // Por que utilizamos o TextEditingController?
  // R: Utilizamos o TextEditingController para gerenciar o estado dos campos de texto e facilitar a obtenção dos valores inseridos pelos usuários.

  Future<void> salvarAluno() async {
    String nome = nomeController.text;
    String idade = idadeController.text;
    String curso = cursoController.text;
    String email = emailController.text;

    if (nome.isEmpty || idade.isEmpty || curso.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    int? idadeNumero = int.tryParse(idade);

    await FirebaseFirestore.instance.collection('alunos').add({
      'nome': nome,
      'idade': idadeNumero ?? 0,
      'curso': curso,
      'email': email,
    });

    nomeController.clear();
    idadeController.clear();
    cursoController.clear();
    emailController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Aluno salvo com sucesso!')),
    );
  }

  Future<void> editarAluno(String docId, String nomeAtual, int idadeAtual, String cursoAtual, String emailAtual) async {
    TextEditingController editNomeController = TextEditingController(text: nomeAtual);
    TextEditingController editIdadeController = TextEditingController(text: idadeAtual.toString());
    TextEditingController editCursoController = TextEditingController(text: cursoAtual);
    TextEditingController editEmailController = TextEditingController(text: emailAtual);

   //Por que utilizamos TextEditingController?
  // R: Utilizamos o TextEditingController para gerenciar o estado dos campos de texto,
  // permitindo capturar os valores digitados pelos usuários, escutar modificações e 
  // limpar os inputs após as ações.

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Aluno'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: editNomeController, decoration: InputDecoration(labelText: 'Nome')),
                TextField(
                  controller: editIdadeController, 
                  decoration: InputDecoration(labelText: 'Idade'),
                  keyboardType: TextInputType.number,
                ),
                TextField(controller: editCursoController, decoration: InputDecoration(labelText: 'Curso')),
                TextField(controller: editEmailController, decoration: InputDecoration(labelText: 'E-mail')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('alunos').doc(docId).update({
                  'nome': editNomeController.text,
                  'idade': int.tryParse(editIdadeController.text) ?? 0,
                  'curso': editCursoController.text,
                  'email': editEmailController.text,
                });
                Navigator.pop(context);
              },
              child: Text('Atualizar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> excluirAluno(String docId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar exclusão'),
          content: Text('Deseja realmente excluir este aluno?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('alunos').doc(docId).delete();
                Navigator.pop(context);
              },
              child: Text('EXCLUIR'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Alunos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome', prefixIcon: Icon(Icons.person)),
            ),
            TextField(
              controller: idadeController,
              decoration: InputDecoration(labelText: 'Idade', prefixIcon: Icon(Icons.cake)),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: cursoController,
              decoration: InputDecoration(labelText: 'Curso', prefixIcon: Icon(Icons.school)),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.email)),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: salvarAluno,
              icon: Icon(Icons.add),
              label: Text('Cadastrar Aluno'),
            ),
            Divider(height: 30, thickness: 2),

            // Atividade 6: Campo de Pesquisa
            TextField(
              controller: pesquisaController,
              decoration: InputDecoration(
                labelText: 'Pesquisar aluno por nome...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  textoPesquisa = val.toLowerCase();
                });
              },
            ),
            SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('alunos').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Erro ao carregar os alunos: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final todosAlunos = snapshot.data?.docs ?? [];

                  // Atividade 6: Filtragem em tempo real
                  final alunosFiltrados = todosAlunos.where((aluno) {
                    final dados = aluno.data() as Map<String, dynamic>;
                    final nome = (dados['nome'] ?? '').toString().toLowerCase();
                    return nome.contains(textoPesquisa);
                  }).toList();

                  return Column(
                    children: [
                      // Atividade 7: Contador de Alunos
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Total de alunos: ${alunosFiltrados.length}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: alunosFiltrados.length,
                          itemBuilder: (context, index) {
                            final aluno = alunosFiltrados[index];
                            final id = aluno.id;
                            final dados = aluno.data() as Map<String, dynamic>;

                            return Card(
                              elevation: 2,
                              child: ListTile(
                                title: Text(dados['nome'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  'Idade: ${dados['idade']} anos\nCurso: ${dados['curso']}\nEmail: ${dados['email'] ?? 'Não informado'}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.orange),
                                      onPressed: () => editarAluno(
                                        id, 
                                        dados['nome'] ?? '', 
                                        dados['idade'] ?? 0, 
                                        dados['curso'] ?? '',
                                        dados['email'] ?? ''
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => excluirAluno(id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
    );
  }
}

// Pergunta: Os alunos continuam cadastrados ao fechar e abrir o aplicativo?
// Explique: Sim. Os alunos continuam cadastrados porque os dados são salvos de forma 
// persistente nos servidores do Cloud Firestore na nuvem, e não apenas na memória 
// temporária (RAM) do aplicativo. Quando o app reabre, o StreamBuilder consulta 
// a coleção novamente e recupera todos os registros.
