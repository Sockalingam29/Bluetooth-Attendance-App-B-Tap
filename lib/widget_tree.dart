
import 'package:flutter/material.dart';

import 'package:att_blue/auth.dart';
import 'package:att_blue/pages/home_page.dart';
import 'package:att_blue/pages/login_register_page.dart';
import 'package:att_blue/pages/register_page.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return HomePage();
        }else{
          return const LoginPage();
        }
      },
    );
  }
}