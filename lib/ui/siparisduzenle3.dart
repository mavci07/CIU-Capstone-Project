import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karakaya_soguk/db/dbcariler.dart';
import 'package:karakaya_soguk/db/dbstoklar.dart';
import 'package:karakaya_soguk/db/dbstokhareket.dart';
import 'package:karakaya_soguk/model/shgecici.dart';
import 'package:karakaya_soguk/model/shmodel.dart';
import 'package:karakaya_soguk/model/carimodel.dart';
import 'package:karakaya_soguk/model/stokmodel.dart';
import 'package:karakaya_soguk/ui/anamenu.dart';
import 'package:karakaya_soguk/static/global.dart';
import 'dart:core';

import 'anasayfa.dart';

class Siparisduzenle extends StatefulWidget {
  final String siparisno;
  const Siparisduzenle(this.siparisno);

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<Siparisduzenle> {
  final _formKey = GlobalKey<FormState>();
  TextStyle headerTextStyle = TextStyle(color: Colors.white, fontSize: 20);
  var _miktar = TextEditingController();
  var cariara = TextEditingController();
  var stokara = TextEditingController();
  var stokarama = TextEditingController();
  var _aciklama = TextEditingController();
  var aaa = TextEditingController();
  var cmara = TextEditingController();
  var stara = TextEditingController();
  var _fiyat = TextEditingController();
  DbStoklar _dbstoklar = DbStoklar();
  DbCariler _dbcariler = DbCariler();
  DbStokhareket _dbStokhareket = DbStokhareket();
  List<Carimodel> cariler = new List<Carimodel>();
  //List<Stokhareket> allNotes = new List<Stokhareket>();
  List<Stokmodel> items = new List<Stokmodel>();
  List<Stokmodel> stokg = new List<Stokmodel>();
  List<Carimodel> carig = new List<Carimodel>();
  List<ShGecici> gecici = new List<ShGecici>();
  List<StokHmodel> stokh = new List<StokHmodel>();
  List<ShGecici> sabitler = new List<ShGecici>();
  String _carikod = "";
  String _stokkod = "";
  String _sfiyat1 = "";
  String _sfiyat2 = "";
  String _tarih = "";
  //String _sipno = Global.duzenlesipno;
  String _bakiye = "";
  String _kod4 = "";
  double _toplam = 0.00;
  bool isAscending = true;
  FocusNode myFocusNode;
  FocusNode carifocus;
  FocusNode stokfocus;
  int yuklendi = 0;
  //var _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void dispose() {
    stokarama.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    cariara.addListener(_printLatestValue);
    myFocusNode = FocusNode();
    stokfocus = FocusNode();
    listeal().whenComplete(() => yuklendi = 1);
  }

  Future<void> listeal() async {
    final list = await _dbStokhareket.sipnogetir(widget.siparisno);
    if (list.isNotEmpty) {
      setState(() {
        list.forEach((note) {
          gecici.add(ShGecici.fromJson(note));
          sabitler.add(ShGecici.fromJson(note));
        });
        cariara.text = sabitler[0].cariunvan;
        _carikod = sabitler[0].carikod;
        tutaral();
        _aciklama.text = sabitler[0].aciklama;
        // _toplam = (gecici.length.isNaN ? 0 : gecici.length);
      });
      // print(sabitler[1].aciklama + ' Açıklama');
    }
    carigetir(_carikod).then((gg) {
      if (gg.isNotEmpty) {
        setState(() {
          _bakiye = gg[0].bakiye.toString();
        });

        // carifocus.requestFocus();
      }
    });
  }

  _printLatestValue() {
    print("text field: ${cariara.text}");
  }

  void carikodguncelle() {
    //print(sabitler[0].carikod);
    gecici.forEach((element) {
      setState(() {
        element.carikod = _carikod;
        element.cariunvan = cariara.text;
        element.aciklama = _aciklama.text;
      });
    });
    //print(gecici);
  }

