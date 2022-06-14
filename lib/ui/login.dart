import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:karakaya_soguk/db/dbcariler.dart';
import 'package:karakaya_soguk/db/kullanicimodel.dart';
import 'package:karakaya_soguk/db/dbislem.dart';
import 'package:karakaya_soguk/static/global.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<LoginPage> {
  DBKullanici _dbKullanici = DBKullanici();
  DbCariler db = new DbCariler();
  List<Kullanicilar> allNotes = new List<Kullanicilar>();
  var _kuladi = TextEditingController();
  var _pass = TextEditingController();
  String kulladi;
  int yuklendi = 0;
  String sonucmesaj = "";
  List kulListe = List();
  @override
  initState() {
    super.initState();
    tablokontrol().then((value) => _statikler()).then((value) => kulkontrol());
    //_statikler();
    // kulkontrol();
  }

  Future<void> tablokontrol() async {
    await db.initializeDatabase().then((value) => setState(() {
          yuklendi = 1;
        }));
  }

  _statikler() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      Global.sunucu = (prefs.getString('sunucu') ?? "");
      Global.sqlsa = (prefs.getString('sqlsa') ?? "");
      Global.sqlpass = (prefs.getString('sqlpass') ?? "");
      Global.sirket = (prefs.getString('sirket') ?? "");
    });
  }

  kulkontrol() async {
    var sonuc = await _dbKullanici.kulliste().then((value) async {
      if (value.length > 0)
        setState(() {
          kulListe = value;
        });
    });
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (yuklendi == 0) {
      return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.blue[900],
          title: new Text("Loading..."),
        ),
      );
    } else {
      return new WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
              appBar: AppBar(
                backgroundColor: Color.fromRGBO(9, 34, 96, 0.8),
                title: Text('CIU Capstone Project'),
                centerTitle: true,
                automaticallyImplyLeading: false,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, "/ayarlar");
                    },
                  )
                ],
                leading: IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    sonucmesaj = "";
                    var sonuc = kullanici().then((value) => sonucmesaj = value);
                  },
                ),
              ),
              body: Padding(
                  padding: EdgeInsets.all(10),
                  child: ListView(
                    children: <Widget>[
                      Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Log In',
                            style: TextStyle(
                                color: Colors.blue[900],
                                fontWeight: FontWeight.w500,
                                fontSize: 30),
                          )),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: DropdownButtonFormField(
                            dropdownColor: Colors.blue[100],
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Username',
                                labelStyle: TextStyle(color: Colors.blue[900])),
                            items: kulListe.map((item) {
                              return new DropdownMenuItem(
                                  child: Text(
                                    item["name"],
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  value: item['kuladi'].toString());
                            }).toList(),
                            onChanged: (newVal) {
                              setState(() {
                                kulladi = newVal;
                              });
                            },
                            value: kulladi),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: TextField(
                          obscureText: true,
                          controller: _pass,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                          ),
                        ),
                      ),
                      Container(
                        height: 70,
                        padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                        child: RaisedButton(
                            textColor: Colors.white,
                            color: Colors.blue[900],
                            child: Text('Log In'),
                            onPressed: () async {
                              if (_kuladi.text == "" && _pass.text == "") {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                            "Username or Password Entered Blank"),
                                      );
                                    });
                              } else {
                                var sonuc = await _dbKullanici.kulkontrol(
                                    kulladi, _pass.text);
                                if (sonuc.length > 0) {
                                  setState(() {
                                    Global.kuladi =
                                        sonuc[0]["kuladi"].toString();
                                    Global.name = sonuc[0]["name"].toString();
                                    Global.sipno = sonuc[0]["sipno"].toString();
                                    Global.rutkodu =
                                        sonuc[0]["rutkodu"].toString();
                                  });

                                  return Navigator.pushNamed(
                                      context, "/siparisler");
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                              "Username or Password Not Found"),
                                        );
                                      });
                                }
                              }
                            }),
                      ),
                      Center(
                          child: Container(
                              height: 70,
                              padding: EdgeInsets.fromLTRB(0, 50, 10, 0),
                              child: Text(sonucmesaj)))
                    ],
                  ))));
    }
  }

  Future<String> kullanici() async {
    try {
      var liste = await _dbKullanici.kulliste();
      if (liste.length > 0) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Registration Available'),
                content: Text("Users Available. Update?"),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () async {
                      var kul = await _dbKullanici.kulcek().then((value) async {
                        if (value != null) {
                          var tem = _dbKullanici.temizle();
                          var kuljson = json.decode(value.body);
                          var kulliste = kuljson as List;
                          for (var k in kulliste) {
                            Kullanicilar kulyaz = Kullanicilar.fromMap(k);
                            await _dbKullanici.insert(kulyaz);
                          }
                          setState(() {
                            kulListe = kuljson;
                          });
                        } else {
                          showDialog<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text(';Error'),
                                  content: Text("Failed to Retrieve Data"),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Okey'),
                                    ),
                                  ],
                                );
                              });
                        }
                      });

                      Navigator.pop(context);
                    },
                    child: const Text('Update'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              );
            });
        return "Tamam";
      } else {
        var kul = await _dbKullanici.kulcek();
        if (kul != null) {
          var kuljson = json.decode(kul.body);
          var kulliste = kuljson as List;

          for (var k in kulliste) {
            Kullanicilar kulyaz = Kullanicilar.fromMap(k);
            await _dbKullanici.insert(kulyaz);
          }
          setState(() {
            kulListe = kuljson;
          });
        } else {
          showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: Text("Failed to Retrieve Data"),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Okey'),
                    ),
                  ],
                );
              });
        }
        return "Tamam";
      }
    } catch (err) {
      showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text("Failed to Retrieve Data" + err.toString()),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Okey'),
                ),
              ],
            );
          });
      return err.toString();
    }
  }
}
