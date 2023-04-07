import 'package:flutter/material.dart';
import 'package:inject_annotation/inject.dart';

import 'main.inject.dart' as g;
import 'src/app.dart';
import 'src/settings/settings_controller.dart';

void main() async {
  final mainComponent = g.MainComponent$Component.create();
  final myApp = await mainComponent.myAppFactory.create();
  runApp(myApp);
}

@Component([SettingsModule])
abstract class MainComponent {
  static const create = g.MainComponent$Component.create;

  @inject
  MyAppFactory get myAppFactory;
}
