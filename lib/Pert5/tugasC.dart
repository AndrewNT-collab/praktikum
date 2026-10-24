import 'package:flutter/material.dart';
import 'tugasB.dart';

class TugasCPage extends StatefulWidget {
  const TugasCPage({super.key});

  @override
  State<TugasCPage> createState() => _TugasCPageState();
}

class _TugasCPageState extends State<TugasCPage> {
  List<Catatan> _catatan = [];

  @override
  void initState() {
    super.initState();
    _muatCatatan();
  }

  Future<void> _muatCatatan() async {
    final data = await DbHelper.getCatatan();

    setState(() {
      _catatan = data;
    });
  }

  Future<void> _tambahCatatan() async {
    final judulController = TextEditingController();
    final isiController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Catatan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                ),
              ),
              TextField(
                controller: isiController,
                decoration: const InputDecoration(
                  labelText: 'Isi',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (judulController.text.isEmpty ||
                    isiController.text.isEmpty) {
                  return;
                }

                final catatan = Catatan(
                  judul: judulController.text,
                  isi: isiController.text,
                  waktu: DateTime.now().toString(),
                );

                await DbHelper.insertCatatan(catatan);
                if (context.mounted) {
                  Navigator.pop(context);
                }
                await _muatCatatan();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _hapusCatatan(int id) async {
    await DbHelper.deleteCatatan(id);
    await _muatCatatan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Catatan'),
      ),
      body: _catatan.isEmpty
          ? const Center(
        child: Text('Belum ada catatan'),
      )
          : ListView.builder(
        itemCount: _catatan.length,
        itemBuilder: (context, index) {
          final catatan = _catatan[index];

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
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahCatatan,
        child: const Icon(Icons.add),
      ),
    );
  }
}