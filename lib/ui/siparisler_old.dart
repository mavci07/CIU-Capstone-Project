import 'package:flutter/material.dart';
import 'dart:io';

class Siparisler extends StatelessWidget {
  final appTitle = 'Siparişler';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Siparişler')),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: new Color(0xFF0062ac),
              ),
              accountName: Text("Muhammet ÖZER"),
              accountEmail: Text("0544 727 27 57"),
              currentAccountPicture: CircleAvatar(
                backgroundColor:
                    Theme.of(context).platform == TargetPlatform.iOS
                        ? new Color(0xFF0062ac)
                        : Colors.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.note_add),
              title: Text('Siparişler'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.border_color),
              title: Text('Yeni Sipariş'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Çıkış'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('ÇIKIŞ'),
                      content: Text("Program Kapatılsın mı ?"),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("Çıkış"),
                          onPressed: () {
                            //Put your code here which you want to execute on Yes button click.
                            exit(0);
                          },
                        ),
                        FlatButton(
                          child: Text("İptal"),
                          onPressed: () {
                            //Put your code here which you want to execute on No button click.
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
