import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MaterialApp(home: PaginaNumeroAleatorio()));
}

class PaginaNumeroAleatorio extends StatefulWidget{
  @override
  _PaginaNumeroAleatorioState createState() => _PaginaNumeroAleatorioState();
}

class _PaginaNumeroAleatorioState extends State<PaginaNumeroAleatorio> {
  int numero = 0;

  void sortear(){
    setState((){
      numero = Random().nextInt(10) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text("Sorteador de Numeros Aleatórios"),),
    body: Center(
      child: Text(
        'Número sorteado: $numero',
        style: TextStyle(fontSize: 30),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: sortear,
        child: Icon(Icons.refresh),
      ),
    );
  }
  }