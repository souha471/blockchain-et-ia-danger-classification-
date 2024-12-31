import 'package:danger_classification_app/danger.dart';
import 'package:danger_classification_app/normal.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart'; // Assurez-vous d'importer HomeScreen

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          color: Color.fromARGB(119, 129, 141, 169),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo à gauche
                  Image.asset(
                    'assets/logo.png', // Remplacez par votre logo
                    height: 40,
                  ),
                  SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white, // Fond blanc
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Découvrez comment détecter les liquides anormaux et préserver notre planète avec notre solution innovante.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40, // Plus grand
                  fontWeight: FontWeight.w900, // Plus épais
                  color: const Color.fromARGB(163, 0, 0, 0),
                  fontFamily:
                      'RobotoMono', // Remplacez par une police personnalisée
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300], // Gris clair
                  foregroundColor: Colors.black, // Texte noir
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Bouton arrondi
                  ),
                ),
                child: Text(
                  'Commencer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(119, 129, 141, 169),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Prédire',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle), // Icône pour Normal
            label: 'Normal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Danger',
          ),
        ],
        onTap: (index) {
          // Gérer la navigation
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NormalPage(), // Dirige vers NormalPage
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DangerPage(),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}
