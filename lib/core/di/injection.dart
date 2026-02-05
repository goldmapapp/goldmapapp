import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

// Uncomment after running: dart run build_runner build --delete-conflicting-outputs
// import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  preferRelativeImports: true,
)
Future<void> configureDependencies() async {
  // Uncomment after running build_runner
  // await getIt.init();
}
