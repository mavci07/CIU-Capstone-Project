import 'package:flutter/material.dart';
import 'package:karakaya_soguk/static/global.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'anasayfa.dart';

class Ayarlar extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<Ayarlar> {
  final _formKey = GlobalKey<FormState>();
  var _sunucu = TextEditingController();
  var _sqlsa = TextEditingController();
  var _sqlpass = TextEditingController();
  var _sirket = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _sunucu.text = Global.sunucu;
    _sqlsa.text = Global.sqlsa;
    _sqlpass.text = Global.sqlpass;
    _sirket.text = Global.sirket;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[900],
          centerTitle: true,
          title: Text("Settings"),
          automaticallyImplyLeading: Global.kuladi.isEmpty ? false : true,
        ),
        drawer: MyDrawer(),
        body: Container(
            child: Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10),
                      TextField(
                        controller: _sunucu,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20.0, 0, 0, 0),
                          // hintText: "Sunucu IP ve SQL Instance",
                          labelText: 'Server',
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _sqlsa,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20.0, 0, 0, 0),
                          //hintText: "SQL Kullanıcı Adı",
                          labelText: 'SQL User',
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        obscureText: true,
                        controller: _sqlpass,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20.0, 0, 0, 0),
                          //hintText: "SQL Şifre",
                          labelText: 'SQL Password',
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _sirket,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(20.0, 0, 0, 0),
                          //hintText: "Şirket",
                          labelText: 'Company',
                        ),
                      ),
                      SizedBox(height: 10),
                      MaterialButton(
                        height: 50,
                        onPressed: () {
                          _kaydet();
                        },
                        textColor: Colors.white,
                        color: Colors.blue[900],
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Save',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                    ]))));
  }

  _kaydet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // _counter = (prefs.getInt('counter') ?? 0) + 1;
      prefs.setString('sunucu', _sunucu.text);
      prefs.setString('sqlsa', _sqlsa.text);
      prefs.setString('sqlpass', _sqlpass.text);
      prefs.setString('sirket', _sirket.text);
      Global.sunucu = _sunucu.text;
      Global.sqlsa = _sqlsa.text;
      Global.sqlpass = _sqlpass.text;
      Global.sirket = _sirket.text;
    });
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save'),
          content: Text('Registration Complete'),
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
