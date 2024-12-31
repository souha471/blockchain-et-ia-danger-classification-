import 'package:danger_classification_app/home.dart';
import 'package:danger_classification_app/home_screen.dart';
import 'package:danger_classification_app/normal.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'ethereum_service.dart';

class DangerPage extends StatefulWidget {
  @override
  _DangerPageState createState() => _DangerPageState();
}

class _DangerPageState extends State<DangerPage> {
  final EthereumService _ethereumService = EthereumService();
  List<Map<String, dynamic>> _incidents = [];

  @override
  void initState() {
    super.initState();
    _fetchIncidents();
  }

  Future<void> _fetchIncidents() async {
    final incidents = await _ethereumService.getIncidents();
    setState(() {
      _incidents = incidents;
    });
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
                    'assets/logo.png', // Ajoutez votre logo ici
                    height: 40,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _incidents.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(child: _buildChart()),
                ],
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
            icon: Icon(Icons.check_circle),
            label: 'Normal',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HomePage(), // Assurez-vous que HomePage existe
                ),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HomeScreen(), // Assurez-vous que HomeScreen existe
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NormalPage(), // Assurez-vous que NormalPage existe
                ),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _incidents
                .map((incident) => incident['quantite'] as int)
                .reduce((a, b) => a > b ? a : b)
                .toDouble() +
            10,
        barGroups: _incidents
            .map((incident) => BarChartGroupData(
                  x: incident['id'],
                  barRods: [
                    BarChartRodData(
                      toY: incident['quantite'].toDouble(),
                      color: const Color.fromARGB(215, 243, 75, 33),
                      width: 20,
                    )
                  ],
                ))
            .toList(),
      ),
    );
  }
}
