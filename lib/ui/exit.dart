import 'package:flutter/material.dart';
import 'package:karakaya_soguk/static/global.dart';
import 'anasayfa.dart';

class Cikis extends StatefulWidget {
  @override
  Ccikis createState() {
    return Ccikis();
  }
}

class Ccikis extends State<Cikis> {
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.blue[900],
            title: Text("Exit")),
        drawer: MyDrawer(),
        body: Container(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text("Çıkış"),
              onPressed: () {
                setState(() {
                  Global.kuladi = "";
                  Global.pass = "";
                  Global.name = "";
                });
                Navigator.pushNamed(context, "/login");
              },
            ),
            SizedBox(width: 25),
            RaisedButton(
              child: Text("Cancel"),
              onPressed: () => {Navigator.pushNamed(context, "/siparisler")},
            ),
          ],
        )));
  }
}
