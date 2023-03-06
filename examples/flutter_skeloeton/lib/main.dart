import 'package:flutter/material.dart';
import 'package:inject/inject.dart';

import 'main.inject.dart' as g;
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  // final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  // await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.

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
