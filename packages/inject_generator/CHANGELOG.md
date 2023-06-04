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
