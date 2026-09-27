import 'dart:html' as html;
import 'package:flutter/services.dart';

Future<void> enterFullscreen() async {
  try {
    html.document.documentElement?.requestFullscreen();
  } on Exception catch (_) {
    // ignore unsupported browsers
  }
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

Future<void> exitFullscreen() async {
  try {
    html.document.exitFullscreen();
  } on Exception catch (_) {
    // ignore unsupported browsers
  }
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}
