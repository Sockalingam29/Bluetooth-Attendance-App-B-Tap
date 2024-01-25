// ignore_for_file: unused_import, avoid_print, await_only_futures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../auth.dart';
import 'package:att_blue/pages/staff_home.dart';

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
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: TextField(
          controller: controller,
          obscureText: title == 'Password' ? true : false,
          decoration: InputDecoration(
            hintText: title,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
          ),
        ));
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
    return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
            onPressed: () async {
              var email = _emailCtrl.text.trim();
              var password = _passwordCtrl.text.trim();
              User? firebaseUser = FirebaseAuth.instance.currentUser;
              if (!email.toLowerCase().endsWith('tce.edu')) {
                setState(() {
                  errorMsg = 'Not a valid Email';
                });
              } else if (email != "" && password != "") {
                try {
                  firebaseUser = await (await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: email, password: password))
                      .user;

                  if (firebaseUser != null) {
                    print(firebaseUser);
                    if (email.toLowerCase().endsWith('@student.tce.edu')) {
                      Get.offNamed('/studentHome');
                    } else {
                      Get.offNamed('/staffHome');
                    }
                  } else {
                    print("USER IS NULL!");
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('Login', style: TextStyle(color: Colors.white))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome back!',
              style: Theme.of(context).textTheme.headline4,
            ),
            _entryField('Email', _emailCtrl),
            _entryField('Password', _passwordCtrl),
            _errorMessage(),
            _loginBtn(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Create an account?'),
                TextButton(
                  onPressed: () {
                    Get.offNamed('/register');
                  },
                  child: const Text(
                    'Register',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
