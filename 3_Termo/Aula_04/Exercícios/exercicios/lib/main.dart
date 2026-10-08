import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
  // PARTE 1 - Estrutura Inicial
  // O que precisa ser passado dentro do runApp?
  // R: O runApp exige que você passe a instância do widget raiz da sua aplicação. No caso o MyApp().
}

class MyApp extends StatelessWidget { 
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TodoPage(),
    );
  }
}

// Esse widget (MyApp) deve ser Stateless ou Stateful?
// R: Ele deve ser um StatelessWidget.
// Por quê?
// R: Porque o MyApp serve apenas como a configuração inicial do aplicativo (definindo rotas, o MaterialApp, título e tema).
// O estado interno não sofre alterações na tela ao longo do tempo. O estado que vai mudar (a lista de tarefas) ficará a cargo de outra página (a TodoPage).

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<String> tarefas = [];
  final TextEditingController controller = TextEditingController();

  // PARTE 3 - Criando o Estado
  // Por que essa variável (lista de tarefas) precisa estar dentro da classe TodoPageState?
  // R: A classe que estende State é a responsável por guardar os dados mutáveis na memória enquanto o aplicativo roda.
  // Se a lista fosse colocada no próprio Widget (que é imutável), ela seria recriada toda vez que a tela atualizasse,
  // e você perderia as tarefas inseridas.
  // Qual classe controla o texto digitado?
  // R: A classe responsável por isso no Flutter é o TextEditingController.

void adicionarTarefa() {
  setState(() {
    tarefas.add(controller.text);
  });
  controller.clear();
  // PARTE 5 - Criando Função para Adicionar
  // O que acontece se remover o setState?
  // R: Se você remover o setState, a tarefa será até adicionada à lista na memória, mas o Flutter não será avisado
  // de que a interface do usuário precisa ser atualizada. Ou seja, visualmente, a nova tarefa não aparecerá na tela.
  // O que deve ser usado para limpar o campo?
  // R: Você deve chamar o método clear() do controlador. Exemplo: controller.clear();
}

void removerTarefa(int index) {
setState(() {
  tarefas.removeAt(index);
});
}

void impedirTarefaVazia() {
  if (controller.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('A tarefa não pode ser vazia!')),
    );
  } else {
    adicionarTarefa();
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tarefas: (${tarefas.length}) Tarefas'),
      ),
      body: Column (
        children: [

          TextField(
            controller: controller,
            onSubmitted: (_) => impedirTarefaVazia(),
          ),

          ElevatedButton (
            onPressed: impedirTarefaVazia,
            child: const Text("Adicionar"),
          ),
          Expanded(
            child: tarefas.isEmpty
                ? const Center(
                    child: Text('Nenhuma tarefa adicionada'),
                  )
                : ListView.builder(
                    itemCount: tarefas.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(tarefas[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => removerTarefa(index),
                        ),
                      );
                    },
                  ),
          // PARTE 6 - Exibindo a Lista
          // Por que usamos .length?
          // R: Usamos o .length na propriedade itemCount para avisar ao ListView exatamente quantos itens
          // existem na nossa lista de tarefas. Assim, ele sabe o limite de vezes que deve repetir o processo
          // de construção na tela.
          // O que é index?
          // R: O index é a posição do item atual que está sendo renderizado pelo ListView.builder.
          // O Flutter passa por cada item da lista (posição 0, 1, 2...) e o index indica qual posição
          // está sendo construída naquele exato momento.
          ),
        ],
      ),
    );
  }
}
