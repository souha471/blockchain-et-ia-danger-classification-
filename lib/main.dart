import 'package:danger_classification_app/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart'; // Importez votre écran principal

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Danger Classification',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(), // Démarrez avec l'écran de connexion
    );
  }
}
