
import 'package:flutter/material.dart';
import 'package:att_blue/components/rippleEffect/splash_screen.dart';


class StudentHome2 extends StatelessWidget {
  const StudentHome2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
     theme: ThemeData.dark(),

      home: const Splash(),
    );
  }
}







