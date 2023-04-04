// ignore_for_file: unused_import
import 'package:att_blue/pages/student_list.dart';
import 'package:att_blue/pages/login_page.dart';
import 'package:att_blue/pages/staff_home.dart';
import 'package:att_blue/pages/student_home.dart';
import 'package:att_blue/pages/register_page.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? user = FirebaseAuth.instance.currentUser;
  bool isStudent = true;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      isStudent = user!.email!.endsWith('student.tce.edu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: '/',
      // home: user != null ? Register() : Login(),
      routes: {
        '/': (context) => user != null
            ? (isStudent ? const StudentHomePage() : const StaffHomePage())
            : const Login(),
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),
        '/studentHome': (context) => const StudentHomePage(),
        // user != null ? const StudentHomePage() : const Login(),
        '/staffHome': (context) => const StaffHomePage(),
        // user != null ? const StaffHomePage() : const Login(),
        '/studentList': (context) => const StudentList()
        // user != null ? const StudentList() : const Login(),
      },
    );
  }
}
