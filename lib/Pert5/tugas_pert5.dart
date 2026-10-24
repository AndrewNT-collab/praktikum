import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Pengeluaran {
  final int? id;
  final String nama;
  final double jumlah;
  final String kategori;
  final String tanggal;

  Pengeluaran({
    this.id,
    required this.nama,
    required this.jumlah,
    required this.kategori,
    required this.tanggal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'jumlah': jumlah,
      'kategori': kategori,
      'tanggal': tanggal,
    };
  }

  factory Pengeluaran.fromMap(Map<String, dynamic> map) {
    return Pengeluaran(
      id: map['id'],
      nama: map['nama'],
      jumlah: map['jumlah'],
      kategori: map['kategori'],
      tanggal: map['tanggal'],
    );
  }
}

class DatabasePengeluaran {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final dbPath = path.join(
      await getDatabasesPath(),
      'pengeluaran.db',
    );

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pengeluaran(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            jumlah REAL NOT NULL,
            kategori TEXT NOT NULL,
            tanggal TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  static Future<int> tambah(Pengeluaran pengeluaran) async {
    final db = await database;

    return db.insert(
      'pengeluaran',
      pengeluaran.toMap(),
    );
  }

  static Future<List<Pengeluaran>> ambilSemua() async {
    final db = await database;

    final data = await db.query(
      'pengeluaran',
      orderBy: 'id DESC',
    );

    return data
        .map((item) => Pengeluaran.fromMap(item))
        .toList();
  }

  static Future<int> ubah(Pengeluaran pengeluaran) async {
    final db = await database;

    return db.update(
      'pengeluaran',
      pengeluaran.toMap(),
      where: 'id = ?',
      whereArgs: [pengeluaran.id],
    );
  }

  static Future<int> hapus(int id) async {
    final db = await database;

    return db.delete(
      'pengeluaran',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

class TugasPert5Page extends StatefulWidget {
  const TugasPert5Page({super.key});

  @override
  State<TugasPert5Page> createState() => _TugasPert5PageState();
}

class _TugasPert5PageState extends State<TugasPert5Page> {
  List<Pengeluaran> _pengeluaran = [];
  bool _gelap = false;

  @override
  void initState() {
    super.initState();
    _muatData();
    _muatPengaturan();
  }

  Future<void> _muatPengaturan() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _gelap = prefs.getBool('gelap') ?? false;
    });
  }

  Future<void> _ubahTema(bool nilai) async {
    setState(() {
      _gelap = nilai;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gelap', nilai);
  }

  Future<void> _muatData() async {
    final data = await DatabasePengeluaran.ambilSemua();

    if (!mounted) return;

    setState(() {
      _pengeluaran = data;
    });
  }

  double get _total {
    return _pengeluaran.fold(
      0,
          (total, item) => total + item.jumlah,
    );
  }

  Future<void> _tambahPengeluaran() async {
    final namaController = TextEditingController();
    final jumlahController = TextEditingController();
    String kategori = 'Makanan';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Pengeluaran'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                      ),
                    ),
                    TextField(
                      controller: jumlahController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah',
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: kategori,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Makanan',
                          child: Text('Makanan'),
                        ),
                        DropdownMenuItem(
                          value: 'Transportasi',
                          child: Text('Transportasi'),
                        ),
                        DropdownMenuItem(
                          value: 'Belanja',
                          child: Text('Belanja'),
                        ),
                        DropdownMenuItem(
                          value: 'Lainnya',
                          child: Text('Lainnya'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            kategori = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nama = namaController.text.trim();
                    final jumlah = double.tryParse(
                      jumlahController.text.trim(),
                    );

                    if (nama.isEmpty || jumlah == null || jumlah <= 0) {
                      return;
                    }

                    final pengeluaran = Pengeluaran(
                      nama: nama,
                      jumlah: jumlah,
                      kategori: kategori,
                      tanggal: DateTime.now()
                          .toString()
                          .substring(0, 10),
                    );

                    await DatabasePengeluaran.tambah(
                      pengeluaran,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                    }

                    await _muatData();
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _hapusPengeluaran(int id) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Hapus pengeluaran ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (konfirmasi == true) {
      await DatabasePengeluaran.hapus(id);
      await _muatData();
    }
  }


  Future<void> _editPengeluaran(Pengeluaran item) async {
    final namaController = TextEditingController(text: item.nama);
    final jumlahController = TextEditingController(
      text: item.jumlah.toString(),
    );

    String kategori = item.kategori;

    final hasil = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Pengeluaran'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama pengeluaran',
                      ),
                    ),
                    TextField(
                      controller: jumlahController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Jumlah',
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: kategori,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Makanan',
                          child: Text('Makanan'),
                        ),
                        DropdownMenuItem(
                          value: 'Transportasi',
                          child: Text('Transportasi'),
                        ),
                        DropdownMenuItem(
                          value: 'Belanja',
                          child: Text('Belanja'),
                        ),
                        DropdownMenuItem(
                          value: 'Lainnya',
                          child: Text('Lainnya'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            kategori = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nama = namaController.text.trim();
                    final jumlah = double.tryParse(
                      jumlahController.text.trim().replaceAll(',', '.'),
                    );

                    if (nama.isEmpty || jumlah == null || jumlah <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Nama wajib diisi dan jumlah harus lebih dari 0.',
                          ),
                        ),
                      );
                      return;
                    }

                    final pengeluaranBaru = Pengeluaran(
                      id: item.id,
                      nama: nama,
                      jumlah: jumlah,
                      kategori: kategori,
                      tanggal: item.tanggal,
                    );

                    await DatabasePengeluaran.ubah(pengeluaranBaru);

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    namaController.dispose();
    jumlahController.dispose();

    if (hasil == true && mounted) {
      await _muatData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengeluaran berhasil diperbarui.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
          brightness: _gelap ? Brightness.dark : Brightness.light,
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
        ),
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Pencatat Pengeluaran'),
        actions: [
          Row(
            children: [
              const Icon(Icons.light_mode),
              Switch(
                value: _gelap,
                onChanged: _ubahTema,
              ),
              const Icon(Icons.dark_mode),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pengeluaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Rp ${_total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _pengeluaran.isEmpty
                ? const Center(
              child: Text('Belum ada pengeluaran'),
            )
                : ListView.builder(
              itemCount: _pengeluaran.length,
              itemBuilder: (context, index) {
                final item = _pengeluaran[index];

                return ListTile(
                  title: Text(item.nama),
                  subtitle: Text(
                    '${item.kategori} • ${item.tanggal}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Rp ${item.jumlah.toStringAsFixed(0)}',
                      ),
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () {
                          _editPengeluaran(item);
                        },
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        tooltip: 'Hapus',
                        onPressed: () {
                          _hapusPengeluaran(item.id!);
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
          floatingActionButton: FloatingActionButton(
          onPressed: _tambahPengeluaran,
          child: const Icon(Icons.add),
        ),
    ),
    );
  }
}