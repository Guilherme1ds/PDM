import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: TelaPrincipal()));
}

class TelaPrincipal extends StatefulWidget {
  @override
  _TelaPrincipalState createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  TextEditingController nomeController = TextEditingController();
  TextEditingController idadeController = TextEditingController();
  TextEditingController cursoController = TextEditingController();

  // Por que utilizamos o TextEditingController?
  // R: Utilizamos o TextEditingController para gerenciar o estado dos campos de texto e facilitar a obtenção dos valores inseridos pelos usuários.

  Future<void> salvarAluno() async {
    String nome = nomeController.text;
    String idade = idadeController.text;
    String curso = cursoController.text;

    if (nome.isEmpty || idade.isEmpty || curso.isEmpty) {
      // Exibir uma mensagem de erro se algum campo estiver vazio
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    // Desafio: Fazer com que a idade seja armazenada como número em vez de texto no Firestore
    int? idadeNumero = int.tryParse(idade);

    // Enviar os dados para a coleção "alunos" no Firestore
    await FirebaseFirestore.instance.collection('alunos').add({
      'nome': nome,
      'idade': idadeNumero,
      'curso': curso,
    });
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
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: idadeController,
              decoration: InputDecoration(labelText: 'Idade'),
            ),
            TextField(
              controller: cursoController,
              decoration: InputDecoration(labelText: 'Curso'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                salvarAluno();
              },
              child: Text('Salvar'),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('alunos')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(
                      'Erro ao carregar os alunos: ${snapshot.error}',
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final alunos = snapshot.data?.docs ?? [];

                  return ListView.builder(
                    itemCount: alunos.length,
                    itemBuilder: (context, index) {
                      final aluno = alunos[index];
                      return ListTile(
                        title: Text(aluno['nome']),
                        subtitle: Text(
                          'Idade: ${aluno['idade']}, Curso: ${aluno['curso']}',
                        ),
                      );
                    },
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
