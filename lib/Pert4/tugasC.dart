import 'dart:convert';

import 'package:http/http.dart' as http;

class Pengguna {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String website;

  Pengguna({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.website,
  });

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    return Pengguna(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
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