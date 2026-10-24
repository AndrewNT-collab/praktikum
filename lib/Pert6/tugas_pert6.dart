import 'halaman_detail.dart';
import 'package:flutter/material.dart';
import '../tema_global.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TugasPert6Page extends StatefulWidget {
  const TugasPert6Page({super.key});

  @override
  State<TugasPert6Page> createState() => _TugasPert6PageState();
}

class _TugasPert6PageState extends State<TugasPert6Page> {
  int tabAktif = 0;

  @override
  Widget build(BuildContext context) {
    final halaman = [

      ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: daftarItem.length,
        itemBuilder: (context, index) {
          final item = daftarItem[index];
          final tema = Theme.of(context);

          return Card(
            child: ListTile(
              leading: Hero(
                tag: 'ikon-${item.nama}',
                child: CircleAvatar(
                  backgroundColor: tema.colorScheme.primaryContainer,
                  child: Icon(
                    item.ikon,
                    color: tema.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              title: Text(
                item.nama,
                style: tema.textTheme.titleMedium,
              ),
              subtitle: Text(item.deskripsi),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detail',
                  arguments: item,
                );
              },
            ),
          );
        },
      ),

      const AnimasiTab(),

      ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Pengaturan Tampilan',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Mode Gelap'),
            value: themeMode.value == ThemeMode.dark,
            onChanged: (aktif) async {
              themeMode.value =
              aktif ? ThemeMode.dark : ThemeMode.light;

              final prefs =
              await SharedPreferences.getInstance();
              await prefs.setBool('modeGelap', aktif);
            },
          ),
          const SizedBox(height: 16),
          const Text('Pilih Warna Tema'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: List.generate(pilihanWarna.length, (index) {
              final warna = pilihanWarna[index];

              return GestureDetector(
                onTap: () async {
                  seedColor.value = warna;

                  final prefs =
                  await SharedPreferences.getInstance();
                  await prefs.setInt('warnaTema', index);
                },
                child: CircleAvatar(
                  backgroundColor: warna,
                  child: seedColor.value == warna
                      ? const Icon(
                    Icons.check,
                    color: Colors.white,
                  )
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum Pertemuan 6'),
      ),
      body: halaman[tabAktif],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tabAktif,
        onDestinationSelected: (index) {
          setState(() => tabAktif = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.animation),
            label: 'Animasi',
          ),
          NavigationDestination(
            icon: Icon(Icons.palette),
            label: 'Tema',
          ),
        ],
      ),
    );
  }
}

class AnimasiTab extends StatefulWidget {
  const AnimasiTab({super.key});

  @override
  State<AnimasiTab> createState() => _AnimasiTabState();
}

class _AnimasiTabState extends State<AnimasiTab>
    with SingleTickerProviderStateMixin {
  bool diperbesar = false;

  late final AnimationController controller;
  late final Animation<double> rotasi;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    rotasi = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Demo Animasi',
          style: tema.textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: diperbesar ? 200 : 120,
            height: diperbesar ? 200 : 120,
            decoration: BoxDecoration(
              color: tema.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(
                diperbesar ? 100 : 24,
              ),
            ),
            child: Icon(
              Icons.flutter_dash,
              size: diperbesar ? 100 : 64,
              color: tema.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () {
            setState(() {
              diperbesar = !diperbesar;
            });
          },
          child: const Text('Ubah Bentuk'),
        ),
        const Divider(height: 40),
        Center(
          child: RotationTransition(
            turns: rotasi,
            child: Icon(
              Icons.settings,
              size: 100,
              color: tema.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () {
            if (controller.isAnimating) {
              controller.stop();
            } else {
              controller.forward(from: 0);
            }
          },
          child: const Text('Putar Ikon'),
        ),
      ],
    );
  }
}

