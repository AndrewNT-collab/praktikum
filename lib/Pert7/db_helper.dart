import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'kegiatan.dart';

final ValueNotifier<int> versiData = ValueNotifier<int>(0);

class DbHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = join(
      await getDatabasesPath(),
      'tabungku.db',
    );

    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE kegiatan(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            judul TEXT NOT NULL,
            tanggal TEXT NOT NULL,
            selesai INTEGER NOT NULL DEFAULT 0,
            tipe TEXT NOT NULL DEFAULT 'tanpa',
            nominal INTEGER NOT NULL DEFAULT 0,
            kategori TEXT NOT NULL DEFAULT '-'
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_kegiatan_tanggal
          ON kegiatan(tanggal)
        ''');
      },
    );
  }

  static void _beriTahuPerubahan() {
    versiData.value++;
  }

  static Future<int> tambah(Kegiatan kegiatan) async {
    final db = await database;

    final id = await db.insert(
      'kegiatan',
      kegiatan.toMap()..remove('id'),
    );

    _beriTahuPerubahan();
    return id;
  }

  static Future<List<Kegiatan>> semua() async {
    final db = await database;

    final data = await db.query(
      'kegiatan',
      orderBy: 'tanggal DESC, id DESC',
    );

    return data.map(Kegiatan.fromMap).toList();
  }

  static Future<List<Kegiatan>> pada(String tanggal) async {
    final db = await database;

    final data = await db.query(
      'kegiatan',
      where: 'tanggal = ?',
      whereArgs: [tanggal],
      orderBy: 'id DESC',
    );

    return data.map(Kegiatan.fromMap).toList();
  }

  static Future<int> ubah(Kegiatan kegiatan) async {
    if (kegiatan.id == null) {
      throw ArgumentError('ID kegiatan tidak boleh kosong.');
    }

    final db = await database;

    final jumlah = await db.update(
      'kegiatan',
      kegiatan.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [kegiatan.id],
    );

    if (jumlah > 0) {
      _beriTahuPerubahan();
    }

    return jumlah;
  }

  static Future<int> hapus(int id) async {
    final db = await database;

    final jumlah = await db.delete(
      'kegiatan',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (jumlah > 0) {
      _beriTahuPerubahan();
    }

    return jumlah;
  }

  static Future<int> ubahStatus(
      int id,
      bool selesai,
      ) async {
    final db = await database;

    final jumlah = await db.update(
      'kegiatan',
      {'selesai': selesai ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );

    if (jumlah > 0) {
      _beriTahuPerubahan();
    }

    return jumlah;
  }

  static Future<Ringkasan> ringkasan(String tanggal) async {
    final db = await database;

    final hasil = await db.rawQuery('''
      SELECT
        COUNT(*) AS jumlah,
        COALESCE(SUM(selesai), 0) AS selesai,
        COALESCE(
          SUM(CASE WHEN tipe = 'pemasukan'
              THEN nominal ELSE 0 END),
          0
        ) AS masuk,
        COALESCE(
          SUM(CASE WHEN tipe = 'pengeluaran'
              THEN nominal ELSE 0 END),
          0
        ) AS keluar
      FROM kegiatan
      WHERE tanggal = ?
    ''', [tanggal]);

    final baris = hasil.first;

    return Ringkasan(
      jumlahKegiatan: (baris['jumlah'] as num).toInt(),
      selesai: (baris['selesai'] as num).toInt(),
      pemasukan: (baris['masuk'] as num).toInt(),
      pengeluaran: (baris['keluar'] as num).toInt(),
    );
  }

  static Future<Map<String, int>> pengeluaranPerKategori(
      String tanggal,
      ) async {
    final db = await database;

    final hasil = await db.rawQuery('''
      SELECT kategori, SUM(nominal) AS total
      FROM kegiatan
      WHERE tanggal = ?
        AND tipe = 'pengeluaran'
      GROUP BY kategori
      ORDER BY total DESC
    ''', [tanggal]);

    return {
      for (final baris in hasil)
        baris['kategori'] as String:
        (baris['total'] as num).toInt(),
    };
  }

  static Future<List<Map<String, Object?>>> tujuhHariTerakhir(
      String tanggalAkhir,
      ) async {
    final db = await database;

    final hasil = await db.rawQuery('''
      SELECT
        tanggal,
        COUNT(*) AS jumlah,
        COALESCE(
          SUM(CASE WHEN tipe = 'pemasukan'
              THEN nominal ELSE 0 END),
          0
        ) AS masuk,
        COALESCE(
          SUM(CASE WHEN tipe = 'pengeluaran'
              THEN nominal ELSE 0 END),
          0
        ) AS keluar
      FROM kegiatan
      WHERE tanggal BETWEEN date(?, '-6 days') AND ?
      GROUP BY tanggal
      ORDER BY tanggal ASC
    ''', [tanggalAkhir, tanggalAkhir]);

    return hasil;
  }
}