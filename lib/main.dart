import 'package:attendance/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bquahlsixaokxfnqzbof.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJxdWFobHNpeGFva3hmbnF6Ym9mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxNjc2MTQsImV4cCI6MjA1OTc0MzYxNH0.gI2CRyCHmXbAY_a5InA95puIssq_1KjZDPK6L35FIZg',
  );
  runApp(ModularApp(module: AppRoute(), child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    Modular.setInitialRoute('/');
    return MaterialApp.router(
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
      debugShowCheckedModeBanner: false,
    );
  }
}
