// import 'package:inject_annotation/inject.dart';
// import 'package:test/test.dart';
//
// // ignore: uri_does_not_exist
// import 'providers_injector_test.inject.dart' as g;
//
// /// Qualifier for a manually written [CounterFactory] for the purpose of testing
// /// getting a [Provider] in a module provide method.
// const Qualifier manual = Qualifier(#manual);
//
// /// A custom typedef for providing a type.
// typedef Provider<T> = T Function();
//
// /// Injector whose purpose is to test binding providers.
// @Component([CounterModule])
// abstract class ProvidersInjector {
//   static final create = g.ProvidersInjector$Injector.create;
//
//   /// Returns a [CounterFactory].
//   ///
//   /// Tests injecting a [Provider] in a class.
//   @inject
//   CounterFactory get counterFactory;
//
//   /// Returns a [Provider] of [Counter].
//   ///
//   /// Tests getting a [Provider] from an injector.
//   @inject
//   Provider<Counter> get counter;
//
//   /// Returns a [CounterFactory].
//   ///
//   /// Tests getting a [Provider] from a module provider method.
//   @inject
//   @manual
//   CounterFactory get manualCounterFactory;
// }
//
// @module
// class CounterModule {
//   @inject
//   @manual
//   CounterFactory provideCounterProvider(Counter Function() counter) =>
//       CounterFactory(counter);
// }
//
// @inject
// class CounterFactory {
//   Provider<Counter> counter;
//
//   CounterFactory(this.counter);
//
//   Counter create() => counter();
// }
//
// /// A simple stateful class for the purpose of testing [Provider]s.
// @inject
// class Counter {
//   int value = 0;
//
//   void increment() => value++;
// }
//
// // Tests for providers.
// void main() {
//   group(
//     ProvidersInjector,
//     () {
//       ProvidersInjector? injector;
//
//       setUp(() async {
//         injector = await ProvidersInjector.create(CounterModule());
//       });
//
//       test('provider from injector', () async {
//         final counter1 = injector!.counter();
//         final counter2 = injector!.counter();
//         counter1.increment();
//
//         expect(counter1.value, 1);
//         expect(counter2.value, 0);
//       });
//
//       test('provider injected in class', () async {
//         final counterFactory = injector!.counterFactory;
//         final counter1 = counterFactory.create();
//         final counter2 = counterFactory.create();
//         counter1.increment();
//
//         expect(counter1.value, 1);
//         expect(counter2.value, 0);
//       });
//
//       test('provider in module method', () async {
//         final counterFactory = injector!.counterFactory;
//         final counter1 = counterFactory.create();
//         final counter2 = counterFactory.create();
//         counter1.increment();
//
//         expect(counter1.value, 1);
//         expect(counter2.value, 0);
//       });
//     },
//     skip: 'Currently not working with the external build system',
//   );
// }

void main() {
  // empty test as long as the above isn't fixed
}
