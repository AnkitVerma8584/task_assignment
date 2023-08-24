import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

double getHeight(context) => MediaQuery.of(context).size.height;

String getAppLogo(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? "assets/logo/logo_white.png"
        : "assets/logo/logo_black.webp";

void printLog(String data) => log("APP: $data");

String getTimeStampExtention() {
  DateTime time = DateTime.now();
  return time.millisecondsSinceEpoch.abs().toString();
}

Future<String?> getThumbnail(String path) async {
  final tempPath = (await getTemporaryDirectory()).path;
  printLog(tempPath);
  final fileName = await VideoThumbnail.thumbnailFile(
      video: path, thumbnailPath: tempPath, maxHeight: 100);
  printLog(fileName ?? path);
  return fileName;
}
