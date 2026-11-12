import 'package:flutter/material.dart';

import '../utils/warna.dart';

class Kotak extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const Kotak({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Warna.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Warna.border),
      ),
      child: child,
    );
  }
}

class Label extends StatelessWidget {
  final String teks;

  const Label(this.teks, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(teks, style: const TextStyle(color: Warna.teksSekunder, fontSize: 13)),
    );
  }
}

class KotakGambar extends StatelessWidget {
  final ImageProvider? gambar;

  const KotakGambar({super.key, required this.gambar});

  Widget _kosong(String teks) {
    return SizedBox(
      height: 80,
      child: Center(child: Text(teks, style: const TextStyle(color: Colors.black54))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        color: Colors.white,
        child: gambar == null
            ? _kosong('Gambar tidak tersedia')
            : Image(
                image: gambar!,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(
                    height: 80,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
                errorBuilder: (context, error, stack) => _kosong('Gambar gagal dimuat'),
              ),
      ),
    );
  }
}
