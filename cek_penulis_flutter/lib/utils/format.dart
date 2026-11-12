const _namaBulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String formatPersen(double nilai) {
  final teks = (nilai * 100).toStringAsFixed(1).replaceAll('.', ',');
  return '$teks%';
}

String formatDetik(double detik) {
  return '${detik.toStringAsFixed(2).replaceAll('.', ',')} detik';
}

String formatTanggal(DateTime waktu) {
  final jam = waktu.hour.toString().padLeft(2, '0');
  final menit = waktu.minute.toString().padLeft(2, '0');
  return '${waktu.day} ${_namaBulan[waktu.month - 1]} ${waktu.year}, $jam:$menit';
}

const _awalanJpeg = [0xFF, 0xD8, 0xFF];
const _awalanPng = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

bool _diawaliDengan(List<int> isi, List<int> awalan) {
  if (isi.length < awalan.length) return false;
  for (var i = 0; i < awalan.length; i++) {
    if (isi[i] != awalan[i]) return false;
  }
  return true;
}

/// Mengembalikan 'jpg' atau 'png' berdasarkan isi file, atau null kalau formatnya lain.
/// Nama file tidak dipakai karena di web path-nya berupa blob URL dan di galeri Android
/// path-nya kadang tanpa ekstensi.
String? jenisGambar(List<int> isi) {
  if (_diawaliDengan(isi, _awalanJpeg)) return 'jpg';
  if (_diawaliDengan(isi, _awalanPng)) return 'png';
  return null;
}
