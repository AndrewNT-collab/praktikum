import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'Pert7/db_helper.dart';
import 'Pert7/form_kegiatan_page.dart';
import 'Pert7/kegiatan.dart';
import 'Pert7/pengaturan.dart';
import 'Pert7/shell_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID');
  await muatPengaturan();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        modeGelap,
        warnaTema,
      ]),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TabungKu',
          themeMode: modeGelap.value
              ? ThemeMode.dark
              : ThemeMode.light,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: warnaTema.value,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: warnaTema.value,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          onGenerateRoute: (settings) {
            if (settings.name == '/form') {
              final args = settings.arguments;

              if (args is Kegiatan) {
                return MaterialPageRoute(
                  builder: (context) => FormKegiatanPage(
                    kegiatan: args,
                  ),
                  settings: settings,
                );
              }

              return MaterialPageRoute(
                builder: (context) => FormKegiatanPage(
                  tanggalAwal: args as String?,
                ),
                settings: settings,
              );
            }

            return null;
          },
          home: const ShellPage(),
        );
      },
    );
  }
}