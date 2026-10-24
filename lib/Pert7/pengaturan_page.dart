import 'package:flutter/material.dart';

import 'format.dart';
import 'pengaturan.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  late final TextEditingController _targetController;

  @override
  void initState() {
    super.initState();
    _targetController = TextEditingController(
      text: targetTabungan.value.toString(),
    );
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _simpanTarget() async {
    final nominal = int.tryParse(_targetController.text.trim());

    if (nominal == null || nominal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Target harus lebih besar dari nol.'),
        ),
      );
      return;
    }

    await simpanTargetTabungan(nominal);

    if (!mounted) return;

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Target tabungan berhasil disimpan.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Tampilan',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<bool>(
            valueListenable: modeGelap,
            builder: (context, gelap, child) {
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mode Gelap'),
                subtitle: Text(
                  gelap
                      ? 'Tema gelap sedang aktif'
                      : 'Tema terang sedang aktif',
                ),
                secondary: Icon(
                  gelap ? Icons.dark_mode : Icons.light_mode,
                ),
                value: gelap,
                onChanged: simpanModeGelap,
              );
            },
          ),
          const SizedBox(height: 16),
          const Text('Warna Tema'),
          const SizedBox(height: 12),
          ValueListenableBuilder<Color>(
            valueListenable: warnaTema,
            builder: (context, warnaTerpilih, child) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: pilihanWarna.map((warna) {
                  final terpilih =
                      warnaTerpilih.toARGB32() == warna.toARGB32();

                  return Semantics(
                    label: 'Pilih warna ${warna.toString()}',
                    button: true,
                    child: InkWell(
                      onTap: () => simpanWarnaTema(warna),
                      borderRadius: BorderRadius.circular(30),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: warna,
                        child: terpilih
                            ? const Icon(
                          Icons.check,
                          color: Colors.white,
                        )
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const Divider(height: 40),
          Text(
            'Target Tabungan Harian',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Target saat ini: '
                '${formatRupiah(targetTabungan.value)}',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _targetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Target baru',
              prefixText: 'Rp ',
              border: OutlineInputBorder(),
              helperText: 'Masukkan nominal tanpa tanda titik.',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _simpanTarget,
            icon: const Icon(Icons.save),
            label: const Text('Simpan Target'),
          ),
          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'TabungKu menyimpan kegiatan di database '
                          'lokal dan pengaturan di perangkat ini.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}