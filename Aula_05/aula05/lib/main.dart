import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: InterruptorApp(),
  ));
}

class InterruptorApp extends StatefulWidget {
  @override
  _InterruptorAppState createState() => _InterruptorAppState();
}

class _InterruptorAppState extends State<InterruptorApp> {
  bool estaAceso = false;

  void alternarLuz() {
    setState(() {
      estaAceso = !estaAceso;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: estaAceso ? Colors.black :Colors.white,
      appBar: AppBar(
        title: Text(
          "Interruptor",
          style: TextStyle(color: estaAceso ? Colors.white : Colors.black),
        ),
        backgroundColor: estaAceso ? Colors.black : Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              estaAceso ? Icons.lightbulb : Icons.lightbulb_outline,
              size: 100,
              color: estaAceso ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: alternarLuz,
              style: ElevatedButton.styleFrom(
                backgroundColor: estaAceso ? Colors.white : Colors.black,
              ),
              child: Text(
                "Interruptor",
                style: TextStyle(color: estaAceso ? Colors.black : Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}