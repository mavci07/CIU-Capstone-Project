import 'package:flutter/material.dart';
import 'package:karakaya_soguk/db/dbcariler.dart';
import 'package:karakaya_soguk/db/dbcarihareket.dart';
import 'package:karakaya_soguk/model/carimodel.dart';
import 'package:karakaya_soguk/model/chmodel.dart';
import 'package:karakaya_soguk/static/global.dart';
import 'package:karakaya_soguk/ui/anamenu.dart';
import 'package:karakaya_soguk/ui/tahsilatduzenle.dart';
import 'anasayfa.dart';

class GenelToplam extends StatefulWidget {
  @override
  Toplamlar createState() => new Toplamlar();
}

class Toplamlar extends State<GenelToplam> {
  MainMenu mm = new MainMenu();
  List<Carimodel> items = new List();
  List<CariHmodel> carihareket = new List();
  List<CariHmodel> bul = new List();
  DbCariler db = new DbCariler();
  DbCarihareket dbch = new DbCarihareket();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    super.initState();

    // db.cariliste().then((notes) {
    //   setState(() {
    //     notes.forEach((note) {
    //       items.add(Carimodel.fromMap(note));
    //       bul.add(Carimodel.fromMap(note));
    //     });
    //   });
    // });
    Global.mavi = Colors.pink;
    db.cariliste().then((notes) {
      setState(() {
        notes.forEach((note) {
          items.add(Carimodel.fromMap(note));
        });
      });
    });
    dbch.chlistecari(Global.kuladi).then((notes) {
      setState(() {
        notes.forEach((note) {
          carihareket.add(CariHmodel.fromMap(note));
          bul.add(CariHmodel.fromMap(note));
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> listeal() async {
    dbch.chlistecari(Global.kuladi).then((notes) {
      bul.clear();
      carihareket.clear();
      setState(() {
        notes.forEach((note) {
          carihareket.add(CariHmodel.fromMap(note));
          bul.add(CariHmodel.fromMap(note));
        });
      });
    });
  }

  onItemChanged(String value) {
    setState(() {
      bul = carihareket
          .where((string) =>
              string.carikod.toLowerCase().contains(value.toLowerCase()) ||
              string.tahsno.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green[600],
          centerTitle: true,
          title: Text("Total Collections"),
          // actions: <Widget>[
          //   IconButton(
          //     icon: Icon(
          //       Icons.add,
          //       color: Colors.white,
          //     ),
          //     onPressed: () {
          //       Navigator.pushNamed(context, "/yenitahsilat");
          //     },
          //   )
          // ],
        ),
        //  drawer: MyDrawer(),
        body: new Column(children: <Widget>[
          new TextFormField(
            decoration:
                InputDecoration(hintText: 'Enter Collection Number or Title'),
            onChanged: onItemChanged,
          ),
          new Expanded(
            child: RefreshIndicator(
              strokeWidth: 3,
              backgroundColor: Colors.green[900],
              color: Colors.white,
              key: _refreshIndicatorKey,
              onRefresh: () => listeal(),
              child: ListView.builder(
                  itemCount: bul.length,
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
                              '${bul[position].carikod}',
                              style: TextStyle(
                                fontSize: 13.0,
                                color: Global.mavi,
                              ),
                            ),
                            subtitle: Text(
                              'Collection Number : ${bul[position].tahsno}',
                              style: new TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            leading: Column(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.all(8.0)),
                                SizedBox(
                                    width:
                                        70, // here put the desired space between the icon and the text
                                    child: Text(
                                      '${bul[position].tarih.substring(8, 10)}/${bul[position].tarih.substring(5, 7)}/${bul[position].tarih.substring(0, 4)} ',
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        color: Colors.black,
                                      ),
                                    )),
                              ],
                            ),
                            onTap: () {
                              // Global.duzenletahsno =
                              //     '${bul[position].tahsno}';
                              // Navigator.pushNamed(
                              //     context, "/tahsilatduzenle");
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => Tahsilatduzenle(
                                      '${bul[position].kayno}')));
                            },
                            onLongPress: () {
                              showDialog<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Unregister !'),
                                    content:
                                        Text('Delete Selected Collection?'),
                                    actions: <Widget>[
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      FlatButton(
                                          onPressed: () {
                                            tahsilatsil(bul[position].kayno)
                                                .then((value) {
                                              if (value > 0)
                                                setState(() {
                                                  bul.removeAt(bul
                                                      .indexOf(bul[position]));
                                                });
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Text("Delete"))
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
        ]
            // floatingActionButton: FloatingActionButton(
            //   child: Icon(Icons.add),
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => MainMenu()),
            //     );
            //   },
            // ),
            ));
  }
}

Future<int> tahsilatsil(String tahsno) async {
  DbCarihareket db = new DbCarihareket();
  var durum = await db.tahsilatsil(tahsno);
  return durum;
}
