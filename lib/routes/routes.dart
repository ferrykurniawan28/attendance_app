import 'package:attendance/ui/pages/pages.dart';
import 'package:flutter_modular/flutter_modular.dart';

part 'auth.dart';

class AppRoute extends Module {
  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const Splash());
    r.child('/home', child: (_) => const HomePage());
    r.module('/auth', module: AuthRoute());
  }
}
