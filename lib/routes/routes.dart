import 'package:attendance/models/models.dart';
import 'package:attendance/ui/pages/pages.dart';
import 'package:flutter_modular/flutter_modular.dart';

part 'auth.dart';

class AppRoute extends Module {
  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const Splash());
    r.child('/home', child: (_) => const HomePage());
    r.child('/attendance-history', child: (_) => const AttendnceHistory());
    r.child(
      '/attendance-detail',
      child:
          (context) => AttendanceDetail(attendance: r.args.data as Attendance),
    );
    r.module('/auth', module: AuthRoute());
  }
}
