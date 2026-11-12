import 'package:flutter/material.dart';

import '../utils/warna.dart';
import 'identifikasi_screen.dart';
import 'riwayat_screen.dart';
import 'tentang_model_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int halamanAktif = 0;

  final halaman = const [
    IdentifikasiScreen(),
    RiwayatScreen(),
    TentangModelScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: halamanAktif, children: halaman),
      bottomNavigationBar: NavigationBar(
        selectedIndex: halamanAktif,
        onDestinationSelected: (i) => setState(() => halamanAktif = i),
        backgroundColor: Warna.card,
        indicatorColor: Warna.primary.withAlpha(45),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner),
            label: 'Identifikasi',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Tentang Model',
          ),
        ],
      ),
    );
  }
}
