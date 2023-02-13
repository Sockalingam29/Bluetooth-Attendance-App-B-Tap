import 'package:att_blue/pages/home_page.dart';
import 'package:att_blue/pages/login_page.dart';
import 'package:att_blue/pages/staff_home.dart';
import 'package:att_blue/pages/student_home.dart';
import 'package:att_blue/pages/register_page.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/register',
      // home: user != null ? Register() : Login(),
      routes: {
        '/': (context) => user != null ? const HomePage() : const Login(),
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),
        '/studentHome': (context) =>
            user != null ? const StudentHomePage() : const Login(),
        '/staffHome': (context) =>
            user != null ? const StaffHomePage() : const Login(),
      },
      // home: const Register(), //const WidgetTree(),
    );
  }
}
