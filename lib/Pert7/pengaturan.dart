import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<bool> modeGelap = ValueNotifier<bool>(false);

final ValueNotifier<Color> warnaTema =
ValueNotifier<Color>(Colors.teal);

final ValueNotifier<int> targetTabungan =
ValueNotifier<int>(20000);

final List<Color> pilihanWarna = [
  Colors.teal,
  Colors.blue,
  Colors.deepPurple,
  Colors.orange,
  Colors.pink,
];

Future<void> muatPengaturan() async {
  final prefs = await SharedPreferences.getInstance();

  modeGelap.value = prefs.getBool('tabungku_mode_gelap') ?? false;

  warnaTema.value = Color(
    prefs.getInt('tabungku_warna_tema') ??
        Colors.teal.toARGB32(),
  );

  targetTabungan.value =
      prefs.getInt('tabungku_target') ?? 20000;
}

Future<void> simpanModeGelap(bool value) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setBool('tabungku_mode_gelap', value);
  modeGelap.value = value;
}

Future<void> simpanWarnaTema(Color warna) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setInt(
    'tabungku_warna_tema',
    warna.toARGB32(),
  );

  warnaTema.value = warna;
}

Future<void> simpanTargetTabungan(int nominal) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setInt('tabungku_target', nominal);
  targetTabungan.value = nominal;
}