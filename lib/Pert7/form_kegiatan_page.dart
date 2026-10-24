import 'package:flutter/material.dart';

import 'db_helper.dart';
import 'format.dart';
import 'kegiatan.dart';

class FormKegiatanPage extends StatefulWidget {
  final Kegiatan? kegiatan;
  final String? tanggalAwal;

  const FormKegiatanPage({
    super.key,
    this.kegiatan,
    this.tanggalAwal,
  });

  @override
  State<FormKegiatanPage> createState() => _FormKegiatanPageState();
}

class _FormKegiatanPageState extends State<FormKegiatanPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _nominalController = TextEditingController();

  late DateTime _tanggal;
  TipeKeuangan _tipe = TipeKeuangan.tanpa;
  String _kategori = 'Makan';
  bool _menyimpan = false;

  final List<String> _kategoriPengeluaran = [
    'Makan',
    'Transport',
    'Belajar',
    'Hiburan',
    'Lainnya',
  ];

  bool get _modeEdit => widget.kegiatan != null;

  @override
  void initState() {
    super.initState();

    final kegiatan = widget.kegiatan;

    _tanggal = kegiatan != null
        ? parseTanggal(kegiatan.tanggal)
        : parseTanggal(
      widget.tanggalAwal ?? formatTanggal(DateTime.now()),
    );

    if (kegiatan != null) {
      _judulController.text = kegiatan.judul;
      _nominalController.text = kegiatan.nominal == 0
          ? ''
          : kegiatan.nominal.toString();
      _tipe = kegiatan.tipe;

      if (_kategoriPengeluaran.contains(kegiatan.kategori)) {
        _kategori = kegiatan.kategori;
      }
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _nominalController.dispose();
    super.dispose();
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
      });
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _menyimpan = true;
    });

    try {
      final nominal = _tipe == TipeKeuangan.tanpa
          ? 0
          : int.parse(_nominalController.text.trim());

      final kegiatan = Kegiatan(
        id: widget.kegiatan?.id,
        judul: _judulController.text.trim(),
        tanggal: formatTanggal(_tanggal),
        selesai: widget.kegiatan?.selesai ?? false,
        tipe: _tipe,
        nominal: nominal,
        kategori: _tipe == TipeKeuangan.pengeluaran
            ? _kategori
            : '-',
      );

      if (_modeEdit) {
        await DbHelper.ubah(kegiatan);
      } else {
        await DbHelper.tambah(kegiatan);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _modeEdit
                ? 'Kegiatan berhasil diubah.'
                : 'Kegiatan berhasil ditambahkan.',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _menyimpan = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _modeEdit ? 'Ubah Kegiatan' : 'Tambah Kegiatan',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judulController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Judul kegiatan',
                hintText: 'Contoh: Membeli makan siang',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul kegiatan wajib diisi.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pilihTanggal,
              icon: const Icon(Icons.calendar_month),
              label: Text(formatTanggalIndonesia(_tanggal)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TipeKeuangan>(
              value: _tipe,
              decoration: const InputDecoration(
                labelText: 'Jenis kegiatan',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: TipeKeuangan.tanpa,
                  child: Text('Kegiatan biasa'),
                ),
                DropdownMenuItem(
                  value: TipeKeuangan.pemasukan,
                  child: Text('Pemasukan'),
                ),
                DropdownMenuItem(
                  value: TipeKeuangan.pengeluaran,
                  child: Text('Pengeluaran'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _tipe = value;
                  });
                }
              },
            ),
            if (_tipe != TipeKeuangan.tanpa) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _nominalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal (rupiah)',
                  hintText: 'Contoh: 25000',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_tipe == TipeKeuangan.tanpa) return null;

                  final nominal = int.tryParse(
                    value?.trim() ?? '',
                  );

                  if (nominal == null || nominal <= 0) {
                    return 'Nominal harus berupa angka lebih dari 0.';
                  }

                  return null;
                },
              ),
            ],
            if (_tipe == TipeKeuangan.pengeluaran) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _kategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori pengeluaran',
                  border: OutlineInputBorder(),
                ),
                items: _kategoriPengeluaran.map((kategori) {
                  return DropdownMenuItem(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _kategori = value;
                    });
                  }
                },
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _menyimpan ? null : _simpan,
              icon: _menyimpan
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.save),
              label: Text(
                _menyimpan ? 'Menyimpan...' : 'Simpan Kegiatan',
              ),
            ),
          ],
        ),
      ),
    );
  }
}