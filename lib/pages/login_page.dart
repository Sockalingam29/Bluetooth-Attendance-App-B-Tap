import 'package:att_blue/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String? errorMsg = '';

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  Widget _entryField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMsg = e.message;
      });
    }
  }

  Widget _errorMessage() {
    return Text(errorMsg == '' ? '' : 'Humm ? $errorMsg');
  }

  Widget _loginBtn() {
    return ElevatedButton(
        onPressed: () async {
          var email = _emailCtrl.text.trim();
          var password = _passwordCtrl.text.trim();

          if (!email.toLowerCase().endsWith('tce.edu')) {
            setState(() {
              errorMsg = 'Not a valid Email';
            });
          } else if (email != "" && password != "") {
            try {
              final User? firebaseUser = (await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: email, password: password))
                  .user;

              if (firebaseUser != null) {
                Get.toNamed('/staffHome');
                // ignore: use_build_context_synchronously
                // Navigator.pushNamed(context, '/home');
              }
            } on FirebaseAuthException catch (e) {
              setState(() {
                errorMsg = e.message;
              });
            }
          } else {
            setState(() {
              errorMsg = 'Email and Password mismatch';
            });
          }
        },
        child: const Text('Login'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _entryField('Email', _emailCtrl),
            _entryField('Password', _passwordCtrl),
            _errorMessage(),
            _loginBtn(),
            ElevatedButton(
                onPressed: () {
                  Get.toNamed('/register');
                },
                child: const Text("Create a new account")),
          ],
        ),
      ),
    );
  }
}
