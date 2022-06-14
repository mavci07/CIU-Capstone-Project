import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:karakaya_soguk/db/dbcariler.dart';
import 'package:karakaya_soguk/db/dbislem.dart';
import 'package:karakaya_soguk/db/dbstokhareket.dart';
import 'package:karakaya_soguk/db/dbcarihareket.dart';
import 'package:karakaya_soguk/db/dbstoklar.dart';
import 'package:karakaya_soguk/model/carimodel.dart';
import 'package:karakaya_soguk/model/chmodel.dart';
import 'package:karakaya_soguk/model/shmodel.dart';
import 'package:karakaya_soguk/model/stokmodel.dart';
import 'package:karakaya_soguk/static/global.dart';
import 'package:karakaya_soguk/ui/anamenu.dart';
import 'package:karakaya_soguk/ui/anasayfa.dart';
import 'package:karakaya_soguk/ui/siparisduzenle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Siparisler extends StatefulWidget {
  @override
  _ListViewNoteState createState() => new _ListViewNoteState();
}

class _ListViewNoteState extends State<Siparisler> {
  MainMenu mm = new MainMenu();
  var cmara = TextEditingController();
  List<StokHmodel> stokhareket = new List();
  List<StokHmodel> bul = new List();
  DbCariler dbc = new DbCariler();
  DBKullanici _dbKullanici = new DBKullanici();
  DbStokhareket dbsh = new DbStokhareket();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _statikler();
    //_zaman();
    tablokontrol().whenComplete(() => listeal());
    // db.cariliste().then((notes) {
    //   setState(() {
    //     notes.forEach((note) {
    //       items.add(Carimodel.fromMap(note));
    //       bul.add(Carimodel.fromMap(note));
    //     });
    //   });
    // });
    Global.mavi = Colors.pink;
    // listeal();
  }

  Future<void> tablokontrol() async {
    await dbc.initializeDatabase();
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

  _zaman() async {
    const oneSec = const Duration(seconds: 15);
    new Timer.periodic(oneSec, (Timer t) async {
      mesajgetir();
      // await mesajgetir();
    });
  }

  void mesajgetir() async {
    try {
      print("geldi");
      var gelen = await http.get('http://' +
          Global.sunucu +
          '/home/mesajgetir?gelen=' +
          Global.kuladi);

      if (gelen.statusCode == 200) {
        var gonder = json.decode(gelen.body);
        if (gonder.length > 0) {
          String icerik = "";
          String msid = "";
          for (var word in gonder) {
            String tarih = DateFormat("dd-MM-yyyy HH:mm:ss")
                .format(DateTime.parse(word["Tarih"]));
            msid = word["id"].toString();
            icerik = icerik + '\n' + tarih + '\n   ' + word['Mesaj'].toString();
          }
          if (!Global.acik) _mesajGoster(icerik, msid);
        }
      }
    } catch (err) {
      print(err);
    }
  }

  Future<bool> _mesajGoster(var gelen, String msid) async {
    setState(() {
      Global.acik = true;
    });
    Text mesajid = Text(msid);
    return (await showDialog(
            context: context,
            builder: (context) {
              return WillPopScope(
                onWillPop: () async => false,
                child: new AlertDialog(
                  title: Row(children: [
                    Icon(
                      Icons.circle_notifications,
                      color: Colors.red,
                    ),
                    new Text('New Notification ',
                        style: TextStyle(fontSize: 20, color: Colors.red)),
                  ]),
                  content: Container(
                      //height: 200,
                      // width: 350,
                      child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                          gelen,
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  )),
                  actions: <Widget>[
                    mesajid,
                    new FlatButton(
                      onPressed: () {
                        _dbKullanici.okundu(mesajid.data);
                        setState(() {
                          Global.acik = false;
                        });

                        Navigator.of(context).pop(false);
                      },
                      child: new Text('Read', style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              );
            })) ??
        false;
  }

  Future<void> listeal() async {
    var gelen = await dbsh.shlistecari(Global.kuladi);
    bul.clear();
    stokhareket.clear();
    if (gelen != null)
      setState(() {
        gelen.forEach((note) {
          stokhareket.add(StokHmodel.fromMap(note));
          bul.add(StokHmodel.fromMap(note));
        });
      });
  }

  onItemChanged(String value) {
    setState(() {
      bul = stokhareket
          .where((string) =>
              string.sipno.toLowerCase().contains(value.toLowerCase()) ||
              string.carikod.toLowerCase().contains(value.toLowerCase()))
          .toList();
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
              centerTitle: true,
              title: Text("Orders"),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, "/yenisiparis");
                  },
                )
              ],
            ),
            drawer: MyDrawer(),
            body: new Column(children: <Widget>[
              new TextFormField(
                controller: cmara,
                decoration: InputDecoration(
                    hintText: 'Enter Current Code or Title',
                    prefixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          cmara.clear();
                        });
                      },
                      icon: Icon(
                        Icons.clear,
                        size: 25,
                        color: Colors.blue[400],
                      ),
                    )),
                onChanged: onItemChanged,
              ),
              new Expanded(
                child: RefreshIndicator(
                  strokeWidth: 3,
                  backgroundColor: Colors.blue[900],
                  color: Colors.white,
                  key: _refreshIndicatorKey,
                  onRefresh: () => listeal(),
                  child: ListView.builder(
                      itemCount: bul.length,
                      padding: EdgeInsets.symmetric(vertical: .5),
                      itemBuilder: (context, position) {
                        return Container(
                          color: Colors.blueGrey[50],
                          child: Column(
                            children: <Widget>[
                              Divider(
                                height: 1,
                              ),
                              ListTile(
                                title: Text(
                                  '${bul[position].carikod}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.pink,
                                    //fontStyle: FontStyle.italic,
                                  ),
                                ),
                                // subtitle: Text(
                                //   '${bul[position].cariunvan}',
                                //   style: new TextStyle(
                                //       fontSize: 15.0, color: Colors.blue[900]),
                                // ),
                                leading: Column(
                                  children: <Widget>[
                                    Padding(padding: EdgeInsets.all(8.0)),
                                    Text(
                                      '${bul[position].tarih.substring(8, 10)}/${bul[position].tarih.substring(5, 7)}/${bul[position].tarih.substring(0, 4)} ',
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // Global.duzenlesipno =
                                  //    '${bul[position].sipno}';
                                  // Navigator.pushNamed(context, "/siparisduzenle");
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => Siparisduzenle(
                                          '${bul[position].sipno}')));
                                },
                                onLongPress: () {
                                  showDialog<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Unregister !'),
                                        content:
                                            Text('Delete Selected Order??'),
                                        actions: <Widget>[
                                          FlatButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          FlatButton(
                                              onPressed: () {
                                                siparissil(bul[position].sipno)
                                                    .then((value) {
                                                  if (value > 0)
                                                    setState(() {
                                                      bul.removeAt(bul.indexOf(
                                                          bul[position]));
                                                    });
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: Text("delete"))
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                ),
              )
            ])));
  }
}

Future<int> siparissil(String sipno) async {
  DbStokhareket db = new DbStokhareket();
  var durum = await db.siparissil(sipno);
  return durum;
}