  void listedeara(String stokkodu) {
    final index =
        gecici.indexWhere((element) => element.stokkod.toString() == stokkodu);
    if (index >= 0) {
      setState(() {
        gecici[index].miktar =
            (int.parse(gecici[index].miktar) + int.parse(_miktar.text))
                .toString();
        gecici[index].fiyat = _fiyat.text;

        // _toplam = (gecici.length.isNaN ? 0 : gecici.length);
      });

      _stokkod = "";
      _miktar.text = "";
      stokara.text = "";
      _fiyat.text = "0";
      _sfiyat1 = "";
      _sfiyat2 = "";
      _kod4 = "";
      stokfocus.requestFocus();
    } else {
      setState(() {
        gecici.add(ShGecici.withJ(
            stokkod: _stokkod,
            carikod: _carikod,
            stokad: stokara.text,
            miktar: _miktar.text,
            tarih: DateTime.now().toString(),
            fiyat: _fiyat.text,
            sfiyat1: _sfiyat1,
            sfiyat2: _sfiyat2,
            kod4: _kod4,
            sipno: widget.siparisno,
            kuladi: Global.kuladi,
            aciklama: _aciklama.text));
        // print(_sipno);
        _stokkod = "";
        _miktar.text = "";
        stokara.text = "";
        _fiyat.text = "0";
        _sfiyat1 = "";
        _sfiyat2 = "";
        _kod4 = "";
        // _toplam = (gecici.length.isNaN ? 0 : gecici.length);
      });
      tutaral();
      stokfocus.requestFocus();
    }
  }

  // void sipnoal() async {
  //   DbStokhareket _db = DbStokhareket();
  //   int gelen = await _db.sipnoal(Global.kuladi);
  //   setState(() {
  //     _sipno = (gelen + 1).toString();
  //   });
  // }

  tutaral() {
    _toplam = 0;
    gecici.forEach((element) {
      setState(() {
        _toplam = _toplam +
            (double.parse(element.miktar) *
                double.parse(element.fiyat.replaceAll(",", ".")));
      });
    });
  }

