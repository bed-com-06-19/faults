import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF004D40), // Dark Green
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    color: Color(0xFF004D40),
    elevation: 4,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(Colors.green),
    trackColor: WidgetStateProperty.all(Colors.greenAccent),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.black,
  scaffoldBackgroundColor: Colors.grey[900],
  appBarTheme: const AppBarTheme(
    color: Colors.black,
    elevation: 4,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(Colors.green),
    trackColor: WidgetStateProperty.all(Colors.greenAccent),
  ),
);
