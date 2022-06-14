import 'package:karakaya_soguk/model/carimodel.dart';
import 'package:karakaya_soguk/static/global.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class DbCariler {
  static Database _database;

  String _tablo = "cariler";

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initializeDatabase();
    return _database;
  }

  static const kullanici =
      '''CREATE TABLE IF NOT EXISTS  kullanici (id INTEGER PRIMARY key AUTOINCREMENT, kuladi TEXT, name TEXT,pass TEXT,grup INTEGER,durum INTEGER, nakitkarsihesap TEXT,kkkarsihesap TEXT,serino TEXT, rutkodu TEXT);''';
  static const cariler =
      '''CREATE TABLE IF NOT EXISTS  cariler (cid INTEGER PRIMARY key AUTOINCREMENT, carikod TEXT, cariunvan TEXT,borc TEXT,alacak TEXT,bakiye TEXT,grupkodu TEXT,bolgekodu INTEGER);''';
  static const stoklar =
      '''CREATE TABLE IF NOT EXISTS  stoklar (sid INTEGER PRIMARY key AUTOINCREMENT, stokkod TEXT, stokad TEXT,birim TEXT,barkod1 TEXT,barkod2 TEXT, barkod3 TEXT,sfiyat1 TEXT, sfiyat2 TEXT,kod4 TEXT,kod9 TEXT);''';
  static const stokhareket =
      '''CREATE TABLE IF NOT EXISTS  stokhareket (shid INTEGER PRIMARY key AUTOINCREMENT, tarih TEXT, stokkod TEXT,stokad TEXT,cariunvan TEXT,carikod TEXT,sipno TEXT,miktar TEXT,fiyat TEXT,sfiyat1 TEXT,sfiyat2 TEXT,kod4 TEXT,kuladi TEXT,aciklama TEXT);''';
  static const carihareket =
      '''CREATE TABLE IF NOT EXISTS  carihareket (chid INTEGER PRIMARY key AUTOINCREMENT,tahsno TEXT, tarih TEXT, carikod TEXT,borc TEXT,alacak TEXT,islemtip TEXT,kuladi TEXT,aciklama TEXT,kayno TEXT);''';
  Future<Database> initializeDatabase() async {
    print("Tablo Kontrol");
    Directory dd =
        await getExternalStorageDirectory(); //getApplicationDocumentsDirectory();

    String path = join(dd.path, "karakayadb.db");
    print(path);
    //await deleteDatabase(path);
    // print("tablo silindi");
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(kullanici);
      print("Kullanıcı Tablo Oluşturuldu");
      await db.execute(cariler);
      print("Cari Tablo Oluşturuldu");
      await db.execute(stoklar);
      print("Stok Tablo Oluşturuldu");
      await db.execute(stokhareket);
      print("StokHareket Tablo Oluşturuldu");
      await db.execute(carihareket);
      print("CariHareket Tablo Oluşturuldu");
    });
  }

  Future<String> get _localPath async {
    final directory =
        await getExternalStorageDirectory(); //getApplicationDocumentsDirectory();
    print(directory.path);
    return directory.path;
  }

  // Future<ByteData> get _localFile async {
  //   final path = await _localPath;
  //   var dosya = File('$path/karakayadb.db');
  //   Uint8List bytes = dosya.readAsBytesSync();
  //   return ByteData.view(bytes.buffer);
  // }

  Future<String> yedekle() async {
    try {
      // var filename = _localFile;
      //var bytes = await rootBundle.load(filename.toString());
      // String dir = (await getApplicationDocumentsDirectory()).path;
      var dir =
          await getExternalStorageDirectory(); //getExternalStorageDirectory();
      String uzakdosya = join(
          dir.path, "Yedek_" + new DateTime.now().toString().substring(0, 19));
      final path = await _localPath;
      var dosya = File('$path/karakayadb.db');
      Uint8List bytes = dosya.readAsBytesSync();
      var aa = ByteData.view(bytes.buffer);
      //await sunucuyakopyala(bytes);
      var sonuc = await writeToFile(aa, '$uzakdosya');
      return "Tamam";
    } catch (err) {
      return err;
    }
  }

  Future<http.Response> sunucuyakopyala(var gelen) async {
    try {
      final sonuc = await http.get(
          'http://' + Global.sunucu + '/dosyaal?gelen=' + gelen.toString());
      //print("burada " + sonuc.body);
      return sonuc;
    } on SocketException {
      throw SocketException("Sunucuya Erisilemedi");
    } on HttpException {
      throw HttpException("Veri Gönderilemedi");
    } on FormatException {
      throw FormatException("Bozuk Veri Biçimi");
    }
    //return sonuc;
  }

  Future<int> yedeksil(String gelen) async {
    print(gelen);
    try {
      final path = await _localPath;
      final dosya = File('$path/$gelen');
      await dosya.delete();
      return 1;
    } catch (err) {
      return 0;
    }
  }

  Future<String> restore(String gelen) async {
    try {
      final path = await _localPath;
      String yenidosya = join(path, "karakayadb.db");
      print(yenidosya);
      var dosya = File('$path/$gelen');

      print(dosya);
      Uint8List bytes = dosya.readAsBytesSync();
      var aa = ByteData.view(bytes.buffer);
      var sonuc = await writeToFile(aa, '$yenidosya');
      return "Tamam";
    } catch (err) {
      print(err);
      return err.toString();
    }
  }

  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<List> cariliste() async {
    var dbClient = await this.database;
    var result = await dbClient.rawQuery('SELECT * FROM $_tablo');
    return result.toList();
  }

  Future<List> cariara(String gelen) async {
    var dbClient = await this.database;
    var result = await dbClient.rawQuery(
        "SELECT * from $_tablo where (cariunvan like '%" +
            gelen +
            "%' or carikod like '%" +
            gelen +
            "%') and bolgekodu=cast(strftime('%w', 'now') as integer) union " +
            "all select * from $_tablo where (cariunvan like '%" +
            gelen +
            "%' or carikod like '%" +
            gelen +
            "%') and bolgekodu<>cast(strftime('%w', 'now') as integer)");
    // "SELECT * FROM $_tablo where cariunvan like '%" +
    //     gelen +
    //     "%' or carikod like '%" +
    //     gelen +
    //     "%'  order by carikod");
    print(result);
    return result.toList();
  }

  Future<int> cksay() async {
    Database db = await this.database;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $_tablo'));
    return count;
  }

  Future<int> temizle() async {
    Database db = await this.database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
        "DELETE FROM $_tablo;delete from sqlite_sequence where name='$_tablo';DELETE FROM stoklar;delete from sqlite_sequence where name='stoklar';"));
    return count;
  }

  Future<int> insert(Carimodel note) async {
    Database db = await this.database;
    var result = await db.insert("$_tablo", note.toMap());
    return result;
  }

  Future<int> delete(int cid) async {
    Database db = await this.database;
    var result = await db.rawDelete("delete from $_tablo where sid=$cid");
    return result;
  }

  Future<int> update(Carimodel note) async {
    Database db = await this.database;
    var result = await db
        .update("$_tablo", note.toMap(), where: "cid=?", whereArgs: [note.cid]);
    return result;
  }

  //String url = 'https://jsonplaceholder.typicode.com/posts';
  Future<http.Response> carilerr() async {
    try {
      Database db = await this.database;
      final sonuc = await http.get(
          'http://' + Global.sunucu + '/cariliste?grupkodu=' + Global.rutkodu);

      return sonuc;
    } on SocketException {
      throw SocketException("Sunucuya Erisilemedi");
    } on HttpException {
      throw HttpException("Veri Gönderilemedi");
    } on FormatException {
      throw FormatException("Bozuk Veri Biçimi");
    }
    //return sonuc;
  }

  Future<http.Response> carilerliste() {
    return http.get('http://' + Global.sunucu + '/home/Carilistegetir');
  }
}
