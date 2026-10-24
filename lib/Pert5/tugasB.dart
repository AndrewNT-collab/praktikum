import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Catatan {
  final int? id;
  final String judul;
  final String isi;
  final String waktu;
  final String dibuat;

  Catatan({
    this.id,
    required this.judul,
    required this.isi,
    required this.waktu,
    required this.dibuat,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'waktu': waktu,
      'dibuat': dibuat,
    };
  }

  factory Catatan.fromMap(Map<String, dynamic> map) {
    return Catatan(
      id: map['id'],
      judul: map['judul'],
      isi: map['isi'],
      waktu: map['waktu'],
      dibuat: map['dibuat'] ?? '',
    );
  }
}

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
    final path = join(
      await getDatabasesPath(),
      'catatan.db',
    );

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE catatan(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            judul TEXT NOT NULL,
            isi TEXT NOT NULL,
            waktu TEXT NOT NULL,
            dibuat TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE catatan ADD COLUMN dibuat TEXT',
          );
        }
      },
    );
  }

  static Future<int> insertCatatan(Catatan catatan) async {
    final db = await database;

    return db.insert(
      'catatan',
      catatan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Catatan>> getCatatan() async {
    final db = await database;

    final maps = await db.query(
      'catatan',
      orderBy: 'id DESC',
    );

    return maps.map((map) => Catatan.fromMap(map)).toList();
  }

  static Future<int> updateCatatan(Catatan catatan) async {
    final db = await database;

    return db.update(
      'catatan',
      catatan.toMap(),
      where: 'id = ?',
      whereArgs: [catatan.id],
    );
  }

  static Future<int> deleteCatatan(int id) async {
    final db = await database;

    return db.delete(
      'catatan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}