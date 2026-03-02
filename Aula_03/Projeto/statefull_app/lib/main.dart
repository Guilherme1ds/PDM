import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: PaginaContador()));
}

class PaginaContador extends StatefulWidget{
  @override
  _PaginaContadorState createState() => _PaginaContadorState();
}

class _PaginaContadorState extends State<PaginaContador> {
  int contador = 0;

  void increment(){
    setState((){
      contador++;
    });
  }

  void decrement(){
    setState((){
      contador--;
    });
  }

  @override 
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text("Meu App Interativo"),),
    body: Center(
      child: Text(
        'Clique: $contador',
        style: TextStyle(fontSize: 30),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: increment,
      child: Icon(Icons.add),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: decrement,
      child: Icon(Icons.remove),
    ),
  );
}
}

