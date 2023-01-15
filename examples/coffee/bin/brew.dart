// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:inject_example_coffee/coffee_app.dart';

/// An example application that simulates running the `Coffee` application.
Future<void> main() async {
  final coffee = Coffee.create();
  (await coffee.getCoffeeMaker()).brew();
}
