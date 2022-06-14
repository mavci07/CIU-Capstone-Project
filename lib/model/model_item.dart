import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuItem {
  String title;
  Icon icon;
  Color color;
  Function func;
  MenuItem(this.title, this.icon, this.color, this.func);
}
