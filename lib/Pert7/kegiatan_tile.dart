import 'package:flutter/material.dart';

import 'format.dart';
import 'kegiatan.dart';

class KegiatanTile extends StatelessWidget {
  final Kegiatan kegiatan;
  final ValueChanged<bool?> onSelesai;
  final VoidCallback onUbah;
  final VoidCallback onHapus;

  const KegiatanTile({
    super.key,
    required this.kegiatan,
    required this.onSelesai,
    required this.onUbah,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    final warna = switch (kegiatan.tipe) {
      TipeKeuangan.pemasukan => Colors.green,
      TipeKeuangan.pengeluaran => Colors.red,
      TipeKeuangan.tanpa => Theme.of(context).colorScheme.onSurface,
    };

    final nominalText = switch (kegiatan.tipe) {
      TipeKeuangan.pemasukan =>
      '+ ${formatRupiah(kegiatan.nominal)}',
      TipeKeuangan.pengeluaran =>
      '- ${formatRupiah(kegiatan.nominal)}',
      TipeKeuangan.tanpa => '',
    };

    return Card(
      child: ListTile(
        leading: Checkbox(
          value: kegiatan.selesai,
          onChanged: onSelesai,
        ),
        title: Text(
          kegiatan.judul,
          style: TextStyle(
            decoration: kegiatan.selesai
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(kegiatan.tanggal),
            if (kegiatan.tipe == TipeKeuangan.pengeluaran)
              Text(kegiatan.kategori),
            if (nominalText.isNotEmpty)
              Text(
                nominalText,
                style: TextStyle(
                  color: warna,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'ubah') onUbah();
            if (value == 'hapus') onHapus();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'ubah',
              child: Text('Ubah'),
            ),
            PopupMenuItem(
              value: 'hapus',
              child: Text('Hapus'),
            ),
          ],
        ),
      ),
    );
  }
}