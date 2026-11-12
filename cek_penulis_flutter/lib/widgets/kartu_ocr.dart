import 'package:flutter/material.dart';

import '../utils/warna.dart';
import 'kotak.dart';

class KartuOcr extends StatelessWidget {
  const KartuOcr({super.key});

  @override
  Widget build(BuildContext context) {
    return const Kotak(
      child: Row(
        children: [
          Icon(Icons.text_fields, color: Warna.teksSekunder),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Baca isi tulisan (OCR)', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(
                  'Fitur OCR belum tersedia. EfficientNetV2B0 mengenali gaya tulisan, bukan membaca isinya.',
                  style: TextStyle(color: Warna.teksSekunder, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
