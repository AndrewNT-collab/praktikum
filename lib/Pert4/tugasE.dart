import 'package:flutter/material.dart';
import 'tugasC.dart';

class DetailPenggunaPage extends StatelessWidget {
  final Pengguna pengguna;

  const DetailPenggunaPage({
    super.key,
    required this.pengguna,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengguna'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              pengguna.name,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Text('Email: ${pengguna.email}'),
            const SizedBox(height: 8),
            Text('Telepon: ${pengguna.phone}'),
            const SizedBox(height: 8),
            Text('Website: ${pengguna.website}'),
          ],
        ),
      ),
    );
  }
}