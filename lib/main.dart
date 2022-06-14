import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:karakaya_soguk/static/global.dart';
import 'package:karakaya_soguk/ui/aktarim.dart';
import 'package:karakaya_soguk/ui/ayarlar.dart';
import 'package:karakaya_soguk/ui/exit.dart';
import 'package:karakaya_soguk/ui/login.dart';
import 'package:karakaya_soguk/ui/mesajlar.dart';
import 'package:karakaya_soguk/ui/mesajyaz.dart';
import 'package:karakaya_soguk/ui/siparisler.dart';
import 'package:karakaya_soguk/ui/tahsilatlar.dart';
import 'package:karakaya_soguk/ui/yenisiparis.dart';
import 'package:karakaya_soguk/ui/yenitahsilat.dart';

String _defaultHome = "";
int mesajj = 0;
void main() async {
  if (Global.kuladi != "") {
    _defaultHome = "/siparisler";
  } else {
    _defaultHome = "/login";
  }

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(new MaterialApp(
    theme: ThemeData(fontFamily: Global.font),
    debugShowCheckedModeBanner: false,
    initialRoute: _defaultHome,
    routes: {
      "/siparisler": (context) => Siparisler(),
      "/yenisiparis": (context) => Yenisiparis(),
      "/yenitahsilat": (context) => Yenitahsilat(""),
      "/tahsilatlar": (context) => Tahsilatlar(),
      // "/tahsilatduzenle": (context) => Tahsilatduzenle(),
      // "/siparisduzenle": (context) => Siparisduzenle(String sipno),
      "/ayarlar": (context) => Ayarlar(),
      "/aktarim": (context) => Aktarim(),
      "/mesajyaz":(context)=>MesajYaz(),
      "/exit": (context) => Cikis(),
      '/login': (context) => new LoginPage(),
    },
  ));
}
