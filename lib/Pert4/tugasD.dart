import 'package:flutter/material.dart';
import 'tugasC.dart';
import 'tugasE.dart';

class PenggunaPage extends StatefulWidget {
  const PenggunaPage({super.key});

  @override
  State<PenggunaPage> createState() => _PenggunaPageState();
}

class _PenggunaPageState extends State<PenggunaPage> {
  late Future<List<Pengguna>> _future;

  @override
  void initState() {
    super.initState();
    _future = ambilPengguna();
  }

  void _muatUlang() {
    setState(() {
      _future = ambilPengguna();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna'),
        actions: [
          IconButton(
            onPressed: _muatUlang,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Pengguna>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _muatUlang,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }

          final pengguna = snapshot.data ?? [];

          return ListView.builder(
            itemCount: pengguna.length,
            itemBuilder: (context, index) {
              final user = pengguna[index];

              return ListTile(
                leading: CircleAvatar(
                  child: Text(user.name[0]),
                ),
                title: Text(user.name),
                subtitle: Text(user.email),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPenggunaPage(
                        pengguna: user,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}