import 'package:cores/cores.dart';

import '../../network.dart';

class NetworkInitializer extends DiInitializer {
  NetworkInitializer() : super(_init);

  static Future<void> _init(GetIt getIt, String? environment) async {
    getIt.registerLazySingleton<Dio>(() => Dio(
          BaseOptions(
            baseUrl: 'https://jsonplaceholder.typicode.com',
          ),
        ));
    getIt.registerSingleton<HttpService>(
      DioServiceImpl(dio: getIt<Dio>()),
    );
  }
}
