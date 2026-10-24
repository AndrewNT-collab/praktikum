import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Pengguna {
  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final String city;

  Pengguna({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.city,
  });

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    return Pengguna(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
      city: json['address']['city'],
    );
  }
}

Future<List<Pengguna>> ambilPengguna() async {
  final response = await http
      .get(
    Uri.parse('https://jsonplaceholder.typicode.com/users'),
  )
      .timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('Gagal memuat data');
  }

  final List<dynamic> data = jsonDecode(response.body);

  return data
      .map((json) => Pengguna.fromJson(json))
      .toList();
}

class LatihanMandiriPage extends StatefulWidget {
  const LatihanMandiriPage({super.key});

  @override
  State<LatihanMandiriPage> createState() => _LatihanMandiriPageState();
}

class _LatihanMandiriPageState extends State<LatihanMandiriPage> {
  late Future<List<Pengguna>> _future;

  @override
  void initState() {
    super.initState();
    _future = ambilPengguna();
  }

  Future<void> _muatUlang() async {
    setState(() {
      _future = ambilPengguna();
    });

    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<List<Pengguna>>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text('Daftar Pengguna');
            }

            return Text(
              'Daftar Pengguna (${snapshot.data!.length})',
            );
          },
        ),
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

          if (pengguna.isEmpty) {
            return const Center(
              child: Text('Tidak ada data'),
            );
          }

          return RefreshIndicator(
            onRefresh: _muatUlang,
            child: ListView.builder(
              itemCount: pengguna.length,
              itemBuilder: (context, index) {
                final user = pengguna[index];

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(user.name[0]),
                  ),
                  title: Text(user.name),
                  subtitle: Text(
                    '${user.username} - ${user.city}',
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}