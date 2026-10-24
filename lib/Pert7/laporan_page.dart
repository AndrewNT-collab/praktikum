import 'package:flutter/material.dart';

import 'db_helper.dart';
import 'format.dart';
import 'kegiatan.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  DateTime _tanggal = DateTime.now();

  late Future<Ringkasan> _futureRingkasan;
  late Future<Map<String, int>> _futureKategori;
  late Future<List<Map<String, Object?>>> _futureMingguan;

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
    _futureRingkasan = DbHelper.ringkasan(_tanggalString);
    _futureKategori =
        DbHelper.pengeluaranPerKategori(_tanggalString);
    _futureMingguan =
        DbHelper.tujuhHariTerakhir(_tanggalString);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Keuangan'),
        actions: [
          IconButton(
            onPressed: _pilihTanggal,
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Pilih tanggal laporan',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(_muatData);

          await Future.wait([
            _futureRingkasan,
            _futureKategori,
            _futureMingguan,
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            OutlinedButton.icon(
              onPressed: _pilihTanggal,
              icon: const Icon(Icons.event),
              label: Text(formatTanggalIndonesia(_tanggal)),
            ),
            const SizedBox(height: 16),
            Text(
              'Ringkasan Harian',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            FutureBuilder<Ringkasan>(
              future: _futureRingkasan,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Gagal memuat ringkasan.');
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _baris(
                          'Jumlah kegiatan',
                          '${data.jumlahKegiatan}',
                        ),
                        _baris(
                          'Kegiatan selesai',
                          '${data.selesai}',
                        ),
                        _baris(
                          'Pemasukan',
                          formatRupiah(data.pemasukan),
                          warna: Colors.green,
                        ),
                        _baris(
                          'Pengeluaran',
                          formatRupiah(data.pengeluaran),
                          warna: Colors.red,
                        ),
                        const Divider(),
                        _baris(
                          'Tabungan bersih',
                          formatRupiah(data.tabungan),
                          warna: data.tabungan < 0
                              ? Colors.red
                              : Theme.of(context)
                              .colorScheme
                              .primary,
                          tebal: true,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Pengeluaran per Kategori',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            FutureBuilder<Map<String, int>>(
              future: _futureKategori,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Gagal memuat kategori.');
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!;

                if (data.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Belum ada pengeluaran pada tanggal ini.',
                      ),
                    ),
                  );
                }

                final total = data.values.fold<int>(
                  0,
                      (jumlah, nominal) => jumlah + nominal,
                );

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: data.entries.map((entry) {
                        final progres = total == 0
                            ? 0.0
                            : entry.value / total;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(entry.key),
                                  ),
                                  Text(formatRupiah(entry.value)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: progres,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Ringkasan 7 Hari',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Map<String, Object?>>>(
              future: _futureMingguan,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Gagal memuat laporan mingguan.');
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!;

                if (data.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Belum ada data selama tujuh hari terakhir.',
                      ),
                    ),
                  );
                }

                return Card(
                  child: Column(
                    children: data.map((baris) {
                      final tanggal =
                      baris['tanggal'] as String;
                      final masuk =
                      (baris['masuk'] as num).toInt();
                      final keluar =
                      (baris['keluar'] as num).toInt();

                      return ListTile(
                        title: Text(
                          formatTanggalIndonesia(
                            parseTanggal(tanggal),
                          ),
                        ),
                        subtitle: Text(
                          'Masuk: ${formatRupiah(masuk)}\n'
                              'Keluar: ${formatRupiah(keluar)}',
                        ),
                        isThreeLine: true,
                        trailing: Text(
                          formatRupiah(masuk - keluar),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: masuk - keluar < 0
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _baris(
      String judul,
      String nilai, {
        Color? warna,
        bool tebal = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(judul)),
          Text(
            nilai,
            style: TextStyle(
              color: warna,
              fontWeight: tebal ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}