import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: CadastroAlunos()),
  );
}

class Aluno {
  final String nome;
  final int idade;
  final String curso;

  Aluno({required this.nome, required this.idade, required this.curso});
}

class CadastroAlunos extends StatefulWidget {
  const CadastroAlunos({super.key});

  @override
  State<CadastroAlunos> createState() => _CadastroAlunosState();
}

class _CadastroAlunosState extends State<CadastroAlunos> {
  final List<Aluno> alunos = [];
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController idadeController = TextEditingController();
  final TextEditingController cursoController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() { 
    nomeController.dispose();
    idadeController.dispose();
    cursoController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final nomes = prefs.getStringList('nomes') ?? [];
    final idades = prefs.getStringList('idades') ?? [];
    final cursos = prefs.getStringList('cursos') ?? [];

    setState(() {
      alunos.clear();
      for (var i = 0; i < nomes.length; i++) {
        alunos.add(
          Aluno(
            nome: nomes[i],
            idade: int.tryParse(idades[i]) ?? 0,
            curso: cursos[i],
          ),
        );
      }
    });
  }

  Future<void> _salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('nomes', alunos.map((aluno) => aluno.nome).toList());
    await prefs.setStringList('idades', alunos.map((aluno) => aluno.idade.toString()).toList());
    await prefs.setStringList('cursos', alunos.map((aluno) => aluno.curso).toList());
  }

  void _adicionarAluno() {
    final nome = nomeController.text.trim();
    final idade = int.tryParse(idadeController.text.trim());
    final curso = cursoController.text.trim();

    String? mensagemErro;
    if (nome.isEmpty) {
      mensagemErro = 'Nome necessário.';
    } else if (idade == null || idade <= 0) {
      mensagemErro = 'Idade necessária.';
    } else if (curso.isEmpty) {
      mensagemErro = 'Curso necessário.';
    }

    if (mensagemErro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemErro)),
      );
      return;
    }

    setState(() => alunos.add(Aluno(nome: nome, idade: idade!, curso: curso)));
    _salvarDados();
    nomeController.clear();
    idadeController.clear();
    cursoController.clear();
  }

  void _removerAluno(int index) {
    setState(() {
      alunos.removeAt(index);
      _salvarDados();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Alunos'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: idadeController,
                      decoration: const InputDecoration(labelText: 'Idade'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: cursoController,
                      decoration: const InputDecoration(labelText: 'Curso'),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _adicionarAluno,
                        child: const Text('Adicionar Aluno'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Alunos cadastrados',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: alunos.length,
                itemBuilder: (context, index) {
                  final aluno = alunos[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(aluno.nome),
                      subtitle: Text('${aluno.idade} anos • ${aluno.curso}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Remover aluno',
                        onPressed: () => _removerAluno(index),
                      ),
                    ),
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
