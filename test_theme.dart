import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  const p = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    }
  );
}
