part of 'routes.dart';

class AuthRoute extends Module {
  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const LoginPage());
  }
}
