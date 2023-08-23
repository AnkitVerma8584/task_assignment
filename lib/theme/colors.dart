import 'package:flutter/material.dart';

ColorScheme getColors(context) => Theme.of(context).colorScheme;

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF000000),
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color.fromARGB(255, 66, 66, 66),
  onSecondary: Color.fromARGB(255, 237, 237, 237),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  background: Color.fromARGB(255, 255, 245, 245),
  onBackground: Color.fromARGB(255, 0, 0, 0),
  surface: Color(0xFFFFFFFF),
  onSurface: Color.fromARGB(255, 0, 0, 0),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  onPrimary: Color(0xFF000000),
  primary: Color(0xFFFFFFFF),
  onSecondary: Color.fromARGB(255, 58, 58, 58),
  secondary: Color.fromARGB(255, 231, 231, 231),
  error: Color.fromARGB(255, 255, 120, 120),
  onError: Color(0xFFFFFFFF),
  onBackground: Color.fromARGB(255, 255, 245, 245),
  background: Color.fromARGB(255, 0, 0, 0),
  onSurface: Color(0xFFFFFFFF),
  surface: Color.fromARGB(255, 0, 0, 0),
);
