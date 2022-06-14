import 'package:karakaya_soguk/model/stokmodel.dart';
import 'package:karakaya_soguk/static/global.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';

class DbStoklar {
  static Database _database;

  String _tablo = "stoklar";

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initializeDatabase();
    return _database;
  }

  static const stoklar =
      '''CREATE TABLE IF NOT EXISTS stoklar (sid INTEGER PRIMARY key AUTOINCREMENT, stokkod TEXT, stokad TEXT,birim TEXT,barkod1 TEXT,barkod2 TEXT, barkod3 TEXT,sfiyat1 TEXT, sfiyat2 TEXT,kod4 TEXT,kod9 TEXT);''';
  Future<Database> initializeDatabase() async {
    print("Stok Tablo Kontrol");
    Directory dd =
        await getExternalStorageDirectory(); //getApplicationDocumentsDirectory();
    String path = join(dd.path, "karakayadb.db");
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(stoklar);
      print("Stok Tablo yok oluşturuluyor...");
    });
  }

  Future<List> stokliste() async {
    var dbClient = await this.database;
    var result =
        await dbClient.rawQuery('SELECT * FROM $_tablo order by stokad');
    return result.toList();
  }

  Future<List> grupliste() async {
    var dbClient = await this.database;
    var result =
        await dbClient.rawQuery('SELECT kod9 FROM $_tablo group by kod9');
    return result.toList();
  }

  Future<List> stokara(String gelen) async {
    var dbClient = await this.database;
    var result = await dbClient.rawQuery(
        "SELECT * FROM $_tablo where stokkod='" +
            gelen.toUpperCase() +
            "' or stokad='" +
            gelen.toUpperCase() +
            "' or barkod1='" +
            gelen.toUpperCase() +
            "' or barkod2='" +
            gelen.toUpperCase() +
            "'  or barkod3='" +
            gelen.toUpperCase() +
            "' order by stokad");
    return result.toList();
  }

  Future<List> stokaralike(String gelen) async {
    var dbClient = await this.database;
    var result = await dbClient.rawQuery(
        "SELECT * FROM $_tablo where stokkod like '%" +
            gelen +
            "%' or stokad like '%" +
            gelen +
            "%' order by stokad");
    //replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace( stokad, 'á','a'), 'ã','a'), 'â','a'), 'é','e'), 'ê','e'), 'Ä°','I'),'Ã–','O') ,'Ä','G') ,'Ãœ','U'),'Å','S'), 'Ã‡','C') asc");
    return result.toList();
  }

  Future<List> stokaragrup(String gelen) async {
    var dbClient = await this.database;
    var result = await dbClient.rawQuery(
        "SELECT * FROM $_tablo where kod9 like '%" +
            gelen +
            "%' and sfiyat1<>'0,00' order by stokad");
    return result.toList();
  }

  Future<int> sksay() async {
    Database db = await this.database;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $_tablo'));
    return count;
  }

  Future<int> temizle() async {
    Database db = await this.database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
        "DELETE FROM $_tablo;delete from sqlite_sequence where name='$_tablo';"));
    return count;
  }

  Future<int> insert(Stokmodel note) async {
    Database db = await this.database;
    var result = await db.insert("$_tablo", note.toMap());
    return result;
  }

  Future<int> delete(int sid) async {
    Database db = await this.database;
    var result = await db.rawDelete("delete from $_tablo where sid=$sid");
    return result;
  }

  Future<int> update(Stokmodel note) async {
    Database db = await this.database;
    var result = await db
        .update("$_tablo", note.toMap(), where: "sid=?", whereArgs: [note.sid]);
    return result;
  }

  Future<http.Response> stokgetir() async {
    try {
      final sonuc = await http.get('http://' + Global.sunucu + '/stokliste');
      return sonuc;
    } on SocketException {
      throw SocketException("Sunucuya Erisilemedi");
    } on HttpException {
      throw HttpException("Veri Gönderilemedi");
    } on FormatException {
      throw FormatException("Bozuk Veri Biçimi");
    }
  }
}
