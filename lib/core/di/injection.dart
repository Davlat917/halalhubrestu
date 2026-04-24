import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';
import 'package:halalhub_restaurant/core/di/injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  await getIt.init();
}
