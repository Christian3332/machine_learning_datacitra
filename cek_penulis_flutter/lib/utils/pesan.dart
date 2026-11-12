import 'package:flutter/material.dart';

import 'warna.dart';

void tampilkanPesan(BuildContext context, String pesan, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(pesan, style: const TextStyle(color: Colors.white)),
        backgroundColor: error ? const Color(0xFF5A2626) : Warna.card,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
