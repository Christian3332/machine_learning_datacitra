import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class KameraScreen extends StatefulWidget {
  const KameraScreen({super.key});

  @override
  State<KameraScreen> createState() => _KameraScreenState();
}

class _KameraScreenState extends State<KameraScreen> {
  CameraController? controller;
  String? pesanError;
  bool sedangMemotret = false;

  @override
  void initState() {
    super.initState();
    siapkanKamera();
  }

  Future<void> siapkanKamera() async {
    try {
      final daftarKamera = await availableCameras();
      if (daftarKamera.isEmpty) {
        setState(() => pesanError = 'Kamera tidak ditemukan di perangkat ini.');
        return;
      }

      final kameraBelakang = daftarKamera.firstWhere(
        (k) => k.lensDirection == CameraLensDirection.back,
        orElse: () => daftarKamera.first,
      );
      final kamera = CameraController(kameraBelakang, ResolutionPreset.high, enableAudio: false);
      await kamera.initialize();

      if (!mounted) {
        await kamera.dispose();
        return;
      }
      setState(() => controller = kamera);
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() => pesanError = 'Kamera tidak bisa dibuka (${e.code}). Pastikan izin kamera sudah diberikan.');
    }
  }

  Future<void> ambilFoto() async {
    final kamera = controller;
    if (kamera == null || sedangMemotret) return;

    setState(() => sedangMemotret = true);
    try {
      final foto = await kamera.takePicture();
      if (!mounted) return;
      Navigator.pop(context, foto);
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        sedangMemotret = false;
        pesanError = 'Gagal mengambil foto (${e.code}).';
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget isi;
    if (pesanError != null) {
      isi = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(pesanError!, textAlign: TextAlign.center),
        ),
      );
    } else if (controller == null) {
      isi = const Center(child: CircularProgressIndicator());
    } else {
      isi = Column(
        children: [
          Expanded(child: Center(child: CameraPreview(controller!))),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              'Posisikan tulisan di tengah, lurus, dan cukup terang',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 28, top: 8),
            child: SizedBox(
              width: 72,
              height: 72,
              child: FilledButton(
                onPressed: sedangMemotret ? null : ambilFoto,
                style: FilledButton.styleFrom(shape: const CircleBorder(), padding: EdgeInsets.zero),
                child: sedangMemotret
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.camera_alt, size: 30),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Ambil foto tulisan'),
      ),
      body: SafeArea(child: isi),
    );
  }
}
