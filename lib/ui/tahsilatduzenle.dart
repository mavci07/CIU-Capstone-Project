import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:karakaya_soguk/db/dbcariler.dart';
import 'package:karakaya_soguk/db/dbcarihareket.dart';
import 'package:karakaya_soguk/model/chmodel.dart';
import 'package:karakaya_soguk/model/carimodel.dart';
import 'package:karakaya_soguk/static/global.dart';
import 'dart:core';
import 'dart:convert';
import 'anasayfa.dart';

class Tahsilatduzenle extends StatefulWidget {
  final String _kayno;
  const Tahsilatduzenle(this._kayno);
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<Tahsilatduzenle> {
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
  double _bakiye = 0;
  double _borc = 0;
  double _alacak = 0;
  String _tarih = "";
  int duzenle = 0;
  int cahaid;
  // String _tahsno = Global.tahsno;
  double _toplam = 0;
  bool isAscending = true;
  FocusNode tahsfocus;
  FocusNode carifocus;
  FocusNode tutarfocus;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  //var _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    cariara.addListener(_printLatestValue);
    tahsfocus = FocusNode();
    tutarfocus = FocusNode();
    listeal();
  }

  Future<void> listeal() async {
    final list = await _dbCarihareket.tahsnogetir(widget._kayno);
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
          _carikod = gg[0].carikod.toString();
          _bakiye = double.parse(gg[0].bakiye.replaceAll(',', '.'));
          _borc = double.parse(gg[0].borc.replaceAll(',', '.'));
          _alacak = double.parse(gg[0].alacak.replaceAll(',', '.'));
        });
        // carifocus.requestFocus();
      }
    });
  }

  void carikodguncelle() async {
    carih.forEach((element) {
      setState(() {
        element.carikod = _carikod;
        element.aciklama = _aciklama.text;
        element.tahsno = tahsilatno.text;
        element.kuladi = Global.kuladi;
      });
    });
    var durum = await _dbCarihareket.cariguncelle(
        tahsilatno.text, widget._kayno, _carikod, _aciklama.text);
  }

  _printLatestValue() {
    print("text field: ${cariara.text}");
  }

  // void tahsnoal() async {
  //   DbCarihareket _db = DbCarihareket();
  //   int gelen = await _db.sipnoal();
  //   setState(() {
  //     _tahsno = Global.tahsno + (gelen + 1).toString().padLeft(6, '0');
  //   });
  // }

  void hesapla() {
    double t = 0;
    for (int i = 0; i < carih.length; i++) {
      t = t + double.parse(carih[i].borc.replaceAll(",", "."));
    }
    _toplam = t;
  }

  tarihduzenle(String t) {
    String yil = t.substring(0, 4);
    String ay = t.substring(5, 7);
    String gun = t.substring(8, 10);
    _tarih = gun + '/' + ay + '/' + yil;
    return _tarih;
  }

  void listeyeekle(String islem) {
    final index =
        carih.indexWhere((element) => element.islemtip.toString() == "NAKİT");
    if (index >= 0 && islem == 'NAKİT') {
      setState(() {
        carih[index].borc =
            (double.parse(carih[index].borc.replaceAll(",", ".")) +
                    double.parse(tutar.text.replaceAll(",", ".")))
                .toString();
        hesapla();
        chguncelle(index);
        //_toplam = double.parse(carih.length);
      });

      // _toplam = carih.length;

      _islem = "NAKİT";
      tutar.text = "";
    } else {
      if (duzenle == 1) {
        setState(() {
          carih.add(CariHmodel.withJ(
              chid: cahaid,
              carikod: _carikod,
              borc: tutar.text,
              islemtip: _islem,
              tarih: DateTime.now().toString(),
              tahsno: tahsilatno.text,
              kuladi: Global.kuladi,
              aciklama: _aciklama.text,
              kayno: widget._kayno));
          tutar.text = "";
          hesapla();
          chguncelle(carih.indexOf(carih.last));
          //_toplam = carih.length;
        });
        _islem = "NAKİT";
        cahaid = null;
        duzenle = 0;
      } else {
        setState(() {
          carih.add(CariHmodel.withJ(
              carikod: _carikod,
              borc: tutar.text,
              islemtip: _islem,
              tarih: DateTime.now().toString(),
              tahsno: tahsilatno.text,
              kuladi: Global.kuladi,
              aciklama: _aciklama.text,
              kayno: widget._kayno));
          tutar.text = "";
          hesapla();
          chgekle();
        });
      }
    }
  }

  void chguncelle(int inx) async {
    carikodguncelle();
    var durum = await _dbCarihareket.update(carih[inx]);
  }

  void chgekle() async {
    carikodguncelle();
    var chid = await _dbCarihareket.insert(carih.last);
    setState(() {
      carih[carih.indexOf(carih.last)].chid = chid;
    });
  }

  void carihsil(int inx) async {
    carikodguncelle();
    var durum =
        await _dbCarihareket.delete(carih[inx]).then((value) => setState(() {
              carih.removeAt(inx);
              hesapla();
            }));
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
                  Navigator.pushNamed(context, "/tahsilatlar");
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
            elevation: 0,
            backgroundColor: Colors.green[800],
            centerTitle: true,
            title: Text("Edit Collection"),
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
                      leadingWidth: 200,
                      elevation: 0,
                      backgroundColor: Colors.green[100],
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
                  TextField(
                    style: TextStyle(fontSize: 15),
                    readOnly: true,
                    controller: cariara,
                    maxLines: 2,
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
                      hintText: "Enter Current Code or Title",
                      labelText: 'CURRENT CODE- TITLE',
                      labelStyle: TextStyle(color: Colors.red),
                      prefixText: _carikod + '  ',
                      prefixStyle: TextStyle(
                          color: Colors.blue[900], fontWeight: FontWeight.bold),
                      suffixIcon: IconButton(
                        onPressed: () => _carimodal(),
                        icon: Icon(
                          Icons.search,
                          size: 30,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  Container(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                        Expanded(
                            child: TextField(
                          style: TextStyle(fontSize: 15),
                          controller: tahsilatno,
                          focusNode: tahsfocus,
                          onSubmitted: (value) {
                            carikodguncelle();
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20.0, 5, 0, 0),
                            hintText: "Enter Collection No.",
                            labelText: 'COLLECTION NO',
                            labelStyle: TextStyle(color: Colors.red),
                            // suffixIcon: IconButton(
                            //   onPressed: () => _carimodal(),
                            //   icon: Icon(
                            //     Icons.search,
                            //     size: 35,
                            //     color: Colors.grey[400],
                            //   ),
                            // ),
                          ),
                          keyboardType: TextInputType.number,
                        )),
                        Expanded(
                            child: DropdownButtonFormField(
                                dropdownColor: Colors.green[100],
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(20.0, 5, 0, 0),
                                  //filled: true,
                                  // fillColor: Hexcolor('#ecedec'),
                                  labelText: 'PROCESS TYPE',
                                  labelStyle: TextStyle(color: Colors.red),
                                  // fillColor: Colors.red[50]
                                  // border: new CustomBorderTextFieldSkin().getSkin(),
                                ),
                                isExpanded: false,
                                value: _islem,
                                items: [
                                  DropdownMenuItem(
                                    child: Text("CASH"),
                                    value: "NAKİT",
                                  ),
                                  DropdownMenuItem(
                                    child: Text("CREDIT"),
                                    value: "KREDİ",
                                  )
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _islem = value;
                                  });
                                  tutarfocus.requestFocus();
                                }))
                      ])),
                  TextField(
                    controller: tutar,
                    focusNode: tutarfocus,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(20.0, 5, 0, 0),
                      hintText: "Enter Amount",
                      labelText: 'Amount',
                      labelStyle: TextStyle(color: Colors.red),
                      suffixIcon: IconButton(
                        onPressed: () => {
                          if (tutar.text.isEmpty ||
                              tutar.text == "0,00" ||
                              tutar.text == "0" ||
                              tutar.text == "0.00" ||
                              tutar.text.contains("."))
                            {
                              showDialog<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Error !'),
                                    content: Text('PRICE Invalid !'),
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
                              )
                            }
                          else if (_carikod.isEmpty && _carikod == "")
                            {
                              showDialog<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Error !'),
                                    content: Text('Current Not Selected !'),
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
                              )
                            }
                          else if (tahsilatno.text.isEmpty &&
                              tahsilatno.text == "")
                            {
                              showDialog<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Error !'),
                                    content:
                                        Text('Collection Number Not Entered !'),
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
                              )
                            }
                          else
                            {
                              listeyeekle(_islem),
                            }
                        },
                        icon: Icon(
                          Icons.add_circle,
                          size: 35,
                          color: Colors.red,
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
                              'PROCESS TYPE',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            )),
                        Container(
                          margin: EdgeInsets.fromLTRB(20, 4, 0, 4),
                          width: 100,
                          child: Text(
                            'AMOUNT',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Ink(
                        color: Colors.grey[200],
                        child: NotificationListener<ScrollStartNotification>(
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
                                                    _carikod =
                                                        '${carih[position].carikod}',
                                                    _islem =
                                                        '${carih[position].islemtip}',
                                                    tutar.text =
                                                        '${(double.parse(carih[position].borc.replaceAll(",", ".")).toStringAsFixed(2)).replaceAll(".", ",")}',
                                                    setState(() {
                                                      cahaid =
                                                          carih[position].chid;
                                                      carih.remove(
                                                          carih[position]);
                                                      hesapla();
                                                      duzenle = 1;
                                                    }),
                                                  },
                                              onLongPress: () => {
                                                    showDialog<void>(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Unregister !'),
                                                          content: Text(
                                                              'Delete Selected Row?'),
                                                          actions: <Widget>[
                                                            FlatButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                  'Cancel'),
                                                            ),
                                                            FlatButton(
                                                                onPressed:
                                                                    () => {
                                                                          carihsil(
                                                                              carih.indexOf(carih[position])),
                                                                          Navigator.pop(
                                                                              context)
                                                                        },
                                                                child: Text(
                                                                    "delete"))
                                                          ],
                                                        );
                                                      },
                                                    )
                                                  },
                                              child: Card(
                                                color: Colors.green[100],
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color: Colors.green[200],
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Row(
                                                  children: <Widget>[
                                                    Container(
                                                        margin:
                                                            EdgeInsets.all(10),
                                                        width: 200,
                                                        child: Text(
                                                          '${carih[position].islemtip}',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                    Container(
                                                      margin:
                                                          EdgeInsets.all(10),
                                                      width: 100,
                                                      child: Text(
                                                          NumberFormat.currency(
                                                                  locale: "eu",
                                                                  symbol: "TL")
                                                              .format(double.parse(
                                                                  carih[position]
                                                                      .borc
                                                                      .replaceAll(
                                                                          ",",
                                                                          "."))),
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ),
                                                  ],
                                                ),
                                              ))
                                        ]),
                                      ],
                                    ),
                                  );
                                }))),
                  ),
                  Container(
                    height: 22,
                    child: AppBar(
                      backgroundColor: Colors.green[200],
                      title: Text(
                          "Total: " +
                              NumberFormat.currency(locale: "eu", symbol: "TL")
                                  .format(_toplam),
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold)),
                      automaticallyImplyLeading: false,
                    ),
                  ),
                  Container(
                    height: 22,
                    child: AppBar(
                      backgroundColor: Colors.green[200],
                      title: Text(
                          "Debt: " +
                              NumberFormat.currency(locale: "eu", symbol: "TL")
                                  .format(_borc) +
                              ' receivable: ' +
                              NumberFormat.currency(locale: "eu", symbol: "TL")
                                  .format(_alacak) +
                              ' Balance: ' +
                              NumberFormat.currency(locale: "eu", symbol: "TL")
                                  .format(_bakiye),
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold)),
                      automaticallyImplyLeading: false,
                    ),
                  ),
                  TextField(
                    maxLength: 29,
                    style: TextStyle(fontSize: 13),
                    controller: _aciklama,
                    onSubmitted: (value) {
                      carikodguncelle();
                    },
                    decoration: InputDecoration(
                      counterText: "",
                      border: null,
                      labelText: 'Explanation',
                      labelStyle: TextStyle(color: Colors.red),
                      isDense: true, // Added this
                      contentPadding: EdgeInsets.all(8), // Added this
                    ),
                  ),
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
          //         backgroundColor: Colors.orange[900],
          //         onPressed: () {
          //           _kaydet();
          //         }),
          //   ),
          // ),
        ));
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
      int sipnokontrol = await _dbCarihareket.tahsnokontrol(tahsilatno.text);
      if (sipnokontrol > 0) {
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.red[400],
              title: const Text('Registration Available !',
                  style: TextStyle(color: Colors.white)),
              content: Text(
                  'Collection Number Used. Please Change Collection Number',
                  style: TextStyle(color: Colors.white)),
              actions: <Widget>[
                FlatButton(
                    onPressed: () => {Navigator.pop(context)},
                    child: Text("Close", style: TextStyle(color: Colors.white)))
              ],
            );
          },
        );
      } else {
        carikodguncelle();
        for (var activity in carih) {
          CariHmodel actData = CariHmodel.fromMap(activity.toMap());
          // stokcontroller.text = actData.toString();
          var gelen = await _dbCarihareket.insert(actData);
          if (gelen > 0) {
            showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('RECORD',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.green[800],
                  content: Text('COLLECTION REGISTERED!',
                      style: TextStyle(color: Colors.white)),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/tahsilatlar");
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
                  content: Text('COLLECTION NOT RECORDED',
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
            content: Text('No Current Card Selected or No Collection Added'),
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
                        )),
                    onChanged: (text) async {
                      await carilist(cmara.text);
                      await cmguncelle(state);
                    },
                  ),
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
                                      '${cariler[position].cariunvan}',
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
                                            .replaceAll(',', '.'));

                                        _borc = double.parse(cariler[position]
                                            .borc
                                            .replaceAll(',', '.'));
                                        _alacak = double.parse(cariler[position]
                                            .alacak
                                            .replaceAll(',', '.'));
                                      });
                                      carikodguncelle();
                                      tahsfocus.requestFocus();
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
