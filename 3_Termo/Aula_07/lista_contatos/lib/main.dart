import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ListaContatos()
  ));
}

class Contato {
  final String nome;
  final String telefone;
  final IconData icone;
  final Color cor;

  Contato({
    required this.nome,
    required this.telefone,
    required this.icone,
    required this.cor,
  });
}

class ListaContatos extends StatelessWidget {
  final List<Contato> contatos = [
    Contato(
      nome: "João Silva",
      telefone: "(11) 99999-0000",
      icone: Icons.person,
      cor: Colors.blue,
    ),
    Contato(
      nome: "Maria Santos",
      telefone: "(21) 98888-1111",
      icone: Icons.person_outline,
      cor: Colors.pink,
    ),
    Contato(
      nome: "Pedro Oliveira",
      telefone: "(85) 97777-2222",
      icone: Icons.account_circle,
      cor: Colors.deepOrange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Contatos"),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: contatos.length,
        itemBuilder: (context, index) {
          final contato = contatos[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: contato.cor,
              child: Icon(contato.icone, color: Colors.white),
            ),
            title: Text(contato.nome),
            subtitle: Text(contato.telefone),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Detalhes(contato: contato),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Detalhes extends StatelessWidget {
  final Contato contato;

  Detalhes({required this.contato});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalhes"),
        backgroundColor: contato.cor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: contato.cor,
              child: Icon(contato.icone, size: 60, color: Colors.white),
            ),
            SizedBox(height: 24),
            Text(contato.nome, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text(contato.telefone, style: TextStyle(fontSize: 16, color: contato.cor)),
            SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: contato.cor),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Ligando para ${contato.nome}...")),
              ),
              icon: Icon(Icons.call),
              label: Text("Ligar"),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Voltar"),
            ),
          ],
        ),
      ),
    );
  }
}