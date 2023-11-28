import 'package:inject_annotation/inject_annotation.dart';

import 'main.inject.dart' as g;

Future<void> main() async {
  /// Create an instance of the [MainComponent] to access the dependency graph.
  final mainComponent = g.MainComponent$Component.create();

  /// Use the repository to get a greeting for "World".
  print(mainComponent.repository.getGreeting(name: 'World'));
}

/// The entry point for accessing the dependency graph.
/// [Component]s declare properties that return an instance of the desired type.
@Component([ApiModule])
abstract class MainComponent {
  /// A factory method to create a new instance of [MainComponent].
  static const create = g.MainComponent$Component.create;

  /// Returns an instance of [Repository] to be used by other classes.
  @inject
  Repository get repository;
}

/// The [Repository] depends on an instance of [FakeApiClient].
/// Its dependencies are injected via constructor injection.
@inject
class Repository {
  /// Creates a new instance of [Repository] with the given [apiClient].
  const Repository(this.apiClient);

  /// The instance of [FakeApiClient] used by this class.
  final FakeApiClient apiClient;

  /// Returns a [Future] containing a greeting message for the given name.
  Future<String> getGreeting({required String name}) => apiClient.getGreeting(name: name);
}

/// A [module] declares how to get an instance of a particular type.
/// Modules are necessary for 3rd party libraries where the [inject] annotation cannot be used.
@module
class ApiModule {
  /// Returns a new instance of [FakeApiClient] to be injected into other classes.
  @provides
  @singleton
  FakeApiClient apiClient() => FakeApiClient();
}

/// A fake API client that returns a greeting message for a given name.
/// In a real implementation, this would typically be a client from a library like Chopper.
class FakeApiClient {
  /// Returns a [Future] containing a greeting message for the given name.
  Future<String> getGreeting({required String name}) => Future.value('Hello $name!');
}