  tarihduzenle(String t) {
    //String t = DateTime.now().toString();
    String yil = t.substring(0, 4);
    String ay = t.substring(5, 7);
    String gun = t.substring(8, 10);
    _tarih = gun + '/' + ay + '/' + yil;
    return _tarih;
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Warning'),
            content: new Text('Sign Out??'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('Cancel'),
              ),
              new FlatButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/siparisler");
                },
                child: new Text('Exit'),
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
          title: new Text("Loading..."),
        ),
      );
    } else {
      return new WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue[900],
              centerTitle: true,
              title: Text("Edit Order"),
            ),
            drawer: MyDrawer(),
            body: Container(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 15,
                      child: AppBar(
                        backgroundColor: Colors.blueGrey[100],
                        automaticallyImplyLeading: false,
                        actions: <Widget>[
                          Text(
                            tarihduzenle(DateTime.now().toString()),
                            style: TextStyle(
                                color: Colors.grey[800], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
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
                                  title: const Text('Current Not Found!'),
                                  content: Text('Entered "$value".'),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Okey'),
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
                        hintText: "Enter Current Code or Title",
                        labelText: 'Current Code-Title',
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
                    SizedBox(height: 5),
                    TextField(
                      //maxLines: 2,
                      style: TextStyle(fontSize: 15),
                      controller: stokara,
                      focusNode: stokfocus,
                      onSubmitted: (value) {
                        stokgetir(value).then((gg) {
                          if (gg.isNotEmpty) {
                            stokara.text = gg[0].stokad.toString();
                            _stokkod = gg[0].stokkod.toString();
                            _sfiyat1 = gg[0].sfiyat1.toString();
                            _sfiyat2 = gg[0].sfiyat2.toString();
                            _fiyat.text = gg[0].sfiyat1.toString();
                            _kod4 = gg[0].kod4.toString();
                            //myFocusNode.requestFocus();
                            // Navigator.pop(context);
                            _stokmodal();
                            // myFocusNode.requestFocus();
                          } else {
                            _stokkod = "";
                            stokara.text = "";
                            showDialog<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Product Not Found!'),
                                  content: Text('Entered "$value".'),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Oeky'),
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
                        hintText: "Enter Stock Code or Name",
                        labelText: 'Stock Code-Name',
                        suffixIcon: IconButton(
                          onPressed: () {
                            _settingModalBottomSheet();
                          },
                          icon: Icon(
                            Icons.search,
                            size: 30,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                    Container(
                        decoration: BoxDecoration(
                      color: Colors.red,
                      border: Border.all(
                        color: Colors.grey[200],
                        width: 5,
                      ),
                    )),
                    Expanded(
                      child: Ink(
                          color: Colors.grey[200],
                          child: ListView.builder(
                              itemCount: gecici.length,
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
                              itemBuilder: (context, position) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Column(
                                    children: <Widget>[
                                      //Text("adsfasf"),
                                      Container(
                                        color: Colors.blue[100],
                                        height: 30,
                                        child: ListTile(
                                          dense: true,
                                          contentPadding: EdgeInsets.only(
                                              left: 3,
                                              right: 3,
                                              top: 1,
                                              bottom: 1),
                                          onTap: () => {
                                            _stokkod =
                                                '${gecici[position].stokkod}',
                                            stokara.text =
                                                '${gecici[position].stokad}',
                                            cmara.text =
                                                '${gecici[position].miktar}',
                                            _fiyat.text =
                                                '${gecici[position].fiyat}',
                                            _sfiyat1 =
                                                '${gecici[position].sfiyat1}',
                                            _sfiyat2 =
                                                '${gecici[position].sfiyat2}',
                                            _miktar.text =
                                                '${gecici[position].miktar}',
                                            _kod4 = '${gecici[position].kod4}',
                                            setState(() {
                                              gecici.remove(gecici[position]);
                                              // _toplam = (gecici.length.isNaN
                                              //     ? 0
                                              //     : gecici.length);
                                            }),
                                            tutaral(),
                                            _stokmodal()
                                          },
                                          onLongPress: () => {
                                            showDialog<void>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Unregister !'),
                                                  content: Text(
                                                      'Delete Selected Row?'),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    FlatButton(
                                                        onPressed: () => {
                                                              setState(() {
                                                                gecici.remove(
                                                                    gecici[
                                                                        position]);
                                                                // _toplam = (gecici
                                                                //         .length
                                                                //         .isNaN
                                                                //     ? 0
                                                                //     : gecici
                                                                //         .length);
                                                                tutaral();
                                                              }),
                                                              Navigator.pop(
                                                                  context)
                                                            },
                                                        child: Text("Delte"))
                                                  ],
                                                );
                                              },
                                            )
                                          },
                                          leading: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  '${gecici[position].stokkod}',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                              ]),
                                          title: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  '${gecici[position].stokad}',
                                                  style: TextStyle(fontSize: 9),
                                                ),
                                              ]),
                                          trailing: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                    'Miktar : ${gecici[position].miktar}',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                    )),
                                              ]),
                                        ),
                                      ),

                                      SizedBox(
                                        height: 5,
                                      )
                                    ],
                                  ),
                                );
                              })),
                    ),
                    TextField(
                      style: TextStyle(fontSize: 12),
                      controller: _aciklama,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Explanation',
                        isDense: true, // Added this
                        contentPadding: EdgeInsets.all(8), // Added this
                      ),
                    ),
                    Container(
                      height: 32,
                      child: AppBar(
                        backgroundColor: Colors.blueGrey[100],
                        title: Text("Balance: " + _bakiye,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700])),
                        automaticallyImplyLeading: false,
                      ),
                    ),
                    Container(
                      height: 32,
                      child: AppBar(
                        backgroundColor: Colors.blueGrey[100],
                        title: Text("Amount : " + _toplam.toStringAsFixed(2),
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700])),
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
                    backgroundColor: Colors.red[400],
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
    if (_carikod != "" && gecici.length > 0) {
      // var sdata = json.decode(gecici.toList());
      //var listeal = gecici as List;
      int sipnokontrol = await _dbStokhareket.sipnokontrol(widget.siparisno);
      if (sipnokontrol > 0) {
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.green[900],
              title: const Text('Registration Available !',
                  style: TextStyle(color: Colors.white)),
              content: Text('Registration Available. Update?',
                  style: TextStyle(color: Colors.white)),
              actions: <Widget>[
                FlatButton(
                  onPressed: () async {
                    carikodguncelle();
                    // await _dbStokhareket
                    //     .delete()
                    //     .whenComplete(() async {
                    //   for (var activity in gecici) {
                    //     StokHmodel actData =
                    //         StokHmodel.fromMap(activity.toMap());
                    //     await _dbStokhareket.insert(actData);
                    //   }
                    // });

                    Navigator.pushNamed(context, "/siparisler");
                  },
                  child: const Text('Update',
                      style: TextStyle(color: Colors.white)),
                ),
                FlatButton(
                    onPressed: () => {Navigator.pop(context)},
                    child:
                        Text("Cancel", style: TextStyle(color: Colors.white)))
              ],
            );
          },
        );
      } else {
        carikodguncelle();
        for (var activity in gecici) {
          StokHmodel actData = StokHmodel.fromMap(activity.toMap());
          var gelen = await _dbStokhareket.insert(actData);
          if (gelen > 0) {
            showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Record',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.green[800],
                  content: Text('Order saved!',
                      style: TextStyle(color: Colors.white)),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainMenu()));
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
                  title: const Text('Error!',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red[900],
                  content: Text('Order not saved',
                      style: TextStyle(color: Colors.white)),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Okey',
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
            title: const Text('Error !'),
            content: Text('No Current Card or Product Selected'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Okey'),
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
    print(gelen);
    models = Carimodel.fromJsonList(gelen);
    return models;
  }

  Future<List<Stokmodel>> stokgetir(filter) async {
    var models;
    var gelen = await _dbstoklar.stokara(filter);
    print(gelen);
    models = Stokmodel.fromJsonList(gelen);
    return models;
  }

  Future<List<Stokmodel>> stoklar(String aranacak) async {
    DbStoklar db = new DbStoklar();
    //stokg = new List<Stokmodel>();
    var gelen = await db.stokaralike(aranacak);
    setState(() {
      stokg = Stokmodel.fromJsonList(gelen);
    });
    print(stokg);
    return stokg;
  }

  Future<List<Carimodel>> carilist(String aranacak) async {
    DbCariler db = new DbCariler();
    //stokg = new List<Stokmodel>();
    var gelen = await db.cariara(aranacak);
    setState(() {
      carig = Carimodel.fromJsonList(gelen);
    });
    print(carig);
    return carig;
  }

  _settingModalBottomSheet() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, state) {
            return Column(children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 50)),
              Text(
                "Stock Search",
                style: TextStyle(color: Colors.blue[800], fontSize: 20),
              ),
              SizedBox(height: 10),
              TextField(
                autofocus: true,
                controller: aaa,
                decoration: InputDecoration(
                  hintText: 'Enter Stock Code or Stock Name',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        aaa.clear();
                      });
                    },
                    icon: Icon(
                      Icons.clear,
                      size: 35,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                onChanged: (text) async {
                  await stoklar(aaa.text);
                  await updated(state);
                },
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: items.length,
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
                                '${items[position].stokad}',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Global.mavi,
                                ),
                              ),
                              // subtitle: Text(
                              //   '${items[position].aciklama}',
                              //   style: new TextStyle(
                              //     fontSize: 15.0,
                              //     fontStyle: FontStyle.italic,
                              //   ),
                              // ),
                              leading: Column(
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.all(8.0)),
                                  Text(
                                    '${items[position].stokkod}',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // print(items[position].stokkod.toString());
                                setState(() {
                                  _stokkod = items[position].stokkod.toString();
                                  stokara.text =
                                      items[position].stokad.toString();
                                  _fiyat.text =
                                      items[position].sfiyat1.toString();
                                  _sfiyat1 = items[position].sfiyat1.toString();
                                  _sfiyat2 = items[position].sfiyat2.toString();
                                  _kod4 = items[position].kod4.toString();
                                });
                                print(_stokkod +
                                    ' ' +
                                    _fiyat.text +
                                    ' ' +
                                    _sfiyat1 +
                                    ' ' +
                                    _sfiyat2);
                                Navigator.pop(context);
                                _stokmodal();
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

  _carimodal() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, state) {
            return Column(children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 50)),
              Text(
                "Current Search",
                style: TextStyle(color: Colors.blue[800], fontSize: 20),
              ),
              SizedBox(height: 10),
              TextField(
                autofocus: true,
                controller: cmara,
                decoration: InputDecoration(
                    hintText: 'Enter Current Code or Title',
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
                                  fontSize: 12.0,
                                  color: Global.mavi,
                                ),
                              ),
                              subtitle: Text(
                                'Bakiye: ${cariler[position].bakiye}',
                                style: new TextStyle(
                                  fontSize: 12.0,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              leading: Column(
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.all(8.0)),
                                  Text(
                                    '${cariler[position].carikod}',
                                    style: TextStyle(
                                      fontSize: 12.0,
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
                                });
                                stokfocus.requestFocus();
                                Navigator.pop(context);
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

  _stokmodal() {
    // cmara.text = "";

    showModalBottomSheet(
        backgroundColor: Colors.grey[200],
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, state) {
            return Column(children: <Widget>[
              Padding(padding: EdgeInsets.fromLTRB(15, 35, 5, 0)),
              Text(
                "STOCK INFORMATION",
                style: TextStyle(color: Colors.blue[800], fontSize: 20),
              ),
              SizedBox(height: 10),
              Text(
                _stokkod,
                style: TextStyle(fontSize: 25),
              ),
              Text(
                stokara.text,
                style: TextStyle(fontSize: 15),
              ),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 10),
                      TextField(
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.orange[900],
                        ),
                        autofocus: true,
                        controller: _miktar,

                        decoration: InputDecoration(
                          fillColor: Colors.white, filled: true,
                          prefixText: "Enter Amount: ",
                          prefixStyle:
                              TextStyle(color: Colors.grey[700], fontSize: 15),
                          // prefixIcon: Icon(Icons.add),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        // hintText: 'Cari Kod veya Ünvan Giriniz'),
                        // onChanged: (text) async {
                        //   await carilist(cmara.text);
                        //   await cmguncelle(state);
                        // },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.orange[900],
                        ),
                        // autofocus: true,
                        controller: _fiyat,

                        decoration: InputDecoration(
                          fillColor: Colors.white, filled: true,
                          prefixText: "Select Price: ",
                          prefixStyle:
                              TextStyle(color: Colors.grey[700], fontSize: 15),
                          // prefixIcon: Icon(Icons.add),
                        ),

                        // hintText: 'Cari Kod veya Ünvan Giriniz'),
                        // onChanged: (text) async {
                        //   await carilist(cmara.text);
                        //   await cmguncelle(state);
                        // },
                      ),
                      Wrap(children: <Widget>[
                        Text("SatFiyat1:", style: TextStyle(fontSize: 15)),
                        SizedBox(
                          width: 30,
                        ),
                        Text("SatFiyat2:", style: TextStyle(fontSize: 15)),
                        SizedBox(
                          width: 30,
                        ),
                        Text("Parcel :", style: TextStyle(fontSize: 15)),
                      ]),
                      Wrap(
                        children: <Widget>[
                          RaisedButton(
                            color: Colors.orange[300],
                            onPressed: () {
                              setState(() {
                                _fiyat.text = _sfiyat1;
                              });
                            },
                            child:
                                Text(_sfiyat1, style: TextStyle(fontSize: 20)),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          RaisedButton(
                            color: Colors.orange[300],
                            onPressed: () {
                              setState(() {
                                _fiyat.text = _sfiyat2;
                              });
                            },
                            child:
                                Text(_sfiyat2, style: TextStyle(fontSize: 20)),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          RaisedButton(
                            color: Colors.orange[300],
                            onPressed: () {
                              setState(() {
                                _fiyat.text = _sfiyat2;
                                _miktar.text = _kod4;
                              });
                            },
                            child: Text(_kod4.isEmpty ? "No" : _kod4,
                                style: TextStyle(fontSize: 20)),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      MaterialButton(
                        height: 50,
                        onPressed: () {
                          if (_miktar.text.isNotEmpty) {
                            listedeara(_stokkod);
                            Navigator.pop(context);
                          } else {
                            showDialog<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error !'),
                                  content: Text('QUANTITY EMPTY'),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Okey'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        textColor: Colors.white,
                        color: Colors.blue[600],
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'EKLE',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                    ]),
              )
            ]);
          });
        });
  }

  Future<Null> updated(StateSetter updateState) async {
    updateState(() {
      items = stokg;
    });
  }

  Future<Null> cmguncelle(StateSetter updateState) async {
    updateState(() {
      cariler = carig;
    });
  }
}
