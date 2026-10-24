import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
    );
  }
}

class Komentar {
  final int id;
  final int postId;
  final String name;
  final String email;
  final String body;

  Komentar({
    required this.id,
    required this.postId,
    required this.name,
    required this.email,
    required this.body,
  });

  factory Komentar.fromJson(Map<String, dynamic> json) {
    return Komentar(
      id: json['id'],
      postId: json['postId'],
      name: json['name'],
      email: json['email'],
      body: json['body'],
    );
  }
}

Future<List<Post>> ambilPostingan() async {
  final response = await http
      .get(
    Uri.parse('https://jsonplaceholder.typicode.com/posts'),
  )
      .timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('Gagal memuat postingan');
  }

  final List<dynamic> data = jsonDecode(response.body);

  return data
      .map((json) => Post.fromJson(json))
      .toList();
}

Future<List<Komentar>> ambilKomentar(int postId) async {
  final response = await http
      .get(
    Uri.parse(
      'https://jsonplaceholder.typicode.com/posts/$postId/comments',
    ),
  )
      .timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('Gagal memuat komentar');
  }

  final List<dynamic> data = jsonDecode(response.body);

  return data
      .map((json) => Komentar.fromJson(json))
      .toList();
}

class DaftarPostinganPage extends StatefulWidget {
  const DaftarPostinganPage({super.key});

  @override
  State<DaftarPostinganPage> createState() => _DaftarPostinganPageState();
}

class _DaftarPostinganPageState extends State<DaftarPostinganPage> {
  late Future<List<Post>> _future;

  @override
  void initState() {
    super.initState();
    _future = ambilPostingan();
  }

  void _muatUlang() {
    setState(() {
      _future = ambilPostingan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Postingan'),
        actions: [
          IconButton(
            onPressed: _muatUlang,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
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

          final postingan = snapshot.data ?? [];

          if (postingan.isEmpty) {
            return const Center(
              child: Text('Tidak ada postingan'),
            );
          }

          return ListView.builder(
            itemCount: postingan.length,
            itemBuilder: (context, index) {
              final post = postingan[index];

              return ListTile(
                title: Text(
                  post.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  post.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPostinganPage(
                        post: post,
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

class DetailPostinganPage extends StatefulWidget {
  final Post post;

  const DetailPostinganPage({
    super.key,
    required this.post,
  });

  @override
  State<DetailPostinganPage> createState() => _DetailPostinganPageState();
}

class _DetailPostinganPageState extends State<DetailPostinganPage> {
  late Future<List<Komentar>> _futureKomentar;

  @override
  void initState() {
    super.initState();
    _futureKomentar = ambilKomentar(widget.post.id);
  }

  void _muatUlangKomentar() {
    setState(() {
      _futureKomentar = ambilKomentar(widget.post.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Postingan'),
      ),
      body: FutureBuilder<List<Komentar>>(
        future: _futureKomentar,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  widget.post.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(widget.post.body),
                const SizedBox(height: 24),
                const Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            );
          }

          if (snapshot.hasError) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  widget.post.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(widget.post.body),
                const SizedBox(height: 24),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _muatUlangKomentar,
                  child: const Text('Coba lagi'),
                ),
              ],
            );
          }

          final komentar = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                widget.post.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(widget.post.body),
              const SizedBox(height: 24),
              const Text(
                'Komentar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...komentar.map(
                    (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.name),
                  subtitle: Text(
                    '${item.email}\n${item.body}',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}