import 'dart:async';
import 'dart:convert';
//import 'dart:html';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:karakaya_soguk/db/dbcarihareket.dart';
import 'package:karakaya_soguk/db/dbcariler.dart';
import 'package:karakaya_soguk/db/dbislem.dart';
import 'package:karakaya_soguk/db/dbstokhareket.dart';
import 'package:karakaya_soguk/db/dbstoklar.dart';
import 'package:http/http.dart' as http;
import 'package:karakaya_soguk/db/kullanicimodel.dart';
import 'package:karakaya_soguk/model/carimodel.dart';
import 'package:karakaya_soguk/model/chmodel.dart';
import 'package:karakaya_soguk/model/shmodel.dart';
import 'package:karakaya_soguk/model/stokmodel.dart';
import 'package:karakaya_soguk/static/global.dart';
import 'package:path_provider/path_provider.dart';
import 'anasayfa.dart';

class Aktarim extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<Aktarim> {
  var caricontroller = TextEditingController();
  var stokcontroller = TextEditingController();
  var kulcontroller = TextEditingController();
  var _ydkcontroller = TextEditingController();
  String klasor;
  List<FileSystemEntity> dosyaliste = new List<FileSystemEntity>();
  DbCariler db = new DbCariler();
  double ksay = 0;
  double csay = 0;
  double ssay = 0;
  List<Map<String, dynamic>> filesList;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    super.initState();
    filesList = [];
    dosyalarial();
  }

  Future<void> dosyalarial() async {
    filesList.clear();
    klasor = (await getExternalStorageDirectory()).path;
    final dir = Directory("$klasor/");
    final files = await dir.list().toList();
    setState(() {
      files.forEach((element) {
        var dosya = File(element.path);

        // print(element.path + ' ' + (dosya.lengthSync() / 1000).toString());
        if (element.path.split('/').last.contains('Yedek'))
          filesList.add({
            'dosya': element.path.split('/').last,
            'boyut': (dosya.lengthSync() / 1000).toStringAsFixed(0) + ' KB'
          });
      });
      // files.forEach((element) {
      //   var dos = File(element.path);
      //   var son = dos.lastModifiedSync();
      //   var bug = DateTime.now().subtract(new Duration(days: 5));
      //   if (son.isAfter(bug)) dos.deleteSync();
      // });
      //  print(filesList);
      filesList.sort((a, b) {
        return b.toString().compareTo(a.toString());
      });
    });

    // dosyaliste = Directory("$klasor/").listSync(recursive: false).toList();
    return null;
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Uyarı'),
            content: new Text('Çıkış Yapılsın mı?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('İptal'),
              ),
              new FlatButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/siparisler");
                },
                child: new Text('Çık'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: _onWillPop,
        child: new Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue[900],
            centerTitle: true,
            title: Text("Aktarım"),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                onPressed: () async {
                  try {
                    String sonuc = await db.yedekle();
                    if (sonuc.isNotEmpty) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(sonuc.toString()),
                            );
                          });
                    }
                  } catch (err) {}
                  // Navigator.pushNamed(context, "/yenitahsilat");
                },
              )
            ],
          ),
          drawer: MyDrawer(),
          //hit Ctrl+space in intellij to know what are the options you can use in flutter widgets
          body: new Container(
            color: Colors.grey[300],
            padding: new EdgeInsets.all(20.0),
            child: new Center(
              child: new Column(
                children: <Widget>[
                  new Card(
                    child: InkWell(
                      splashColor: Colors.blue,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => new AlertDialog(
                            backgroundColor: Colors.red[200],
                            title: new Text('Uyarı'),
                            content: new Text(
                                'Mevcut Kayıtlar Silinecek. İşlem Yapılsın mı?'),
                            actions: <Widget>[
                              new FlatButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: new Text('İptal',
                                    style: TextStyle(
                                        color: Colors.green[900],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                              ),
                              new FlatButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    ksay = 0;
                                    ssay = 0;
                                    csay = 0;
                                    kulcontroller.text = "";
                                    caricontroller.text = "";
                                    stokcontroller.text = "";
                                  });
                                  String sonuc = await db.yedekle();
                                  gonder().then((value) {
                                    if (value != "hata")
                                      kullanici()
                                          .then((value) => cari())
                                          .then((value) => stok());
                                  });
                                },
                                child: new Text(
                                  'Aktar',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: new Container(
                        width: 200,
                        color: Colors.red[800],
                        padding: new EdgeInsets.all(15),
                        child: new Column(
                          children: <Widget>[
                            new Text(
                              'AKTARIMI BAŞLAT',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  new Card(
                    child: InkWell(
                      splashColor: Colors.blue,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => new AlertDialog(
                            backgroundColor: Colors.red[200],
                            title: new Text('Uyarı'),
                            content: new Text(
                                'Mevcut Kayıtlar Silinecek. İşlem Yapılsın mı?'),
                            actions: <Widget>[
                              new FlatButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: new Text('İptal',
                                    style: TextStyle(
                                        color: Colors.green[900],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                              ),
                              new FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    ksay = 0;
                                    ssay = 0;
                                    csay = 0;
                                    kulcontroller.text = "";
                                    caricontroller.text = "";
                                    stokcontroller.text = "";
                                  });
                                  kullanici()
                                      .then((_) => cari())
                                      .then((_) => stok());
                                },
                                child: new Text(
                                  'Aktar',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        );

                        //cari();
                        //stok();
                        // yuzde();
                      },
                      child: new Container(
                        width: 200,
                        color: Colors.blue[600],
                        padding: new EdgeInsets.all(15),
                        child: new Column(
                          children: <Widget>[
                            new Text(
                              'Cari ve Stok Kartları Al',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  new Card(
                    child: InkWell(
                      splashColor: Colors.blue.withAlpha(30),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => new AlertDialog(
                            backgroundColor: Colors.red[200],
                            title: new Text('Uyarı'),
                            content: new Text(
                                'Mevcut Kayıtlar Silinecek. İşlem Yapılsın mı?'),
                            actions: <Widget>[
                              new FlatButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: new Text('İptal',
                                    style: TextStyle(
                                        color: Colors.green[900],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                              ),
                              new FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  gonder();
                                },
                                child: new Text(
                                  'Aktar',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: new Container(
                        color: Colors.blue[600],
                        width: 200,
                        padding: new EdgeInsets.all(15),
                        child: new Column(
                          children: <Widget>[
                            new Text('Sipariş ve Tahsilat Gönder',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  new Card(
                      child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      cariliste();
                    },
                    child: new Container(
                      color: Colors.blue[600],
                      width: 200,
                      padding: new EdgeInsets.all(15),
                      child: new Column(
                        children: <Widget>[
                          new Text('Toplam Kayıt Sayısı',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  )),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                      readOnly: true,
                      controller: kulcontroller,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                      )),
                  LinearProgressIndicator(
                    value: ksay,
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                    backgroundColor: Colors.blue[50],
                    minHeight: 20,
                  ),
                  TextField(
                      readOnly: true,
                      controller: caricontroller,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                      )),
                  LinearProgressIndicator(
                    value: csay,
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                    backgroundColor: Colors.blue[50],
                    minHeight: 20,
                  ),
                  TextField(
                      readOnly: true,
                      controller: stokcontroller,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                      )),
                  LinearProgressIndicator(
                    value: ssay,
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                    backgroundColor: Colors.blue[50],
                    minHeight: 20,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: Card(
                          child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      _yedekislemleri();
                    },
                    child: new Container(
                      color: Colors.red[900],
                      width: 150,
                      padding: new EdgeInsets.all(12),
                      child: new Column(
                        children: <Widget>[
                          new Text('Yedek İşlemleri',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ))),
                ],
              ),
            ),
          ),
        ));
  }

  void cksayisi() async {
    DbCariler _dbcariler = DbCariler();
    int gelen = await _dbcariler.cksay();
  }

  Future<http.Response> stok() async {
    stokcontroller.text = "";
    DbStoklar _dbstoklar = DbStoklar();
    try {
      var sgelen = await _dbstoklar.stokgetir();
      var sdata = json.decode(sgelen.body);
      var listeal = sdata as List;
      if (listeal.length > 0) {
        _dbstoklar.temizle();
      }
      num boy = 1 / listeal.length;
      for (var activity in listeal) {
        Stokmodel actData = Stokmodel.fromMap(activity);
        stokcontroller.text = actData.toString();
        await _dbstoklar.insert(actData);
        setState(() {
          ssay = ssay + boy;
        });
      }
      stokcontroller.text = "Stok AKTARIM TAMAM - " + listeal.length.toString();
      return null;
    } catch (err) {
      stokcontroller.text = err.toString();
      return null;
    }
  }

  Future<http.Response> kullanici() async {
    try {
      kulcontroller.text = "";
      DBKullanici _dbkullanici = DBKullanici();
      var kul = await _dbkullanici.kulcek();
      var kuljson = json.decode(kul.body);
      var kulliste = kuljson as List;
      num boy = 1 / kulliste.length;
      if (kulliste.length > 0) {
        await _dbkullanici.temizle();
      }
      for (var k in kulliste) {
        Kullanicilar kulyaz = Kullanicilar.fromMap(k);
        kulcontroller.text = kulyaz.toString();
        await _dbkullanici.insert(kulyaz);
        setState(() {
          ksay = ksay + boy;
        });
      }
      kulcontroller.text =
          "KULLANICI AKTARIM TAMAM - " + kulliste.length.toString();
    } catch (err) {
      kulcontroller.text = err.toString();
    }
    return null;
  }

  Future<http.Response> cari() async {
    caricontroller.text = "";

    DbCariler _dbcariler = DbCariler();
    try {
      var gelen = await _dbcariler.carilerr();
      var data = json.decode(gelen.body);
      var activities = data as List;
      if (activities.length > 0) {
        _dbcariler.temizle();
      }
      num boy = 1 / activities.length;
      for (var activity in activities) {
        Carimodel actData = Carimodel.fromMap(activity);
        caricontroller.text = actData.toString();
        await _dbcariler.insert(actData);
        setState(() {
          csay = csay + boy;
        });
      }
      caricontroller.text =
          "CARİ AKTARIM TAMAM - " + activities.length.toString();
      return null;
    } catch (err) {
      caricontroller.text = err.toString();
      return null;
    }
  }

  Future<String> gonder() async {
    setState(() {
      caricontroller.text = "";
      stokcontroller.text = "";
    });
    DbStokhareket db = DbStokhareket();
    DbCarihareket dbc = DbCarihareket();
    var gelen = await db.stokhareketliste();
    print("Hareketler Al:" + gelen.length.toString());
    if (gelen.isNotEmpty) {
      try {
        var dd = await db.stokgonder(json.encode(gelen));
        // print("servisten gelen:" + dd.statusCode.toString());
        if (dd != null) {
          var sdata = StokHmodel.fromJsonList(gelen);
          if (sdata.length > 0) {
            for (int i = 0; i < sdata.length; i++) {
              db.siparissil(sdata[i].sipno);
            }
            stokcontroller.text = "Siparişler Aktarıldı";
          } else {
            stokcontroller.text = "Hata: Siparişler Aktarılamadı";
          }
        } else {
          setState(() {
            stokcontroller.text = 'Bağlantı Yapılamadı';
          });
        }
      } catch (e) {
        setState(() {
          stokcontroller.text = e.toString();
        });
        return "hata";
      }
    } else {
      setState(() {
        stokcontroller.text = "Sipariş Hareket Bulunamadı";
      });
    }
    var gelenc = await dbc.carihareketliste();
    if (gelenc.isNotEmpty) {
      try {
        var cc = await dbc.carigonder(json.encode(gelenc));
        if (cc != null) {
          var cdata = CariHmodel.fromJsonList(gelenc);
          if (cdata.length > 0) {
            for (int i = 0; i < cdata.length; i++) {
              print(cdata[i].kayno);
              dbc.tahsilatsil(cdata[i].kayno);
            }
            caricontroller.text = "Tahsilatlar Aktarıldı";
          } else {
            caricontroller.text = "Hata: Tahsilatlar Aktarılamadı";
          }
        } else {
          setState(() {
            caricontroller.text = 'Bağlantı Yapılamadı';
          });
        }
      } catch (e) {
        setState(() {
          caricontroller.text = e.toString();
        });
        return "hata";
      }
    } else {
      setState(() {
        caricontroller.text = "Tahsilat Hareket Bulunamadı";
      });
    }

    return null;
  }

  Future<List> cariliste() async {
    setState(() {
      caricontroller.text = "";
      stokcontroller.text = "";
      kulcontroller.text = "";
    });
    DbCariler _dbc = DbCariler();
    DbStoklar _dbs = DbStoklar();
    DBKullanici _dbk = DBKullanici();
    DbCarihareket _dbch = DbCarihareket();
    DbStokhareket _dbsh = DbStokhareket();
    var kul = await _dbk.kulliste();
    var carikart = await _dbc.cariliste();
    var stokkart = await _dbs.stokliste();
    var carhar = await _dbch.carihareketsay();
    var stkhar = await _dbsh.stokhareketsay();
    setState(() {
      caricontroller.text = "CariKart: " +
          carikart.length.toString() +
          " Tahs.Hareket: " +
          carhar.length.toString();
      stokcontroller.text = "StokKart: " +
          stokkart.length.toString() +
          " Sipr.Hareket: " +
          stkhar.length.toString();
      kulcontroller.text = "Kullanıcılar: " + kul.length.toString();
    });
    return null;
  }

  _yedekislemleri() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Container(
              height: MediaQuery.of(context).size.height * 0.95,
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(25.0),
                  topRight: const Radius.circular(25.0),
                ),
              ),
              child: StatefulBuilder(builder: (context, state) {
                return Column(children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text("'   '"),
                        Text(
                          "YEDEKLER",
                          style:
                              TextStyle(color: Colors.blue[800], fontSize: 20),
                        ),
                        IconButton(
                            iconSize: 30,
                            icon: Icon(Icons.close),
                            color: Colors.black54,
                            onPressed: () => Navigator.pop(context)),
                      ]),
                  Expanded(
                      child: RefreshIndicator(
                    strokeWidth: 3,
                    backgroundColor: Colors.blue[900],
                    color: Colors.white,
                    key: _refreshIndicatorKey,
                    onRefresh: () async {
                      await dosyalarial();
                      await listeguncelle(state);
                    },
                    child: NotificationListener<ScrollStartNotification>(
                      child: ListView.builder(
                          itemCount: filesList.length,
                          padding: EdgeInsets.symmetric(vertical: .5),
                          itemBuilder: (context, position) {
                            return Container(
                              child: Column(
                                children: <Widget>[
                                  Divider(
                                    height: 1,
                                  ),
                                  ListTile(
                                    title: Text(
                                      'YEDEK - ${DateTime.parse(filesList[position]['dosya'].substring(6)).day.toString().padLeft(2, '0')}/${DateTime.parse(filesList[position]['dosya'].substring(6)).month.toString().padLeft(2, '0')}/${DateTime.parse(filesList[position]['dosya'].substring(6)).year} ${DateTime.parse(filesList[position]['dosya'].substring(6)).hour.toString().padLeft(2, '0')}:${DateTime.parse(filesList[position]['dosya'].substring(6)).minute.toString().padLeft(2, '0')}:${DateTime.parse(filesList[position]['dosya'].substring(6)).second.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        color: Colors.red,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "Boyut : " + filesList[position]['boyut'],
                                      style: new TextStyle(
                                        fontSize: 15.0,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    // leading: Column(
                                    //   children: <Widget>[
                                    //     Padding(padding: EdgeInsets.all(8.0)),
                                    //     Text(
                                    //       '${DateTime.parse(filesList[position].substring(6)).day}/${DateTime.parse(filesList[position].substring(6)).month}/${DateTime.parse(filesList[position].substring(6)).year} ${DateTime.parse(filesList[position].substring(6)).hour}:${DateTime.parse(filesList[position].substring(6)).minute}:${DateTime.parse(filesList[position].substring(6)).second}',
                                    //       style: TextStyle(
                                    //         fontSize: 15.0,
                                    //         color: Colors.black,
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => new AlertDialog(
                                          backgroundColor: Colors.red[200],
                                          title: new Text('Uyarı'),
                                          content: new Text(
                                              'Mevcut Kayıtlar Silinecek. İşlem Yapılsın mı?'),
                                          actions: <Widget>[
                                            new FlatButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: new Text('İptal',
                                                  style: TextStyle(
                                                      color: Colors.green[900],
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15)),
                                            ),
                                            new FlatButton(
                                              onPressed: () {
                                                db.restore(filesList[position]
                                                    ['dosya']);
                                                Navigator.pop(context);
                                              },
                                              child: new Text(
                                                'Yedek Dön',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    onLongPress: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => new AlertDialog(
                                          backgroundColor: Colors.red[200],
                                          title: new Text('Uyarı'),
                                          content: new Text(
                                              'Mevcut Yedek Silinecek. İşlem Yapılsın mı?'),
                                          actions: <Widget>[
                                            new FlatButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: new Text('İptal',
                                                  style: TextStyle(
                                                      color: Colors.green[900],
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15)),
                                            ),
                                            new FlatButton(
                                              onPressed: () {
                                                db
                                                    .yedeksil(
                                                        filesList[position]
                                                            ['dosya'])
                                                    .then((value) {
                                                  dosyalarial();
                                                  listeguncelle(state);
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: new Text(
                                                'Yedek Sil',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                      onNotification: (aa) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),
                  ))
                ]);
              }));
        });
  }

  Future<Null> listeguncelle(StateSetter updateState) async {
    updateState(() {
      filesList = filesList;
    });
  }
}
