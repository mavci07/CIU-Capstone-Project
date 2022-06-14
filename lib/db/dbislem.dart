import 'dart:io';

import 'package:karakaya_soguk/static/global.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:karakaya_soguk/db/kullanicimodel.dart';
import 'package:http/http.dart' as http;

class DBKullanici {
  static Database _database;

  String _ktablo = "kullanici";

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory dd = await getExternalStorageDirectory();
    String dbPath = join(dd.path, "karakayadb.db"); //getDatabasesPath()
    var notesDb = await openDatabase(dbPath, version: 1, onCreate: createDb);
    return notesDb;
  }

  void createDb(Database db, int version) async {
    await db.execute(
        "CREATE TABLE IF NOT EXISTS  kullanici (id INTEGER PRIMARY key AUTOINCREMENT, kuladi TEXT, name TEXT,pass TEXT,grup INTEGER,durum INTEGER, nakitkarsihesap TEXT,kkkarsihesap TEXT,serino TEXT, rutkodu TEXT);");
  }

  Future<List> kulliste() async {
    Database dh = await this.database;
    var say = await dh.rawQuery("select * from $_ktablo");
    if (say.length > 0)
      return say.toList();
    else
      return say;
  }

  Future<List> kulkontrol(String kadi, String sifre) async {
    Database db = await this.database;
    var maps = await db.rawQuery("Select * from $_ktablo where kuladi='" +
        kadi +
        "' and pass='" +
        sifre +
        "'");

    return maps.toList();
  }

  Future<int> temizle() async {
    Database db = await this.database;
    Sqflite.firstIntValue(await db.rawQuery(
        "DELETE FROM $_ktablo;delete from sqlite_sequence where name='$_ktablo';"));
    return null;
  }

  Future<int> insert(Kullanicilar note) async {
    Database db = await this.database;
    var result = await db.insert("$_ktablo", note.toMap());
    return result;
  }

  Future<int> delete(int id) async {
    Database db = await this.database;
    var result = await db.rawDelete("delete from $_ktablo where id=$id");
    return result;
  }

  Future<int> update(Kullanicilar note) async {
    Database db = await this.database;
    var result = await db
        .update("$_ktablo", note.toMap(), where: "id=?", whereArgs: [note.id]);
    return result;
  }

  Future<http.Response> kulcek() async {
    try {
      final sonuc = await http.get('http://' + Global.sunucu + '/skulcek');
      return sonuc;
    } on SocketException {
      throw SocketException("Sunucuya Erisilemedi");
    } on HttpException {
      throw HttpException("Veri Gönderilemedi");
    } on FormatException {
      throw FormatException("Bozuk Veri Biçimi");
    }
  }

  Future<http.Response> okundu(String msid) async {
    try {
      return await http
          .get('http://' + Global.sunucu + '/home/mesajokundu?gelen=' + msid);
    } on SocketException {
      throw SocketException("Sunucuya Erisilemedi");
    } on HttpException {
      throw HttpException("Veri Gönderilemedi");
    } on FormatException {
      throw FormatException("Bozuk Veri Biçimi");
    }
  }
}
