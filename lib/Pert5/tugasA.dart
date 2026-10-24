import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TugasAPage extends StatefulWidget {
  const TugasAPage({super.key});

  @override
  State<TugasAPage> createState() => _TugasAPageState();
}

class _TugasAPageState extends State<TugasAPage> {
  final TextEditingController _controller = TextEditingController();
  String _nama = '';

  @override
  void initState() {
    super.initState();
    _muatNama();
  }

  Future<void> _muatNama() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nama = prefs.getString('nama') ?? '';
    });
  }

  Future<void> _simpanNama() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nama', _controller.text);

    setState(() {
      _nama = _controller.text;
    });
  }

  Future<void> _hapusNama() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nama');

    setState(() {
      _nama = '';
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SharedPreferences'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nama',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _simpanNama,
              child: const Text('Simpan'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _hapusNama,
              child: const Text('Hapus'),
            ),
            const SizedBox(height: 24),
            Text(
              _nama.isEmpty ? 'Belum ada nama' : 'Nama: $_nama',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}