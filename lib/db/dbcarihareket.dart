import 'package:karakaya_soguk/model/chmodel.dart';
import 'package:karakaya_soguk/static/global.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';

class DbCarihareket {
  static Database _database;

  String _tablo = "carihareket";

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initializeDatabase();
    return _database;
  }

  static const stoklar =
      '''CREATE TABLE carihareket (chid INTEGER PRIMARY key AUTOINCREMENT,tahsno TEXT, tarih TEXT, carikod TEXT,borc TEXT,alacak TEXT,islemtip TEXT,kuladi TEXT,aciklama TEXT,kayno TEXT);''';
  Future<Database> initializeDatabase() async {
    print("CariHareket Tablo Kontrol");
    Directory dd =
        await getExternalStorageDirectory(); // getApplicationDocumentsDirectory();
    print(dd.path);
    String path = join(dd.path, "karakayadb.db");
    //await deleteDatabase(path);
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(stoklar);
      print("CariHareket Tablo yok oluşturuluyor...");
    });
  }

  //Crud Methods
  Future<List> carihareketliste() async {
    var dbClient = await this.database;
    var result = await dbClient.rawQuery('SELECT * FROM $_tablo');
    //print(result);
    return result.toList();
  }

  Future<List> carihareketsay() async {
    var dbClient = await this.database;
    var result = await dbClient
        .rawQuery('SELECT count(kayno) FROM $_tablo group by kayno');
    //print(result);
    return result.toList();
  }

  Future<List> tahsnogetir(String kayno) async {
    var dbClient = await this.database;
    var result = await dbClient.rawQuery(
        'SELECT *,(select cariunvan from cariler c where c.carikod=s.carikod ) as cariunvan FROM $_tablo s where kayno=\'' +
            kayno +
            '\'');
    //print(result);
    return result.toList();
  }

  Future<List> chlistecari(String kuladi) async {
    var dbClient = await this.database;
    var result = await dbClient.rawQuery(
        'SELECT s.tarih,(select c.carikod || \' \' || c.cariunvan from cariler as c where c.carikod=s.carikod ) as carikod,tahsno,cast((select sum(cast(replace(tt.borc,\',\',\'.\') as decimal))  from $_tablo tt where tt.kayno=s.kayno and islemtip=\'NAKİT\') as text) borc ,cast((select sum(cast(replace(t.borc,\',\',\'.\') as decimal))  from $_tablo t where t.kayno=s.kayno and islemtip=\'KREDİ\') as text) alacak,s.islemtip,s.kayno FROM $_tablo as s where s.kuladi=\'' +
            kuladi +
            '\' group by kayno order by tahsno');
    //print(result);
    return result.toList();
  }

  Future<List> siparisgetir(String gelen) async {
    // print(gelen);
    var dbClient = await this.database;
    var result = await dbClient.rawQuery(
        "SELECT * FROM $_tablo where carikod like '%" + gelen + "%' ");
    //print(result);
    return result.toList();
  }

  Future<int> sksay() async {
    Database db = await this.database;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $_tablo'));
    return count;
  }

  Future<int> tahsnokontrol(String sipno) async {
    Database db = await this.database;
    final count = Sqflite.firstIntValue(await db
        .rawQuery("SELECT COUNT(*) FROM $_tablo where tahsno='" + sipno + "'"));
    return count;
  }

  Future<int> sipnoal() async {
    Database db = await this.database;
    final sn = Sqflite.firstIntValue(await db.rawQuery(
        "select ifnull(max(cast(ifnull(ltrim(substr(tahsno,-6),'0'), \'0\') as int)),0) from $_tablo;"));
    return sn;
  }

  Future<int> temizle() async {
    Database db = await this.database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
        "DELETE FROM $_tablo;delete from sqlite_sequence where name='$_tablo';"));
    return count;
  }

  Future<int> insert(CariHmodel note) async {
    Database db = await this.database;
    var result = await db.insert("$_tablo", note.toMap());
    return result;
  }

  Future<int> delete(CariHmodel note) async {
    Database db = await this.database;
    var result = await db.delete("$_tablo",
        where: "kayno=? and chid=?", whereArgs: [note.kayno, note.chid]);
    return result;
  }

  Future<int> update(CariHmodel note) async {
    Database db = await this.database;
    var result = await db.update("$_tablo", note.toMap(),
        where: "chid=? ", whereArgs: [note.chid]);
    return result;
  }

  Future<int> tahsilatsil(String tahsno) async {
    Database db = await this.database;
    var result =
        await db.delete("$_tablo", where: "kayno=? ", whereArgs: [tahsno]);
    print(result);
    return result;
  }

  Future<int> cariguncelle(
      String tahsno, String kayno, String carikod, String aciklama) async {
    Database db = await this.database;
    var result = await db.rawUpdate(
        "update $_tablo set tahsno='$tahsno',carikod='$carikod',aciklama='$aciklama' where kayno='$kayno'");
    return result;
  }

  Future<http.Response> stokgetir() {
    return http.get('http://' + Global.sunucu + '/home/Stoklistegetir');
  }

  Future<http.Response> carigonder(gelen) async {
    var sonuc;
    try {
      var cc = await http.post('http://' + Global.sunucu + '/carigonder',
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: gelen);
      if (cc.statusCode == 200) {
        if (cc.body.isEmpty) {
          throw SocketException("Sunucuya Erişilemedi");
        } else {
          sonuc = cc;
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
