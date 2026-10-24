
import 'package:flutter/material.dart';

class Item {
  final String nama;
  final IconData ikon;
  final Color warna;
  final String deskripsi;

  const Item(
      this.nama,
      this.ikon,
      this.warna,
      this.deskripsi,
      );
}

const daftarItem = [
  Item(
    'Flutter',
    Icons.flutter_dash,
    Colors.blue,
    'Framework untuk membangun aplikasi multiplatform.',
  ),
  Item(
    'Musik',
    Icons.music_note,
    Colors.pink,
    'Tempat menemukan inspirasi lewat musik.',
  ),
  Item(
    'Kamera',
    Icons.camera_alt,
    Colors.orange,
    'Abadikan momen terbaikmu.',
  ),
  Item(
    'Peta',
    Icons.map,
    Colors.green,
    'Jelajahi tempat-tempat baru.',
  ),
];

class DetailPage extends StatelessWidget {
  final Item item;

  const DetailPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(item.nama)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'ikon-${item.nama}',
                child: CircleAvatar(
                  radius: 64,
                  backgroundColor: tema.colorScheme.primaryContainer,
                  child: Icon(
                    item.ikon,
                    size: 64,
                    color: tema.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                item.nama,
                style: tema.textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                item.deskripsi,
                textAlign: TextAlign.center,
                style: tema.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
