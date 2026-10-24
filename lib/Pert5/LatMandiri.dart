import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tugasB.dart';

class LatihanMandiriPage extends StatefulWidget {
  const LatihanMandiriPage({super.key});

  @override
  State<LatihanMandiriPage> createState() => _LatihanMandiriPageState();
}

class _LatihanMandiriPageState extends State<LatihanMandiriPage> {
  List<Catatan> _catatan = [];
  String _kata = '';
  String _urutan = 'terbaru';

  @override
  void initState() {
    super.initState();
    _muatPengaturan();
    _muatCatatan();
  }

  Future<void> _muatPengaturan() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _urutan = prefs.getString('urutan') ?? 'terbaru';
    });
  }

  Future<void> _simpanUrutan(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('urutan', value);

    setState(() {
      _urutan = value;
    });

    await _muatCatatan();
  }

  Future<void> _muatCatatan() async {
    final data = await DbHelper.getCatatan();

    setState(() {
      _catatan = data;
    });
  }

  Future<void> _hapusCatatan(int id) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Hapus catatan ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (konfirmasi == true) {
      await DbHelper.deleteCatatan(id);
      await _muatCatatan();
    }
  }

  List<Catatan> get _hasilPencarian {
    if (_kata.isEmpty) {
      return _catatan;
    }

    return _catatan
        .where(
          (catatan) =>
          catatan.judul.toLowerCase().contains(_kata.toLowerCase()),
    )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final hasil = _hasilPencarian;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Latihan Mandiri'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Cari berdasarkan judul',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _kata = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: _urutan,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: 'terbaru',
                  child: Text('Terbaru'),
                ),
                DropdownMenuItem(
                  value: 'terlama',
                  child: Text('Terlama'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  _simpanUrutan(value);
                }
              },
            ),
          ),
          Expanded(
            child: hasil.isEmpty
                ? const Center(
              child: Text('Belum ada catatan'),
            )
                : ListView.builder(
              itemCount: hasil.length,
              itemBuilder: (context, index) {
                final catatan = hasil[index];

                return ListTile(
                  title: Text(catatan.judul),
                  subtitle: Text(catatan.isi),
                  trailing: IconButton(
                    onPressed: () => _hapusCatatan(catatan.id!),
                    icon: const Icon(Icons.delete),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}