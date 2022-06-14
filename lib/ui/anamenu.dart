import 'package:flutter/material.dart';
import 'package:karakaya_soguk/db/dbcariler.dart';
import 'package:karakaya_soguk/model/model_item.dart';
import 'package:karakaya_soguk/static/global.dart';
import 'package:karakaya_soguk/ui/mesajyaz.dart';
import 'package:karakaya_soguk/ui/siparisler.dart';
import 'package:karakaya_soguk/ui/tahsilatlar.dart';
import 'package:karakaya_soguk/ui/yenisiparis.dart';
import 'package:karakaya_soguk/ui/exit.dart';
import 'package:karakaya_soguk/ui/aktarim.dart';
import 'package:flutter/services.dart';
import 'package:karakaya_soguk/ui/yenitahsilat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ayarlar.dart';
import 'mesajlar.dart';

class MainMenu extends StatefulWidget {
  @override
  MainMenuState createState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MainMenuState();
  }
}

class MainMenuState extends State<MainMenu> {
  Widget _appBarTitle;
  Color _appBarBackgroundColor;
  MenuItem _selectedMenuItem;
  List<MenuItem> _menuItems;
  List<Widget> _menuOptionWidgets = [];
  DbCariler db = new DbCariler();
  @override
  initState() {
    super.initState();
    _statikler();
    _menuItems = createMenuItems();
    _selectedMenuItem = _menuItems.first;
    _appBarTitle = new Text(
      _menuItems.first.title,
      style: TextStyle(
        fontWeight: FontWeight.w400,
      ),
    );
    _appBarBackgroundColor = Colors.blue[900];
    //tablokontrol();
  }

  // Future<void> tablokontrol() async {
  //   await db.initializeDatabase();
  // }

  _statikler() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      Global.sunucu = (prefs.getString('sunucu') ?? "");
      Global.sqlsa = (prefs.getString('sqlsa') ?? "");
      Global.sqlpass = (prefs.getString('sqlpass') ?? "");
      Global.sirket = (prefs.getString('sirket') ?? "");
    });
  }

  _getMenuItemWidget(MenuItem menuItem) {
    return menuItem.func();
  }

  _onSelectItem(MenuItem menuItem) {
    setState(() {
      _selectedMenuItem = menuItem;
      _appBarTitle = new Text(
        menuItem.title,
        style: TextStyle(
          fontWeight: FontWeight.w400,
        ),
      );
      _appBarBackgroundColor = menuItem.color;
    });
    Navigator.of(context).pop(); // close side menu
  }

  @override
  Widget build(BuildContext context) {
    _menuOptionWidgets = [];

    for (var menuItem in _menuItems) {
      _menuOptionWidgets.add(new Container(
          decoration: new BoxDecoration(
              color: menuItem == _selectedMenuItem
                  ? Colors.grey[200]
                  : Colors.white),
          child: new ListTile(
              leading: menuItem.icon,
              onTap: () => _onSelectItem(menuItem),
              title: Text(
                menuItem.title,
                style: new TextStyle(
                    fontSize: 20.0,
                    color: menuItem.color,
                    fontWeight: menuItem == _selectedMenuItem
                        ? FontWeight.w500
                        : FontWeight.w300),
              ))));

      _menuOptionWidgets.add(
        new SizedBox(
          child: new Center(
            child: new Container(
              margin: new EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
              height: 0.3,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return new Scaffold(
      appBar: new AppBar(
        title: _appBarTitle,
        backgroundColor: _appBarBackgroundColor,
        centerTitle: true,
      ),
      drawer: new Drawer(
        child: new ListView(
          children: <Widget>[
            new Container(
                child: new ListTile(
                    leading: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ), // new Image.asset('assets/images/cover.png'),
                    title: Text(
                      "CIU",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w300),
                    )),
                margin: new EdgeInsetsDirectional.only(top: 0.0),
                color: Colors.blue[800],
                constraints: BoxConstraints(maxHeight: 70.0, minHeight: 70.0)),
            new SizedBox(
              child: new Center(
                child: new Container(
                  margin: new EdgeInsetsDirectional.only(start: 0.0, end: 0.0),
                  height: 3,
                  color: Colors.green,
                ),
              ),
            ),
            new Container(
              color: Colors.white,
              child: new Column(children: _menuOptionWidgets),
            ),
          ],
        ),
      ),
      body: _getMenuItemWidget(_selectedMenuItem),
    );
  }

  List<MenuItem> createMenuItems() {
    final menuItems = [
      new MenuItem(
          "Orders",
          Icon(
            Icons.note_add,
            color: Colors.blue[400],
          ),
          Colors.blue,
          () => Siparisler()),
      new MenuItem(
          "New order",
          Icon(
            Icons.border_color,
            color: Colors.blue[400],
          ),
          Colors.blue,
          () => (context) => Yenisiparis()),
      new MenuItem(
          "Collections",
          Icon(
            Icons.attach_money,
            color: Colors.blue[400],
          ),
          Colors.blue,
          () => Tahsilatlar()),
      new MenuItem(
          "New Collection",
          Icon(
            Icons.border_color,
            color: Colors.blue[400],
          ),
          Colors.blue,
          () => Yenitahsilat("")),
      new MenuItem(
          "Transfer",
          Icon(
            Icons.settings,
            color: Colors.blue[400],
          ),
          Colors.blue,
          () => Aktarim()),
      new MenuItem(
          "Settings",
          Icon(
            Icons.settings,
            color: Colors.blue[400],
          ),
          Colors.blue,
          () => Ayarlar()),
      new MenuItem(
          "Messages",
          Icon(
            Icons.settings,
            color: Colors.blue[400],
          ),
          Colors.blue,
          () => MesajYaz()),
      new MenuItem(
          "Exit",
          Icon(
            Icons.logout,
            color: Colors.blue[400],
          ),
          Colors.blue,
          () => Cikis()),
    ];
    return menuItems;
  }
}
