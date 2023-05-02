# Compile-time Dependency Injection for Dart and Flutter

Compile-time dependency injection is a technique for managing the dependencies of an application at compile-time rather
than at runtime. This provides several benefits, including improved performance, reduced code size, and better
compile-time error checking. In Dart and Flutter, compile-time dependency injection is implemented using the `@inject`
and `@provides` annotations, along with the `Component` and `Module` classes.

## Getting Started

### Adding the Dependency

To use this library in your Dart or Flutter project, you need to add it as a dependency in your `pubspec.yaml` file:

```shell
// dart
$ dart pub add inject_annotation
$ dart pub add inject_generator build_runner --dev

// flutter
$ flutter pub add inject_annotation
$ flutter pub add inject_generator build_runner --dev
```

### Generating the Code

To generate the code, you need to run the build runner:

```shell
// dart
$ dart run build_runner build

// flutter
$ flutter pub run build_runner build
```

### The `Component`

To use compile-time dependency injection in your Dart or Flutter application, you need to create a `Component` class.
This is an abstract class annotated with `@component` or `@Component([])` if you also have modules.

Inside the `Component`, you can define methods that return instances of the classes you need (
e.g., `Repository get repository` in the example below).

```dart
@component
abstract class MainComponent {
  static const create = g.MainComponent$Component.create;

  @inject
  Repository get repository;
}
```

### `@inject`ing Types

To add a type to the dependency graph, you annotate its class with `@inject`. For example:

```dart
@inject
class Repository {
  const Repository(this.apiClient);

  final FakeApiClient apiClient;

  Future<String> getGreeting({required String name}) => apiClient.getGreeting(name: name);
}
```

Note that you cannot add the `@inject` annotation to classes from 3rd party libraries.

### Modules

Modules are classes annotated with `@module`. There, you can define dependencies with the `@provides` annotation.

Methods annotated with `@provides` tell how to provide an instance of a class. Function parameters are the dependencies
of this type.

```dart
@module
class ApiModule {
  @provides
  @singleton
  FakeApiClient apiClient() => FakeApiClient();
}
```

You can then include the module in your `Component`:

```dart
@component([ApiModule])
abstract class MainComponent {
  static const create = g.MainComponent$Component.create;

  @inject
  Repository get repository;
}
```

### `@singleton`

The `@singleton` annotation is used to indicate that only one instance of the provided type should be created and shared
across the application. This can help improve performance and reduce memory usage by avoiding unnecessary object
creation.

To use `@singleton`, simply add it as an annotation to the method that provides the instance:

```dart
@module
class ApiModule {
  @provides
  @singleton
  FakeApiClient apiClient() => FakeApiClient();
}
```

## FAQ

### What do you mean by compile-time?

All dependency injection is analyzed, configured, and generated at compile-time
as part of a build process, and does not rely on any runtime setup or
configuration (such as reflection with `dart:mirrors`). This provides the best
experience in terms of code-size and performance (it's nearly identical to hand
written code) and allows us to provide compile-time errors and warnings instead
of relying on runtime.
