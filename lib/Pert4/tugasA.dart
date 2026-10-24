import 'package:flutter/material.dart';

class TugasAPage extends StatefulWidget {
  const TugasAPage({super.key});

  @override
  State<TugasAPage> createState() => _TugasAPageState();
}

class _TugasAPageState extends State<TugasAPage> {
  late Future<String> _future;

  @override
  void initState() {
    super.initState();
    _future = ambilSalam();
  }

  Future<String> ambilSalam() async {
    await Future.delayed(const Duration(seconds: 2));
    return 'Halo dari masa depan!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Future'),
      ),
      body: Center(
        child: FutureBuilder<String>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            return Text(
              snapshot.data!,
              style: const TextStyle(fontSize: 24),
            );
          },
        ),
      ),
    );
  }
}