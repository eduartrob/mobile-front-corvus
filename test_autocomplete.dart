import 'package:flutter/material.dart';
void main() {
  Autocomplete<String>(
    optionsBuilder: (text) => [],
    optionsViewOpenDirection: OptionsViewOpenDirection.up,
  );
}
