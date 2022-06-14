import 'package:karakaya_soguk/model/shmodel.dart';
import 'package:karakaya_soguk/static/global.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'package:uuid/uuid.dart';

class DbStokhareket {
  static Database _database;

  String _tablo = "stokhareket";

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initializeDatabase();
    return _database;
  }

  static const stoklar =
      '''CREATE TABLE IF NOT EXISTS stokhareket (shid INTEGER PRIMARY key AUTOINCREMENT, tarih TEXT, stokkod TEXT,stokad TEXT,cariunvan TEXT,carikod TEXT,sipno TEXT,miktar TEXT,fiyat TEXT,sfiyat1 TEXT,sfiyat2 TEXT,kod4 TEXT,kuladi TEXT,aciklama TEXT);''';
  Future<Database> initializeDatabase() async {
    print("StokHareket Tablo Kontrol");
    Directory dd =
        await getExternalStorageDirectory(); //getApplicationDocumentsDirectory();
    print(dd.path);
    String path = join(dd.path, "karakayadb.db");
    //await deleteDatabase(path);
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(stoklar);
      print("StokHareket Tablo yok oluşturuluyor...");
    });
  }

  Future<List> stokhareketliste() async {
    var dbClient = await this.database;
    var result = await dbClient.rawQuery('SELECT * FROM $_tablo');
    return result.toList();
  }

  Future<List> stokhareketsay() async {
    var dbClient = await this.database;
    var result = await dbClient
        .rawQuery('SELECT count(sipno) FROM $_tablo group by sipno');
    return result.toList();
  }

  Future<List> sipnogetir(String sipnogelen) async {
    var dbClient = await this.database;
    var result = await dbClient
        .rawQuery('SELECT * FROM $_tablo s where sipno=\'' + sipnogelen + '\'');
    return result.toList();
  }

  Future<List> shlistecari(String kuladi) async {
    var dbClient = await this.database;
    var result = await dbClient.rawQuery(
        'SELECT tarih,stokkod,(select c.carikod || \' \' || c.cariunvan from cariler as c where c.carikod=s.carikod ) as carikod,sipno,miktar FROM $_tablo as s where kuladi=\'' +
            kuladi +
            '\'group by sipno order by tarih desc');
    return result.toList();
  }

  Future<List> siparisgetir(String gelen) async {
    var dbClient = await this.database;
    var result = await dbClient.rawQuery(
        "SELECT * FROM $_tablo where stokkod like '%" +
            gelen +
            "%' or stokad like '%" +
            gelen +
            "%'");
    return result.toList();
  }

  Future<int> sksay() async {
    Database db = await this.database;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $_tablo'));
    return count;
  }

  Future<int> sipnokontrol(String sipno) async {
    Database db = await this.database;
    final count = Sqflite.firstIntValue(await db
        .rawQuery("SELECT COUNT(*) FROM $_tablo where sipno='" + sipno + "'"));
    return count;
  }

  Future<String> sipnoal(String kuladi) async {
    var uuid = Uuid();
    var sipno = uuid.v4();
    return sipno;
  }

  Future<int> temizle() async {
    Database db = await this.database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
        "DELETE FROM $_tablo;delete from sqlite_sequence where name='$_tablo';"));
    return count;
  }

  Future<int> insert(StokHmodel note) async {
    Database db = await this.database;
    var result = await db.insert("$_tablo", note.toMap());
    return result;
  }

  Future<int> delete(StokHmodel note) async {
    Database db = await this.database;
    var result = await db.delete("$_tablo",
        where: "sipno=? and stokkod=?", whereArgs: [note.sipno, note.stokkod]);
    return result;
  }

  Future<int> update(StokHmodel note) async {
    Database db = await this.database;
    var result = await db.update("$_tablo", note.toMap(),
        where: "shid=? ", whereArgs: [note.shid]);
    return result;
  }

  Future<int> siparissil(String sipno) async {
    Database db = await this.database;
    var result =
        await db.delete("$_tablo", where: "sipno=?", whereArgs: [sipno]);
    return result;
  }

  Future<int> cariguncelle(
      String sipno, String carikod, String cariunvan, String aciklama) async {
    Database db = await this.database;
    var result = await db.rawUpdate(
        "update $_tablo set carikod='$carikod',cariunvan='$cariunvan',aciklama='$aciklama' where sipno='$sipno'");
    return result;
  }

  Future<http.Response> stokgetir() {
    return http.get('http://' + Global.sunucu + '/home/Stoklistegetir');
  }

  Future<http.Response> stokgonder(gelen) async {
    var sonuc;
    try {
      var gg = await http.post('http://' + Global.sunucu + '/stokgonder',
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: gelen);
      print(gg.statusCode);
      if (gg.statusCode == 200) {
        if (gg.body.isEmpty) {
          throw SocketException("Sunucuya Erisilemedi");
        } else {
          sonuc = gg;
        }
      }
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
