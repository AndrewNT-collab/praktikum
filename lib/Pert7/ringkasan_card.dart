import 'package:flutter/material.dart';

import 'format.dart';
import 'kegiatan.dart';

class RingkasanCard extends StatelessWidget {
  final Ringkasan ringkasan;
  final int target;

  const RingkasanCard({
    super.key,
    required this.ringkasan,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final tabungan = ringkasan.tabungan;
    final progres = target <= 0
        ? 0.0
        : (tabungan / target).clamp(0.0, 1.0);

    final warnaTabungan = tabungan < 0
        ? Colors.red
        : Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Hari Ini',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Kegiatan selesai: ${ringkasan.selesai}/${ringkasan.jumlahKegiatan}',
            ),
            const SizedBox(height: 12),
            _barisKeuangan(
              'Pemasukan',
              ringkasan.pemasukan,
              Colors.green,
            ),
            _barisKeuangan(
              'Pengeluaran',
              ringkasan.pengeluaran,
              Colors.red,
            ),
            const Divider(height: 24),
            Text(
              'Tabungan: ${formatRupiah(tabungan)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: warnaTabungan,
              ),
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progres),
              duration: const Duration(milliseconds: 700),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                );
              },
            ),
            const SizedBox(height: 8),
            Text('Target: ${formatRupiah(target)}'),
            if (tabungan < 0)
              const Text(
                'Pengeluaran melebihi pemasukan!',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (tabungan >= target)
              const Text(
                'Hebat! Target tabungan tercapai!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _barisKeuangan(
      String label,
      int nominal,
      Color warna,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            formatRupiah(nominal),
            style: TextStyle(
              color: warna,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}