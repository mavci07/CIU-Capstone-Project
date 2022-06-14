import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karakaya_soguk/db/dbcariler.dart';
import 'package:karakaya_soguk/db/dbcarihareket.dart';
import 'package:karakaya_soguk/model/chmodel.dart';
import 'package:karakaya_soguk/model/carimodel.dart';
import 'package:karakaya_soguk/static/global.dart';
import 'dart:core';

import 'anasayfa.dart';

class Tahsilatduzenle5 extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<Tahsilatduzenle5> {
  final _formKey = GlobalKey<FormState>();
  TextStyle headerTextStyle = TextStyle(color: Colors.white, fontSize: 20);
  var cariara = TextEditingController();
  var cmara = TextEditingController();
  var tutar = TextEditingController();
  var aaa = TextEditingController();
  var tahsilatno = TextEditingController();
  var _aciklama = TextEditingController();
  DbCariler _dbcariler = DbCariler();
  DbCarihareket _dbCarihareket = DbCarihareket();
  List<Carimodel> cariler = new List<Carimodel>();
  List<Carimodel> carig = new List<Carimodel>();
  //List<Stokhareket> allNotes = new List<Stokhareket>();
  List<CariHmodel> carih = new List<CariHmodel>();
  String _carikod = "";
  String _islem = "NAKİT";
  String _bakiye = "";
  String _borc = "";
  String _alacak = "";
  String _tahsno = Global.duzenletahsno;
  double _toplam = 0;
  bool isAscending = true;
  FocusNode myFocusNode;
  FocusNode tahsfocus;
  FocusNode carifocus;
  int yuklendi = 0;
  //var _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    cariara.addListener(_printLatestValue);
    myFocusNode = FocusNode();
    tahsfocus = FocusNode();
    listeal().whenComplete(() => yuklendi = 1);
  }

  Future<void> listeal() async {
    final list = await _dbCarihareket.tahsnogetir(_tahsno);
    if (list.isNotEmpty) {
      setState(() {
        list.forEach((note) {
          carih.add(CariHmodel.fromJson(note));
        });
        hesapla();
        _carikod = carih[0].carikod;
        tahsilatno.text = carih[0].tahsno;
        _aciklama.text = carih[0].aciklama;
        // tutaral();
        // _toplam = (gecici.length.isNaN ? 0 : gecici.length);
      });
    }
    carigetir(_carikod).then((gg) {
      if (gg.isNotEmpty) {
        setState(() {
          cariara.text = gg[0].cariunvan.toString();
          _bakiye = gg[0].bakiye.toString();
        });
        print("unvan" + gg[0].cariunvan.toString());
        // carifocus.requestFocus();
      }
    });
  }

  _printLatestValue() {
    print("text field: ${cariara.text}");
  }

  void tahsnoal() async {
    DbCarihareket _db = DbCarihareket();
    int gelen = await _db.sipnoal();
    setState(() {
      _tahsno = Global.tahsno + (gelen + 1).toString().padLeft(6, '0');
    });
  }

  void hesapla() {
    double t = 0;
    for (int i = 0; i < carih.length; i++) {
      t = t + double.parse(carih[i].borc);
    }
    _toplam = t;
  }

  void carikodguncelle() {
    //print(sabitler[0].carikod);
    carih.forEach((element) {
      setState(() {
        element.carikod = _carikod;
        element.tahsno = tahsilatno.text;
        element.aciklama = _aciklama.text;
        element.kuladi = Global.kuladi;
      });
    });
    //print(gecici);
  }

  void listeyeekle(String islem) {
    print(islem);
    final index =
        carih.indexWhere((element) => element.islemtip.toString() == "NAKİT");
    if (index >= 0) {
      if (islem == "NAKİT")
        setState(() {
          carih[index].borc =
              (double.parse(carih[index].borc) + double.parse(tutar.text))
                  .toString();
          hesapla();
          //_toplam = double.parse(carih.length);
        });
      else {
        setState(() {
          carih.add(CariHmodel.withJ(
              carikod: _carikod,
              borc: tutar.text,
              islemtip: _islem,
              tarih: DateTime.now().toString(),
              tahsno: tahsilatno.text,
              aciklama: _aciklama.text));
          print(_tahsno);
          tutar.text = "";
          hesapla();
          // _toplam = carih.length;
        });
        _islem = "NAKİT";
      }

      tutar.text = "";
    } else {
      setState(() {
        carih.add(CariHmodel.withJ(
            carikod: _carikod,
            borc: tutar.text,
            islemtip: _islem,
            tarih: DateTime.now().toString(),
            tahsno: tahsilatno.text,
            aciklama: _aciklama.text));
        print(_tahsno);
        tutar.text = "";
        hesapla();
        //_toplam = carih.length;
      });
      _islem = "NAKİT";
    }
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
                  Navigator.pushNamed(context, "/tahsilatlar");
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
    if (yuklendi == 0) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Bekleyiniz..."),
        ),
      );
    } else {
      return new WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green[600],
              centerTitle: true,
              title: Text("Tahsilat Düzenle"),
            ),
            drawer: MyDrawer(),
            body: Container(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //SizedBox(height: 50),
                    TextField(
                      style: TextStyle(fontSize: 15),
                      readOnly: true,
                      controller: cariara,
                      maxLines: 2,
                      //focusNode: stokfocus,
                      onSubmitted: (value) {
                        carigetir(value).then((gg) {
                          if (gg.isNotEmpty) {
                            cariara.text = gg[0].cariunvan.toString();
                            _carikod = gg[0].carikod.toString();
                            _bakiye = gg[0].bakiye.toString();
                            carifocus.requestFocus();
                          } else {
                            _carikod = "";
                            cariara.text = "";
                            showDialog<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Cari Bulunamadı!'),
                                  content: Text('Girilen "$value".'),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Tamam'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20.0, 0, 0, 0),
                        hintText: "Cari Kodu veya Ünvan Giriniz",
                        labelText: 'Cari Kod-Ünvan',
                        suffixIcon: IconButton(
                          onPressed: () => _carimodal(),
                          icon: Icon(
                            Icons.search,
                            size: 30,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      style: TextStyle(fontSize: 15),
                      controller: tahsilatno,
                      focusNode: tahsfocus,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20.0, 0, 0, 0),
                        hintText: "Tahsilat No Giriniz",
                        labelText: 'Tahsilat No',
                        // suffixIcon: IconButton(
                        //   onPressed: () => _carimodal(),
                        //   icon: Icon(
                        //     Icons.search,
                        //     size: 35,
                        //     color: Colors.grey[400],
                        //   ),
                        // ),
                      ),
                    ),
                    DropdownButtonFormField(
                        dropdownColor: Colors.amber[100],
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20.0, 5, 0, 0),
                          //filled: true,
                          // fillColor: Hexcolor('#ecedec'),
                          labelText: 'İŞLEM TİPİ',
                          labelStyle: TextStyle(color: Colors.red),
                          // fillColor: Colors.red[50]
                          // border: new CustomBorderTextFieldSkin().getSkin(),
                        ),
                        isExpanded: true,
                        value: _islem,
                        items: [
                          DropdownMenuItem(
                            child: Text("NAKİT"),
                            value: "NAKİT",
                          ),
                          DropdownMenuItem(
                            child: Text("KREDİ"),
                            value: "KREDİ",
                          )
                        ],
                        onChanged: (value) {
                          setState(() {
                            _islem = value;
                          });
                        }),

                    TextField(
                      controller: tutar,
                      focusNode: myFocusNode,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20.0, 5, 0, 0),
                        hintText: "Tutar Giriniz",
                        labelText: 'Tutar',
                        labelStyle: TextStyle(color: Colors.red),
                        suffixIcon: IconButton(
                          onPressed: () => {
                            if (tutar.text != "")
                              {
                                listeyeekle(_islem),
                              }
                            else
                              {
                                showDialog<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Hata !'),
                                      content: Text('Tutar Girilmedi...'),
                                      actions: <Widget>[
                                        FlatButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Tamam'),
                                        ),
                                      ],
                                    );
                                  },
                                )
                              }
                          },
                          icon: Icon(
                            Icons.add_circle,
                            size: 35,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      // inputFormatters: <TextInputFormatter>[
                      //   FilteringTextInputFormatter.digitsOnly
                      // ],
                    ),
                    Container(
                      height: 27,
                      color: Colors.green[700],
                      child: Row(
                        children: <Widget>[
                          Container(
                              margin: EdgeInsets.fromLTRB(10, 4, 0, 4),
                              width: 200,
                              child: Text(
                                'İŞLEM TİPİ',
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              )),
                          Container(
                            margin: EdgeInsets.fromLTRB(20, 4, 0, 4),
                            width: 100,
                            child: Text(
                              'TUTAR',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: carih.length,
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
                          itemBuilder: (context, position) {
                            return Container(
                              child: Column(
                                children: <Widget>[
                                  Column(children: [
                                    //Text("adsfasf"),
                                    GestureDetector(
                                        onTap: () => {
                                              // print('${carih[position].stokkod}'),
                                              _carikod =
                                                  '${carih[position].carikod}',
                                              _islem =
                                                  '${carih[position].islemtip}',
                                              tutar.text =
                                                  '${carih[position].borc}',
                                              setState(() {
                                                carih.remove(carih[position]);
                                                hesapla();
                                              }),
                                            },
                                        onLongPress: () => {
                                              showDialog<void>(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Kayıt Sil !'),
                                                    content: Text(
                                                        'Seçilen Satır Silinsin mi?'),
                                                    actions: <Widget>[
                                                      FlatButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child:
                                                            const Text('İptal'),
                                                      ),
                                                      FlatButton(
                                                          onPressed: () => {
                                                                setState(() {
                                                                  carih.remove(
                                                                      carih[
                                                                          position]);
                                                                  hesapla();
                                                                }),
                                                                Navigator.pop(
                                                                    context)
                                                              },
                                                          child: Text("Sil"))
                                                    ],
                                                  );
                                                },
                                              )
                                            },
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: Colors.white70,
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(0),
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                  margin: EdgeInsets.all(10),
                                                  width: 200,
                                                  child: Text(
                                                    '${carih[position].islemtip}',
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  )),
                                              Container(
                                                margin: EdgeInsets.all(10),
                                                width: 100,
                                                child: Text(
                                                    '${carih[position].borc}',
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        fontSize: 15)),
                                              ),
                                            ],
                                          ),
                                        ))
                                  ]),
                                ],
                              ),
                            );
                          }),
                    ),
                    TextField(
                      style: TextStyle(fontSize: 12),
                      controller: _aciklama,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Açıklama',
                        isDense: true, // Added this
                        contentPadding: EdgeInsets.all(8), // Added this
                      ),
                    ),
                    Container(
                      height: 22,
                      child: AppBar(
                        title: Text("Toplam: " + _toplam.toString(),
                            style: TextStyle(fontSize: 15)),
                        automaticallyImplyLeading: false,
                      ),
                    ),
                    Container(
                      height: 22,
                      child: AppBar(
                        title: Text(
                            "B.: " +
                                _borc +
                                ' A.: ' +
                                _alacak +
                                ' Bakiye: ' +
                                _bakiye,
                            style: TextStyle(fontSize: 15)),
                        automaticallyImplyLeading: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: Container(
              height: 50.0,
              width: 50.0,
              child: FittedBox(
                child: FloatingActionButton(
                    elevation: 10,
                    child: new Icon(Icons.save, size: 35),
                    backgroundColor: Colors.orange[900],
                    onPressed: () {
                      _kaydet();
                    }),
              ),
            ),
          ));
    }
  }

  // Future<List> carigetir() async {
  //   await Future.delayed(Duration(milliseconds: 500));
  //   List _list = new List();
  //   var gelen = await _dbcariler.cariara(cariara.text);
  //   List _jsonList = gelen;
  //   if (gelen.isNotEmpty) {
  //     for (int i = 0; i < _jsonList.length;) {
  //       _list.add(new Carimodel.fromJsonlabel(_jsonList[i]));
  //       i++;
  //     }
  //     return _list;
  //   } else
  //     return _list;
  // }

  void _kaydet() async {
    if (_carikod != "" && carih.length > 0 && tahsilatno.text.isNotEmpty) {
      // var sdata = json.decode(gecici.toList());
      //var listeal = gecici as List;
      int sipnokontrol = await _dbCarihareket.tahsnokontrol(_tahsno);
      if (sipnokontrol > 0) {
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.green[900],
              title: const Text('Kayıt Mevcut !',
                  style: TextStyle(color: Colors.white)),
              content: Text('Kayıt Mevcut. Güncellensin mi?',
                  style: TextStyle(color: Colors.white)),
              actions: <Widget>[
                FlatButton(
                  onPressed: () async {
                    carikodguncelle();
                    // await _dbCarihareket.delete(tahsilatno.whenComplete(() async {
                    //   for (var activity in carih) {
                    //     CariHmodel actData =
                    //         CariHmodel.fromMap(activity.toMap());
                    //     //print(actData);
                    //     // stokcontroller.text = actData.toString();
                    //     await _dbCarihareket.insert(actData);
                    //   }
                    // });
                    Navigator.pushNamed(context, "/tahsilatlar");
                  },
                  child: const Text('Güncelle',
                      style: TextStyle(color: Colors.white)),
                ),
                FlatButton(
                    onPressed: () => {Navigator.pop(context)},
                    child: Text("İptal", style: TextStyle(color: Colors.white)))
              ],
            );
          },
        );
      } else {
        carikodguncelle();
        for (var activity in carih) {
          CariHmodel actData = CariHmodel.fromMap(activity.toMap());
          //print(actData);
          // stokcontroller.text = actData.toString();
          var gelen = await _dbCarihareket.insert(actData);
          if (gelen > 0) {
            showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('KAYIT',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.green[800],
                  content: Text('TAHSİLAT KAYDEDİLDİ!',
                      style: TextStyle(color: Colors.white)),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/tahsilatlar");
                      },
                      child: const Text('Tamam',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              },
            );
          } else {
            showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Hata !',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red[900],
                  content: Text('TAHSİLAT KAYDEDİLEMEDİ',
                      style: TextStyle(color: Colors.white)),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Tamam',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              },
            );
          }
        }
      }
    } else {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Hata !'),
            content: Text('Cari Kart Seçilmedi veya Tahsilat Eklenmedi'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Tamam'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<List<Carimodel>> carigetir(filter) async {
    var models;
    var gelen = await _dbcariler.cariara(filter);
    models = Carimodel.fromJsonList(gelen);
    return models;
  }

  Future<List<Carimodel>> carilist(String aranacak) async {
    DbCariler db = new DbCariler();
    //stokg = new List<Stokmodel>();
    var gelen = await db.cariara(aranacak);
    setState(() {
      carig = Carimodel.fromJsonList(gelen);
    });
    return carig;
  }

  _carimodal() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, state) {
            return Column(children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 50)),
              TextField(
                autofocus: true,
                controller: cmara,
                decoration: InputDecoration(
                    hintText: 'Cari Kod veya Ünvan Giriniz',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          cmara.clear();
                        });
                      },
                      icon: Icon(
                        Icons.clear,
                        size: 35,
                        color: Colors.grey[400],
                      ),
                    )),
                onChanged: (text) async {
                  await carilist(cmara.text);
                  await cmguncelle(state);
                },
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: cariler.length,
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
                                '${cariler[position].cariunvan}',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Global.mavi,
                                ),
                              ),
                              subtitle: Text(
                                'Bakiye: ${cariler[position].bakiye}',
                                style: new TextStyle(
                                  fontSize: 15.0,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              leading: Column(
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.all(8.0)),
                                  Text(
                                    '${cariler[position].carikod}',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // print(items[position].stokkod.toString());
                                setState(() {
                                  _carikod =
                                      cariler[position].carikod.toString();
                                  cariara.text =
                                      cariler[position].cariunvan.toString();
                                  _bakiye = cariler[position].bakiye.toString();
                                  _borc = cariler[position].borc.toString();
                                  _alacak = cariler[position].alacak.toString();
                                });

                                Navigator.pop(context);
                                //tahsfocus.requestFocus();
                              },
                            ),
                          ],
                        ),
                      );
                    }),
              ),
            ]);
          });
        });
  }

  Future<Null> cmguncelle(StateSetter updateState) async {
    updateState(() {
      cariler = carig;
    });
  }
  // Future<List<Stokhareket>> getData(filter) async {
  //   var models;
  //   var gelen = await _dbsiparis.siparisara(filter);
  //   print(gelen);
  //   models = Stokhareket.fromJsonList(gelen);
  //   print(models);

  //   return models;
  // }
}
