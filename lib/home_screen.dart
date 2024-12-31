import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ethereum_service.dart';
import 'home_screen.dart'; // Assurez-vous d'importer HomeScreen
import 'danger.dart';
import 'normal.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final quantityController = TextEditingController();
  final zoneController = TextEditingController();
  final durationController = TextEditingController();
  String result = "";
  String probability = "";
  bool showResult = false;
  final EthereumService _ethereumService = EthereumService();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 0),
    ).animate(_animationController);
  }

  Future<void> predict() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.22:5000/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'Quantité (L)': double.tryParse(quantityController.text),
          'Zone Affectée (km²)': double.tryParse(zoneController.text),
          'Durée (heures)': double.tryParse(durationController.text),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          result = data['result'];
          probability = data['probability'].toString();
          showResult = true;
        });

        if (result.toLowerCase() == "oui") {
          await _insertIntoBlockchain();
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      } else {
        setState(() {
          result = 'Erreur : ${response.body}';
          probability = '';
        });
      }
    } catch (e) {
      setState(() {
        result = 'Erreur : ${e.toString()}';
        probability = '';
      });
    }
  }

  Future<void> _insertIntoBlockchain() async {
    try {
      await _ethereumService.recordIncident(
        int.parse(quantityController.text), // ID ou une valeur appropriée
        int.parse(quantityController.text),
        int.parse(zoneController.text),
        int.parse(durationController.text),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Données insérées dans la blockchain avec succès !")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Erreur lors de l'insertion dans la blockchain : $e")),
      );
    }
  }

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
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text('Accueil'),
              onTap: () {
                Navigator.pushNamed(context, '/');
              },
            ),
            ListTile(
              title: Text('Prédire'),
              onTap: () {
                Navigator.pushNamed(context, '/predict');
              },
            ),
            ListTile(
              title: Text('Danger'),
              onTap: () {
                Navigator.pushNamed(context, '/danger');
              },
            ),
            ListTile(
              title: Text('Normal'),
              onTap: () {
                Navigator.pushNamed(context, '/normal');
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white, // Fond blanc pour toute la page
        child: Center(
          child: showResult ? _buildResultCard() : _buildForm(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(119, 129, 141, 169),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Normal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Danger',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NormalPage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DangerPage()),
              );
              break;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildForm() {
    return Container(
      width: 300,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white, // Fond blanc
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2), // Ombre subtile
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInputField(
              controller: quantityController, label: 'Quantité (L)'),
          SizedBox(height: 10),
          _buildInputField(
              controller: zoneController, label: 'Zone Affectée (km²)'),
          SizedBox(height: 10),
          _buildInputField(
              controller: durationController, label: 'Durée (heures)'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: predict,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300], // Bouton gris clair
              foregroundColor: Colors.black, // Texte noir
            ),
            child: Text('Prédire'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
      {required TextEditingController controller, required String label}) {
    return Container(
      width: 250,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildResultCard() {
    final bool isDangerous = result.toLowerCase() == "oui";
    final String imagePath =
        isDangerous ? 'assets/danger.png' : 'assets/normal.png';

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: 500,
                height: 500,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showResult = false;
                    _animationController.reverse();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                child: Text('Retour'),
              ),
            ],
          ),
        );
      },
    );
  }
}
