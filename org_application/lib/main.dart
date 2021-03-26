import 'package:flutter/material.dart';
import 'color.dart';
import 'startPage.dart';
// icon source: https://feathericons.com/

LightThemeColors colors = LightThemeColors();
Color logoColor = colors.getLogoColor();

void main() {
  runApp(new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(color: logoColor),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return StartPage();
  }
}
