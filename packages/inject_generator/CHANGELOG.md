## 1.0.0-alpha.7

- improve code generator 

  skip Dart files which don't import `package:inject_annotation`

## 1.0.0-alpha.6

- Improve LookupKey.fromDartType to support more DartTypes
- fix melos scripts

## 1.0.0-alpha.5

- update to Dart 3.6.0
- update dependencies

## 1.0.0-alpha.4

- update to Dart 3
- use late final or const in generated code where possible

## 1.0.0-alpha.3

- Add support for injecting methods
  ```dart
  void main() {
    final mainComponent = g.MainComponent$Component.create();
    final add = mainComponent.add;
    final sum = add(1, 2);
    print(sum);
  }
  
  @Component([MainModule])
  abstract class MainComponent {
    static const create = g.MainComponent$Component.create;
  
    Addition get add;
  }
  
  typedef Addition = int Function(int a, int b);
  
  @module
  class MainModule {
    @provides
    Addition provideAddition() => _add;
  }
  
  int _add(int a, int b) => a + b;
  ```

## 1.0.0-alpha.2

- Fix injection of generic types
- Update sdk constraints

## 1.0.0-alpha.1

- Initial release
