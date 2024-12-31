import 'package:danger_classification_app/danger.dart';
import 'package:danger_classification_app/home.dart';
import 'package:danger_classification_app/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NormalPage extends StatefulWidget {
  @override
  _NormalPageState createState() => _NormalPageState();
}

class _NormalPageState extends State<NormalPage> {
  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final url = Uri.parse("http://127.0.0.1:5000/get_normal_data");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          data = jsonDecode(response.body);
        });
      } else {
        throw Exception("Erreur : ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur lors de la récupération des données : $e");
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
                    'assets/logo.png',
                    height: 40,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: data.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  barGroups: data.map((item) {
                    return BarChartGroupData(
                      x: item['id'], // Champ d'identifiant
                      barRods: [
                        BarChartRodData(
                          toY: item['value'], // Valeur correspondante
                          color: const Color.fromARGB(255, 33, 243, 110),
                          width: 16,
                        ),
                      ],
                    );
                  }).toList(),
                  borderData: FlBorderData(show: false),
                ),
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
            icon: Icon(Icons.analytics),
            label: 'Prédire',
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
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
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
