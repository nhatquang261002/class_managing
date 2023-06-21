import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_work_grading_web_based/pages/login_page.dart';
import 'package:study_work_grading_web_based/pages/register_page.dart';
import 'package:study_work_grading_web_based/services/auth_service.dart';

import '../pages/home_page.dart';
import 'widgets/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: MaterialApp(
        theme: ThemeData(
            useMaterial3: true,
            primaryColor: const Color.fromARGB(192, 235, 83, 72),
            iconTheme: const IconThemeData(color: Colors.white)),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => HomePage(
                selectedWidget: 0,
              ),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
        },
      ),
    );
  }
}
