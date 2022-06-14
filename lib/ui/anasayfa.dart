import 'package:flutter/material.dart';
import 'package:karakaya_soguk/static/global.dart';
import 'package:flutter_launcher_icons/android.dart';
import 'package:flutter_launcher_icons/constants.dart';
import 'package:flutter_launcher_icons/custom_exceptions.dart';
import 'package:flutter_launcher_icons/ios.dart';
import 'package:flutter_launcher_icons/main.dart';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';

class MyDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyDrawerState();
}

class _MyDrawerState extends State {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Drawer(
          child: ListView(
            children: <Widget>[
              Container(
                height: 120,
                child: DrawerHeader(
                  child: Align(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        Text(
                          Global.name,
                          style: TextStyle(color: Colors.white, fontSize: 15.0),
                        ),
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.note_add),
                title: Text('Orders'),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.pushNamed(context, "/siparisler");
                },
              ),
              const Divider(
                color: Colors.grey,
                height: 1,
                // thickness: 5,
                indent: 5,
                endIndent: 5,
              ),
              ListTile(
                leading: Icon(Icons.border_color),
                title: Text('New order'),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.pushNamed(context, "/yenisiparis");
                },
              ),
              const Divider(
                color: Colors.grey,
                height: 1,
                // thickness: 5,
                indent: 5,
                endIndent: 5,
              ),
              ListTile(
                leading: Icon(Icons.attach_money),
                title: Text('Collections'),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.pushNamed(context, "/tahsilatlar");
                },
              ),
              const Divider(
                color: Colors.grey,
                height: 1,
                // thickness: 5,
                indent: 5,
                endIndent: 5,
              ),
              ListTile(
                leading: Icon(Icons.border_color),
                title: Text('New Collection'),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.pushNamed(context, "/yenitahsilat");
                },
              ),
              const Divider(
                color: Colors.grey,
                height: 1,
                // thickness: 5,
                indent: 5,
                endIndent: 5,
              ),
              ListTile(
                leading: Icon(Icons.cached),
                title: Text('Transfer'),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.pushNamed(context, "/aktarim");
                },
              ),
              const Divider(
                color: Colors.grey,
                height: 1,
                // thickness: 5,
                indent: 5,
                endIndent: 5,
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.pushNamed(context, "/ayarlar");
                },
              ),
              const Divider(
                color: Colors.grey,
                height: 1,
                // thickness: 5,
                indent: 5,
                endIndent: 5,
              ),
              ListTile(
                leading: Icon(Icons.message),
                title: Text('Messages'),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.pushNamed(context, "/mesajyaz");
                },
              ),
              const Divider(
                color: Colors.grey,
                height: 1,
                // thickness: 5,
                indent: 5,
                endIndent: 5,
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Exit'),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.pushNamed(context, "/exit");
                },
              ),
              const Divider(
                color: Colors.grey,
                height: 1,
                // thickness: 5,
                indent: 5,
                endIndent: 5,
              ),
            ],
          ),
        ));
  }
}
