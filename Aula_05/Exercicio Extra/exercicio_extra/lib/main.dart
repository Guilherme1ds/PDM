import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HumorApp(),
  ));
}

class HumorApp extends StatefulWidget {
  @override
  _HumorAppState createState() => _HumorAppState();
}

class _HumorAppState extends State<HumorApp> {
  String humor = "Neutro";
  String emoji = "😐";
  Color corFundo = Colors.yellow;

  void mudarHumor() {
    setState(() {
      if (humor == "Neutro") {
        humor = "Feliz";
        emoji = "😀";
        corFundo = Colors.green;
      } else if (humor == "Feliz") {
        humor = "Bravo";
        emoji = "😡";
        corFundo = Colors.red;
      } else {
        humor = "Neutro";
        emoji = "😐";
        corFundo = Colors.yellow;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Alterador de Humor")),
      backgroundColor: corFundo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: 80)),
            Text(humor, style: TextStyle(fontSize: 30)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: mudarHumor, 
              child: Text("Alterar Humor"),
            ),
          ],
        ),
      ),
    );
  }
}