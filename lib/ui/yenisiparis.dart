import 'dart:async';
import 'dart:convert';
import 'package:highlight_text/highlight_text.dart';
//import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:karakaya_soguk/db/dbcariler.dart';
import 'package:karakaya_soguk/db/dbstoklar.dart';
import 'package:karakaya_soguk/db/dbstokhareket.dart';
//import 'package:karakaya_soguk/model/shstokh.dart';
import 'package:karakaya_soguk/model/shmodel.dart';
import 'package:karakaya_soguk/model/carimodel.dart';
import 'package:karakaya_soguk/model/stokmodel.dart';
import 'package:karakaya_soguk/static/global.dart';
import 'package:karakaya_soguk/ui/yenitahsilat.dart';
import 'dart:core';
import 'anasayfa.dart';
import 'package:text_to_speech/text_to_speech.dart';

class Yenisiparis extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<Yenisiparis> {
  TextToSpeech tts = TextToSpeech();
  final _formKey = GlobalKey<FormState>();
  TextStyle headerTextStyle = TextStyle(color: Colors.white, fontSize: 20);
  var _miktar = TextEditingController();
  var cariara = TextEditingController();
  var stokara = TextEditingController();
  var stokarama = TextEditingController();
  var _fiyat = TextEditingController();
  var _aciklama = TextEditingController();
  var aaa = TextEditingController();
  var cmara = TextEditingController();
  var stara = TextEditingController();
  var grup = TextEditingController();
  DbStoklar _dbstoklar = DbStoklar();
  DbCariler _dbcariler = DbCariler();
  DbStokhareket _dbStokhareket = DbStokhareket();
  List<Carimodel> cariler = new List<Carimodel>();
  //List<Stokhareket> allNotes = new List<Stokhareket>();
  List<Stokmodel> stoklar = new List<Stokmodel>();

  List<Stokmodel> stokg = new List<Stokmodel>();
  List<Carimodel> carig = new List<Carimodel>();
  //List<Shstokh> stokh = new List<Shstokh>();
  List<StokHmodel> stokh = new List<StokHmodel>();
  List fiyatlar = List();
  List gruplar = List();
  String _carikod = "";
  String _stokkod = "";
  //String _fiyat = "";
  String _sfiyat1 = "";
  String _sfiyat2 = "";
  String _tarih = "";
  String _sipno = Global.sipno;
  double _bakiye = 0;
  String _kod4 = "";
  int duzenle = 0;
  double _toplam = 0;
  bool isAscending = true;
  FocusNode myFocusNode;
  FocusNode carifocus;
  FocusNode stokfocus;
  FocusNode miktarfocus;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  get statusListener => null;

  get errorListener => null;

  get resultListener => null;

  //var _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void dispose() {
    stokarama.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    //WidgetsBinding.instance.addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    cariara.addListener(_printLatestValue);
    myFocusNode = FocusNode();
    stokfocus = FocusNode();
    miktarfocus = FocusNode();
    _miktar.text = "1";
    sipnoal();
    _tarih = tarihduzenle(DateTime.now().toString());
    Timer.run(() {
      _carimodal();
    });
    miktarfocus.addListener(() {
      if (miktarfocus.hasFocus) {
        _miktar.selection =
            TextSelection(baseOffset: 0, extentOffset: _miktar.text.length);
      }
    });

    grupduzenle();

