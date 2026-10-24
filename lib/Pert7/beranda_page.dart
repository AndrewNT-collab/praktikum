import 'package:flutter/material.dart';

import 'db_helper.dart';
import 'format.dart';
import 'kegiatan.dart';
import 'kegiatan_tile.dart';
import 'ringkasan_card.dart';
import 'form_kegiatan_page.dart';
import 'pengaturan.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  DateTime _tanggal = DateTime.now();
  late Future<List<Kegiatan>> _futureKegiatan;
  late Future<Ringkasan> _futureRingkasan;

  String get _tanggalString => formatTanggal(_tanggal);

  @override
  void initState() {
    super.initState();
    _muatData();
    versiData.addListener(_perubahanData);
  }

  @override
  void dispose() {
    versiData.removeListener(_perubahanData);
    super.dispose();
  }

  void _perubahanData() {
    if (mounted) {
      setState(_muatData);
    }
  }

  void _muatData() {
    _futureKegiatan = DbHelper.pada(_tanggalString);
    _futureRingkasan = DbHelper.ringkasan(_tanggalString);
  }

  Future<void> _pilihTanggal() async {
    final tanggal = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (tanggal != null && mounted) {
      setState(() {
        _tanggal = tanggal;
        _muatData();
      });
    }
  }

  Future<void> _tambahKegiatan() async {
    await Navigator.pushNamed(
      context,
      '/form',
      arguments: _tanggalString,
    );
  }

  Future<void> _ubahKegiatan(Kegiatan kegiatan) async {
    await Navigator.pushNamed(
      context,
      '/form',
      arguments: kegiatan,
    );
  }

  Future<void> _hapusKegiatan(Kegiatan kegiatan) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kegiatan'),
        content: Text('Hapus "${kegiatan.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi == true && kegiatan.id != null) {
      await DbHelper.hapus(kegiatan.id!);
    }
  }

  Future<void> _ubahStatus(
      Kegiatan kegiatan,
      bool? selesai,
      ) async {
    if (kegiatan.id == null || selesai == null) return;

    await DbHelper.ubahStatus(kegiatan.id!, selesai);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TabungKu'),
        actions: [
          IconButton(
            onPressed: _pilihTanggal,
            tooltip: 'Pilih tanggal',
            icon: const Icon(Icons.calendar_month),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(_muatData);
          await Future.wait([
            _futureKegiatan,
            _futureRingkasan,
          ]);
        },
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: OutlinedButton.icon(
                onPressed: _pilihTanggal,
                icon: const Icon(Icons.event),
                label: Text(
                  formatTanggalIndonesia(_tanggal),
                ),
              ),
            ),
            ValueListenableBuilder<int>(
              valueListenable: targetTabungan,
              builder: (context, target, child) {
                return FutureBuilder<Ringkasan>(
                  future: _futureRingkasan,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Gagal memuat ringkasan.'),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    return RingkasanCard(
                      ringkasan: snapshot.data!,
                      target: target,
                    );
                  },
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                'Daftar Kegiatan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            FutureBuilder<List<Kegiatan>>(
              future: _futureKegiatan,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Gagal memuat kegiatan.'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final kegiatan = snapshot.data!;

                if (kegiatan.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'Belum ada kegiatan pada tanggal ini.',
                      ),
                    ),
                  );
                }

                return Column(
                  children: kegiatan.map((item) {
                    return KegiatanTile(
                      kegiatan: item,
                      onSelesai: (value) {
                        _ubahStatus(item, value);
                      },
                      onUbah: () => _ubahKegiatan(item),
                      onHapus: () => _hapusKegiatan(item),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 90),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahKegiatan,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kegiatan'),
      ),
    );
  }
}