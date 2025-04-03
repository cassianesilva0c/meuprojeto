import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu App Flutter',
      home: Scaffold(
        appBar: AppBar(title: Text('Olá, Flutter!')),
        body: Center(child: Text('Bem-vindo ao meu app')),
      ),
    );
  }
}