    // _dbsiparis.siparisliste().then((notes) {
    //   setState(() {
    //     notes.forEach((note) {
    //       allNotes.add(Stokhareket.fromMap(note));
    //     });
    //   });
    // });
  }
  /*Future<void> speechtotextt() async {
stt.SpeechToText speech = stt.SpeechToText();
                              bool available = await speech.initialize( onStatus: statusListener, onError: errorListener );
    if ( available ) {
        speech.listen( onResult: resultListener );
    }
    else {
        print("The user has denied the use of speech recognition.");
    }
    speech.stop();

   }*/

  Future<void> grupduzenle() async {
    await _dbstoklar.grupliste().then((gelen) {
      setState(() {
        gelen.forEach((veri) {
          gruplar.add(veri);
        });
      });
    });
    gruplar.sort((a, b) => a["kod9"]
        .replaceAll("Ç", "C")
        .replaceAll("İ", "I")
        .replaceAll("Ö", "O")
        .replaceAll("Ş", "S")
        .replaceAll("Ü", "U")
        .compareTo(b["kod9"]
            .replaceAll("Ç", "C")
            .replaceAll("İ", "I")
            .replaceAll("Ö", "O")
            .replaceAll("Ş", "S")
            .replaceAll("Ü", "U")));
    return null;
  }

  tutaral() {
    _toplam = 0;
    stokh.forEach((element) {
      setState(() {
        _toplam = _toplam +
            (double.parse(element.miktar) *
                double.parse(element.fiyat.replaceAll(",", ".")));
      });
    });
  }

  _printLatestValue() {
    print("text field: ${cariara.text}");
  }

  void carikodguncelle() async {
    stokh.forEach((element) {
      setState(() {
        element.carikod = _carikod;
        element.cariunvan = cariara.text.replaceAll('\'', ' ');
        element.aciklama = _aciklama.text;
      });
    });
    var durum = await _dbStokhareket.cariguncelle(
        _sipno, _carikod, cariara.text.replaceAll('\'', ' '), _aciklama.text);
  }

  void listedeara(String stokkodu) {
    final index =
        stokh.indexWhere((element) => element.stokkod.toString() == stokkodu);
    if (index >= 0) {
      setState(() {
        stokh[index].miktar = duzenle == 0
            ? (int.parse(stokh[index].miktar) + int.parse(_miktar.text))
                .toString()
            : _miktar.text;
        stokh[index].fiyat = _fiyat.text;
        stokh[index].aciklama = _aciklama.text;
      });
      shguncelle(index);
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
        stokh.add(StokHmodel.withJ(
            stokkod: _stokkod,
            carikod: _carikod,
            stokad: stokara.text,
            miktar: _miktar.text,
            tarih: DateTime.now().toString(),
            fiyat: _fiyat.text,
            sfiyat1: fiyatlar[0]["sfiyat1"].toString(),
            sfiyat2: fiyatlar[1]["sfiyat1"].toString(),
            kod4: _kod4,
            aciklama: _aciklama.text,
            kuladi: Global.kuladi,
            sipno: _sipno));
        shgekle();
        _stokkod = "";
        _miktar.text = "1";
        stokara.text = "";
        _fiyat.text = "0";
        _sfiyat1 = "";
        _sfiyat2 = "";
        _kod4 = "";
        //_toplam = (stokh.length.isNaN ? 0 : stokh.length);
      });
    }
    tutaral();
    duzenle = 0;
    stokfocus.requestFocus();
  }

  tarihduzenle(String t) {
    //String t = DateTime.now().toString();
    String yil = t.substring(0, 4);
    String ay = t.substring(5, 7);
    String gun = t.substring(8, 10);
    _tarih = gun + '/' + ay + '/' + yil;
    return _tarih;
  }

  void shguncelle(int inx) async {
    carikodguncelle();
    var durum = await _dbStokhareket.update(stokh[inx]);
  }

  void shgekle() async {
    carikodguncelle();
    var shid = await _dbStokhareket.insert(stokh.last);
    setState(() {
      stokh[stokh.indexOf(stokh.last)].shid = shid;
    });
  }

  void stokhsil(int inx) async {
    carikodguncelle();

    var durum = await _dbStokhareket.delete(stokh[inx]);
    setState(() {
      stokh.removeAt(inx);
    });
    tutaral();
  }

  void stokhyaz() async {
    carikodguncelle();
    String jsonn = jsonEncode(stokh.map((i) => i.toJson()).toList()).toString();
    // var durum = await _dbStokhareket.stokgonderstokh(jsonn);
  }

  void sipnoal() async {
    DbStokhareket _db = DbStokhareket();
    String gelen = await _db.sipnoal(Global.kuladi);
    setState(() {
      _sipno = gelen.toString();
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Warning'),
            content: new Text('Sign Out?'),
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
    return new WillPopScope(
        onWillPop: _onWillPop,
        child: new Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.blue[900],
              elevation: 0,
              titleSpacing: 0.0,
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.payments,
                    color: Colors.white,
                  ),
                )
              ],
              centerTitle: true,
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "New order",
                    // style: TextStyle(fontSize: 12,),
                  ),
                ],
              )),
          drawer: MyDrawer(),
          body: Container(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 15,
                    child: AppBar(
                      leading: Text(
                        "BALANCE : " +
                            NumberFormat.currency(locale: "eu", symbol: "TL")
                                .format(_bakiye),
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      leadingWidth: 200,
                      elevation: 0,
                      backgroundColor: Colors.blue[100],
                      automaticallyImplyLeading: false,
                      actions: <Widget>[
                        Text(
                          tarihduzenle(DateTime.now().toString()),
                          style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
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
                          _bakiye = double.parse(gg[0].bakiye);
                          carifocus.requestFocus();
                        } else {
                          _carikod = "";
                          cariara.text = "";
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Current Not Found!'),
                                content: Text('entered "$value".'),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'),
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
                      prefixText: _carikod + " ",
                      prefixStyle: TextStyle(color: Colors.red),
                      hintText: "Enter Current Code or Title",
                      labelText: 'Current Code-Title',
                      labelStyle: TextStyle(color: Colors.blue[800]),
                      suffixIcon: IconButton(
                        onPressed: () => _carimodal(),
                        icon: Icon(
                          Icons.search,
                          size: 30,
                          color: Colors.blue[600],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    style: TextStyle(fontSize: 15),
                    //maxLines: 2,
                    keyboardType: TextInputType.number,
                    controller: stokara,
                    focusNode: stokfocus,
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        stokgetir(value).then((gg) {
                          if (gg.isNotEmpty) {
                            stokara.text = gg[0].stokad.toString();
                            _stokkod = gg[0].stokkod.toString();
                            _sfiyat1 = gg[0].sfiyat1.toString();
                            _sfiyat2 = gg[0].sfiyat2.toString();
                            _fiyat.text = gg[0].sfiyat1.toString();
                            _kod4 = gg[0].kod4.toString();
                            fiyatlar.clear();
                            fiyatlar.add({"sfiyat1": gg[0].sfiyat1.toString()});
                            fiyatlar.add({"sfiyat1": gg[0].sfiyat2.toString()});
                            _stokmodal();
                          } else {
                            _stokkod = "";
                            stokara.text = "";
                            showDialog<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Product Not Found!'),
                                  content: Text('entered "$value".'),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                            stokfocus..requestFocus();
                          }
                        });
                      } else {
                        _stokkod = "";
                        stokara.text = "";
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Error !'),
                              content: Text('Value Entered Blank'),
                              actions: <Widget>[
                                FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                        stokfocus..requestFocus();
                      }
                    },
                    decoration: InputDecoration(
                      isDense: true, // Added this
                      contentPadding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      hintText: "Enter Stock Code or Barcode",
                      labelText: 'Stock Code-Name',
                      labelStyle: TextStyle(color: Colors.blue[800]),
                      prefixIcon: IconButton(
                        onPressed: () async {
                          setState(() {
                            stokara.clear();
                          });
                        },
                        icon: Icon(
                          Icons.clear,
                          size: 25,
                          color: Colors.blue[600],
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _settingModalBottomSheet();
                        },
                        icon: Icon(
                          Icons.search,
                          size: 30,
                          color: Colors.blue[600],
                        ),
                      ),
                    ),
                  ),
                  Container(
                      decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[200],
                      width: 2,
                    ),
                  )),
                  Expanded(
                      child: Ink(
                    color: Colors.grey[200],
                    child: NotificationListener<ScrollStartNotification>(
                      child: ListView.builder(
                          itemCount: stokh.length,
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
                          itemBuilder: (context, position) {
                            return Container(
                              color: Colors.grey[200],
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    color: Color.fromRGBO(9, 34, 96, 0.8),
                                    height: 45,
                                    child: ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.only(
                                          left: 3, right: 3, top: 1, bottom: 1),
                                      onTap: () => {
                                        _stokkod = '${stokh[position].stokkod}',
                                        stokara.text =
                                            '${stokh[position].stokad}',
                                        cmara.text =
                                            '${stokh[position].miktar}',

                                        _miktar.text =
                                            '${stokh[position].miktar}',
                                        _kod4 = '${stokh[position].kod4}',
                                        fiyatlar.clear(),
                                        _fiyat.text =
                                            '${stokh[position].fiyat}',
                                        fiyatlar.add({
                                          "sfiyat1":
                                              stokh[position].sfiyat1.toString()
                                        }),
                                        fiyatlar.add({
                                          "sfiyat1":
                                              stokh[position].sfiyat2.toString()
                                        }),
                                        // setState(() {
                                        //   stokh.remove(stokh[position]);
                                        // }),
                                        // tutaral(),
                                        duzenle = 1,
                                        _stokmodal()
                                      },
                                      onLongPress: () => {
                                        showDialog<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Unregister !'),
                                              content:
                                                  Text('Delete Selected Row?'),
                                              actions: <Widget>[
                                                FlatButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                FlatButton(
                                                    onPressed: () {
                                                      var index = stokh
                                                          .indexWhere((element) =>
                                                              element.stokkod
                                                                  .toString() ==
                                                              '${stokh[position].stokkod}');
                                                      stokhsil(index);
                                                      tutaral();
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("Delete"))
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
                                              '${stokh[position].stokkod}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white),
                                            ),
                                          ]),
                                      title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              '${stokh[position].stokad}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white),
                                            ),
                                          ]),
                                      trailing: Container(
                                          width: 85,
                                          child: (Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                    stokh.length > 0
                                                        ? 'Miktar : ${stokh[position].miktar} ' +
                                                            '\nFiyat    : ${stokh[position].fiyat}' +
                                                            '\nTutar   : ${(double.parse(stokh[position].miktar) * double.parse(stokh[position].fiyat.replaceAll(',', '.'))).toStringAsFixed(2)}'
                                                        : '',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.white)),
                                              ]))),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  )
                                ],
                              ),
                            );
                          }),
                      onNotification: (_) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),
                  )),
                  Container(
                    height: 30,
                    child: AppBar(
                      elevation: 0,
                      backgroundColor: Colors.blue[100],
                      title: Text(
                          "Total : " +
                              stokh.length.toString() +
                              "Product - Amount : " +
                              NumberFormat.currency(locale: "eu", symbol: "TL")
                                  .format(_toplam),
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                      automaticallyImplyLeading: false,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    height: 32,
                    child: TextField(
                      maxLength: 29,
                      style: TextStyle(fontSize: 15),
                      controller: _aciklama,
                      onSubmitted: (value) {
                        carikodguncelle();
                      },
                      decoration: InputDecoration(
                        counterText: "",
                        prefixIcon: Padding(
                            padding: EdgeInsets.all(2),
                            child: Text('Explanation:',
                                style: TextStyle(
                                    color: Colors.blue[900], fontSize: 12))),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          // floatingActionButton: Container(
          //   height: 50.0,
          //   width: 50.0,
          //   child: FittedBox(
          //     child: FloatingActionButton(
          //         elevation: 10,
          //         child: new Icon(Icons.save, size: 35),
          //         backgroundColor: Colors.blue[900],
          //         onPressed: () {
          //           _kaydet();
          //         }),
          //   ),
          // ),
        ));
  }

  void _kaydet() async {
    if (_carikod != "" && stokh.length > 0) {
      // var sdata = json.decode(stokh.toList());
      //var listeal = stokh as List;
      int sipnokontrol = await _dbStokhareket.sipnokontrol(_sipno);
      if (sipnokontrol > 0) {
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.green[900],
              title: const Text('Registration Available!',
                  style: TextStyle(color: Colors.white)),
              content: Text('Registration Available. Update?',
                  style: TextStyle(color: Colors.white)),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    //  Navigator.pop(context);

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
        for (var activity in stokh) {
          StokHmodel actData = StokHmodel.fromMap(activity.toMap());
          // stokcontroller.text = actData.toString();
          var gelen = await _dbStokhareket.insert(actData);
          if (gelen > 0) {
            showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Register',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.green[800],
                  content: Text('ORDER SAVED!',
                      style: TextStyle(color: Colors.white)),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/siparisler");
                      },
                      child: const Text('OK',
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
                  title: const Text('Error !',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red[900],
                  content: Text('ORDER NOT SAVED',
                      style: TextStyle(color: Colors.white)),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK',
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
                child: const Text('OK'),
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

  Future<List<Stokmodel>> stokgetir(filter) async {
    var models;
    var gelen = await _dbstoklar.stokara(filter);
    models = Stokmodel.fromJsonList(gelen);
    return models;
  }

  Future<List<Stokmodel>> stokliste(String aranacak) async {
    DbStoklar db = new DbStoklar();
    //stokg = new List<Stokmodel>();
    var gelen = await db.stokaralike(aranacak.toUpperCase());
    setState(() {
      stokg = Stokmodel.fromJsonList(gelen);
    });
    stokg.sort((a, b) => a.stokad
        .replaceAll("Ç", "C")
        .replaceAll("İ", "I")
        .replaceAll("Ö", "O")
        .replaceAll("Ş", "S")
        .replaceAll("Ü", "U")
        .compareTo(b.stokad
            .replaceAll("Ç", "C")
            .replaceAll("İ", "I")
            .replaceAll("Ö", "O")
            .replaceAll("Ş", "S")
            .replaceAll("Ü", "U")));
    return stokg;
  }

  Future<List<Stokmodel>> stokgrupliste(String aranacak) async {
    DbStoklar db = new DbStoklar();
    //stokg = new List<Stokmodel>();
    var gelen = await db.stokaragrup(aranacak);
    setState(() {
      stokg = Stokmodel.fromJsonList(gelen);
    });
    stokg.sort((a, b) => a.stokad
        .replaceAll("Ç", "C")
        .replaceAll("İ", "I")
        .replaceAll("Ö", "O")
        .replaceAll("Ş", "S")
        .replaceAll("Ü", "U")
        .compareTo(b.stokad
            .replaceAll("Ç", "C")
            .replaceAll("İ", "I")
            .replaceAll("Ö", "O")
            .replaceAll("Ş", "S")
            .replaceAll("Ü", "U")));
    return stokg;
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

  _settingModalBottomSheet() async {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, state) {
            return Column(children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 30)),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text("'   '"),
                    Text(
                      "Stock Search",
                      style: TextStyle(color: Colors.blue[800], fontSize: 20),
                    ),
                    IconButton(
                        iconSize: 30,
                        icon: Icon(Icons.close),
                        color: Colors.black54,
                        onPressed: () => Navigator.pop(context)),
                  ]),
              Container(
                  padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                  child: TextField(
                    readOnly: true,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.orange[900],
                    ),
                    controller: grup,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: Padding(
                          padding: EdgeInsets.fromLTRB(5, 12, 0, 15),
                          child: Text('Product group ',
                              style: TextStyle(fontSize: 15))),
                      suffixIcon: PopupMenuButton(
                        initialValue: gruplar,
                        icon: const Icon(Icons.arrow_drop_down),
                        onSelected: (value) async {
                          grup.text = value["kod9"].toString();
                          await stokgrupliste(grup.text).whenComplete(() {
                            updated(state);
                            FocusScope.of(context).unfocus();
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          return gruplar
                              .map(
                                (day) => PopupMenuItem(
                                  child: Text(day["kod9"].toString()),
                                  value: day,
                                ),
                              )
                              .toList();
                        },
                      ),
                    ),
                    //keyboardType: TextInputType.number,
                  )),
              TextField(
                autofocus: true,
                controller: aaa,
                style: TextStyle(fontSize: 18),
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Colors.grey[200],
                  filled: true,
                  hintText: 'Enter Stock Code or StockName',
                  prefixIcon: IconButton(
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
                  await stokliste(text).whenComplete(() {
                    updated(state);
                  });
                },
              ),
              Expanded(
                  child: RefreshIndicator(
                strokeWidth: 3,
                backgroundColor: Colors.blue[900],
                color: Colors.white,
                key: _refreshIndicatorKey,
                onRefresh: () async {
                  await stokliste(aaa.text).whenComplete(() {
                    grup.text = "";
                    updated(state);
                  });
                },
                child: NotificationListener<ScrollStartNotification>(
                  child: ListView.builder(
                      itemCount: stoklar.length,
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
                                  '${stoklar[position].stokad}',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Global.mavi,
                                  ),
                                ),
                                // subtitle: Text(
                                //   '${stoklar[position].aciklama}',
                                //   style: new TextStyle(
                                //     fontSize: 15.0,
                                //     fontStyle: FontStyle.italic,
                                //   ),
                                // ),
                                leading: Column(
                                  children: <Widget>[
                                    Padding(padding: EdgeInsets.all(8.0)),
                                    Text(
                                      '${stoklar[position].stokkod}',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    _stokkod =
                                        stoklar[position].stokkod.toString();
                                    stokara.text =
                                        stoklar[position].stokad.toString();
                                    _fiyat.text =
                                        stoklar[position].sfiyat1.toString();
                                    fiyatlar.clear();
                                    fiyatlar.add({
                                      "sfiyat1":
                                          stoklar[position].sfiyat1.toString()
                                    });
                                    fiyatlar.add({
                                      "sfiyat1":
                                          stoklar[position].sfiyat2.toString()
                                    });

                                    _kod4 = stoklar[position].kod4.toString();
                                  });

                                  Navigator.pop(context);
                                  _stokmodal();
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
          });
        });
  }

  _carimodal() {
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
                          "Current Search",
                          style:
                              TextStyle(color: Colors.blue[800], fontSize: 20),
                        ),
                        IconButton(
                            iconSize: 30,
                            icon: Icon(Icons.close),
                            color: Colors.black54,
                            onPressed: () => Navigator.pop(context)),
                      ]),
                  TextField(
                    autofocus: true,
                    controller: cmara,
                    style: TextStyle(fontSize: 18),
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Colors.grey[200],
                      filled: true,
                      hintText: 'Enter Current Code or Title',
                      prefixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            cmara.clear();
                          });
                        },
                        icon: Icon(
                          Icons.clear,
                          size: 30,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    onChanged: (text) async {
                      await carilist(cmara.text);
                      await cmguncelle(state);
                    },
                  ),

                  /* Container(
                    
                     padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: TextHighlight(
            
            text: _text,
            //words: _highlights,
            textStyle: const TextStyle(
              fontSize: 32.0,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ), words: null,
          ),
                  ),*/
                  Expanded(
                      child: RefreshIndicator(
                    strokeWidth: 3,
                    backgroundColor: Colors.blue[900],
                    color: Colors.white,
                    key: _refreshIndicatorKey,
                    onRefresh: () async {
                      await carilist(cmara.text).whenComplete(() {
                        cmguncelle(state);
                      });
                    },
                    child: NotificationListener<ScrollStartNotification>(
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
                                      '${cariler[position].cariunvan.replaceAll('\'', ' ')}',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        color: Global.mavi,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "BALANCE : " +
                                          NumberFormat.currency(
                                                  locale: "eu", symbol: "TL")
                                              .format(double.parse(
                                                  cariler[position]
                                                      .bakiye
                                                      .replaceAll(",", "."))),
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
                                      setState(() {
                                        _carikod = cariler[position]
                                            .carikod
                                            .toString();
                                        cariara.text = cariler[position]
                                            .cariunvan
                                            .toString();
                                        _bakiye = double.parse(cariler[position]
                                            .bakiye
                                            .replaceAll(",", "."));
                                      });
                                      carikodguncelle();
                                      stokfocus.requestFocus();
                                      Navigator.pop(context);
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

  _stokmodal() {
    showModalBottomSheet(
        backgroundColor: Colors.grey[200],
        isDismissible: true,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, state) {
            return Column(children: <Widget>[
              Padding(padding: EdgeInsets.fromLTRB(15, 30, 5, 0)),
              Text(
                "STOCK INFORMATION",
                style: TextStyle(color: Colors.blue[800], fontSize: 15),
              ),
              SizedBox(height: 7),
              Text(
                _stokkod,
                style: TextStyle(fontSize: 20),
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
                      Container(
                          padding: EdgeInsets.all(8),
                          child: TextField(
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.orange[900],
                            ),
                            autofocus: true,
                            focusNode: miktarfocus,
                            controller: _miktar,
                            onChanged: (text) {},
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Text('Enter Amount ')),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          padding: EdgeInsets.all(8),
                          child: TextField(
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.orange[900],
                            ),
                            controller: _fiyat,
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Text('Select Price ')),
                              suffixIcon: PopupMenuButton(
                                initialValue: fiyatlar,
                                icon: const Icon(Icons.arrow_drop_down),
                                onSelected: (value) {
                                  _fiyat.text = value["sfiyat1"].toString();
                                },
                                itemBuilder: (BuildContext context) {
                                  return fiyatlar
                                      .map(
                                        (day) => PopupMenuItem(
                                          child:
                                              Text(day["sfiyat1"].toString()),
                                          value: day,
                                        ),
                                      )
                                      .toList();
                                },
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          )),
                      Wrap(children: <Widget>[
                        TextButton(
                            onPressed: () {},
                            child: Text("The amount of stock : ",
                                style: TextStyle(
                                    color: Colors.red[800], fontSize: 15))),
                        SizedBox(
                          width: 30,
                        ),
                        TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.blue[600]),
                            ),
                            onPressed:
                                (fiyatlar[1]["sfiyat1"].toString() == '0,00')
                                    ? () => {null}
                                    : () {
                                        _fiyat.text =
                                            fiyatlar[1]["sfiyat1"].toString();
                                        _miktar.text = _kod4;
                                      },
                            child: Text("Box : " + _kod4,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                )))
                      ]),
                      SizedBox(
                        height: 5,
                      ),
                      MaterialButton(
                        height: 50,
                        onPressed: () {
                          // print(_fiyat.text
                          //     .substring(_fiyat.text.indexOf(','),
                          //         _fiyat.text.length - 1)
                          //     .length);
                          if (_miktar.text.isEmpty ||
                              _miktar.text == "0" ||
                              _fiyat.text.isEmpty ||
                              _fiyat.text == "0,00" ||
                              _fiyat.text == "0" ||
                              _fiyat.text == "0.00" ||
                              _fiyat.text.contains(".") ||
                              _fiyat.text.contains(",") &&
                                  ','.allMatches(_fiyat.text).length >= 2 ||
                              _fiyat.text.contains(",") &&
                                  _fiyat.text
                                          .substring(_fiyat.text.indexOf(','),
                                              _fiyat.text.length - 1)
                                          .length >=
                                      3 ||
                              _fiyat.text.contains(",") &&
                                  _fiyat.text
                                          .substring(_fiyat.text.indexOf(','),
                                              _fiyat.text.length - 1)
                                          .length <=
                                      0) {
                            showDialog<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error !'),
                                  content: Text('AMOUNT or PRICE Invalid!'),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            listedeara(_stokkod);
                            Navigator.pop(context);
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
        }).whenComplete(() {
      setState(() {
        _miktar.text = "1";
        fiyatlar.clear();
        fiyatlar.add({"sfiyat1": 0});
        fiyatlar.add({"sfiyat1": 0});
      });
    });
  }

  Future<Null> updated(StateSetter updateState) async {
    updateState(() {
      stoklar = stokg;
    });
  }

  Future<Null> cmguncelle(StateSetter updateState) async {
    updateState(() {
      cariler = carig;
    });
  }
}
