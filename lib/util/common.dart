import 'dart:developer';

import 'package:flutter/material.dart';

double getHeight(context) => MediaQuery.of(context).size.height;

String getAppLogo(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? "assets/logo/logo_white.png"
        : "assets/logo/logo_black.webp";

void printLog(String data) => log("APP: $data");

int getTimeStamp() {
  DateTime time = DateTime.now();
  return time.millisecondsSinceEpoch;
}
