
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<ThemeMode> themeMode =
ValueNotifier(ThemeMode.light);

final ValueNotifier<Color> seedColor =
ValueNotifier(Colors.blue);

const List<Color> pilihanWarna = [
  Colors.blue,
  Colors.green,
  Colors.purple,
];

Future<void> muatPengaturanTema() async {
  final prefs = await SharedPreferences.getInstance();

  final modeGelap = prefs.getBool('modeGelap') ?? false;
  final warna = prefs.getInt('warnaTema') ?? 0;

  themeMode.value =
  modeGelap ? ThemeMode.dark : ThemeMode.light;

  seedColor.value =
  pilihanWarna[warna.clamp(0, pilihanWarna.length - 1)];
}
