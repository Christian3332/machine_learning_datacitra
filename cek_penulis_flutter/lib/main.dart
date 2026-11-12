import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/identifikasi_provider.dart';
import 'providers/riwayat_provider.dart';
import 'screens/home_screen.dart';
import 'services/pengaturan_service.dart';
import 'utils/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PengaturanService.muat();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IdentifikasiProvider()),
        ChangeNotifierProvider(create: (_) => RiwayatProvider()..muat()),
      ],
      child: const CekPenulisApp(),
    ),
  );
}

class CekPenulisApp extends StatelessWidget {
  const CekPenulisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cek Penulis',
      debugShowCheckedModeBanner: false,
      theme: buatTema(),
      home: const HomeScreen(),
    );
  }
}
