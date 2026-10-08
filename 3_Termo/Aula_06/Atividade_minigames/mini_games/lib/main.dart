import 'package:flutter/material.dart';
import 'dart:math'; 

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: JogoApp(), 
  ));
}

class JogoApp extends StatefulWidget {
  @override
  JogoAppState createState() => JogoAppState(); 
}

class JogoAppState extends State<JogoApp> {
  IconData iconeComputador = Icons.help_outline; 
  String resultado = "Escolha uma opção"; 
  int pontosJogador = 0; 
  int pontosComputador = 0; 
  List opcoes = ["pedra", "papel", "tesoura"]; 

  void jogar(String escolhaUsuario) {
    var numero = Random().nextInt(3); 
    var escolhaComputador = opcoes[numero]; 

    setState(() { 
      
      if (escolhaComputador == "pedra") {
        iconeComputador = Icons.landscape; 
      } else if (escolhaComputador == "papel") {
        iconeComputador = Icons.pan_tool; 
      } else if (escolhaComputador == "tesoura") {
        iconeComputador = Icons.content_cut; 
      }

      if (escolhaUsuario == escolhaComputador) {
        resultado = "Empate"; 
      } 

      else if (
        (escolhaUsuario == "pedra" && escolhaComputador == "tesoura") ||
        (escolhaUsuario == "papel" && escolhaComputador == "pedra") ||
        (escolhaUsuario == "tesoura" && escolhaComputador == "papel")
      ) {
        pontosJogador++; 
        resultado = "Você venceu!"; 
      } 
      else {
        pontosComputador++; 
        resultado = "Computador venceu!"; 
      }

      if (pontosJogador == 5) {
        resultado = "Você ganhou o campeonato!"; 
        resetarPlacar(); 
      } else if (pontosComputador == 5) {
        resultado = "O computador ganhou o campeonato!";
        resetarPlacar();
      }
    });
  }

  void resetarPlacar() {
    setState(() {
      pontosJogador = 0;
      pontosComputador = 0;
      iconeComputador = Icons.help_outline;
    }); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pedra Papel Tesoura"), 
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Text("Computador", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), 
            Icon(
              iconeComputador,
              size: 100, 
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                resultado, 
                style: TextStyle(fontSize: 26), 
              ),
            ),
            Text(
              "Você: $pontosJogador | PC: $pontosComputador", 
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                IconButton(
                  icon: Icon(Icons.landscape), 
                  onPressed: () => jogar("pedra"), 
                  iconSize: 50,
                ),
                IconButton(
                  icon: Icon(Icons.pan_tool), 
                  onPressed: () => jogar("papel"), 
                  iconSize: 50,
                ),
                IconButton(
                  icon: Icon(Icons.content_cut), 
                  onPressed: () => jogar("tesoura"), 
                  iconSize: 50,
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton.icon( 
              onPressed: resetarPlacar, 
              icon: Icon(Icons.refresh), 
              label: Text("Resetar Placar"), 
            )
          ],
        ),
      ),
    );
  }
}