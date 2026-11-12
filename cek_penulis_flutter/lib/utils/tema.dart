import 'package:flutter/material.dart';

import 'warna.dart';

ThemeData buatTema() {
  final skema = ColorScheme.fromSeed(
    seedColor: Warna.primary,
    brightness: Brightness.dark,
  ).copyWith(
    primary: Warna.primary,
    onPrimary: Colors.black,
    surface: Warna.background,
    onSurface: Warna.teksUtama,
    outline: Warna.border,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: skema,
    scaffoldBackgroundColor: Warna.background,
  );
}
