// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:att_blue/pages/home_page.dart';
import 'package:att_blue/pages/login_register_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../auth.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String? errorMsg = '';

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _regNoCtrl = TextEditingController();

  User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(), password: _passwordCtrl.text.trim());
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMsg = e.message;
      });
    }
  }

  Widget _entryField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _errorMessage() {
    return Text(errorMsg == '' ? '' : 'Humm ? $errorMsg');
  }

  Widget _registerBtn() {
    return ElevatedButton(
        onPressed: () async {
          var name = _nameCtrl.text.trim();
          var email = _emailCtrl.text.trim();
          var regno = _regNoCtrl.text.trim();
          var password = _passwordCtrl.text.trim();
          if (!email.toLowerCase().endsWith('@student.tce.edu')) {
            setState(() {
              errorMsg = 'Not a valid Email';
            });
          } else if (name != "" &&
              email != "" &&
              regno != "" &&
              password != "") {
            try {
              FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                      email: email, password: password)
                  .then((value) => {
                        log("User created to FireAuth"),
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc(currentUser?.uid)
                            .set({
                          "createdAt": DateTime.now(),
                          "UserID": currentUser?.uid,
                          "Email": email,
                          "Name": name,
                          "Register number": regno,
                          "Role": "Student",
                        }),
                        // .then((value) => {
                        //           FirebaseAuth.instance.signOut(),
                        //           Get.toNamed('/login'),
                        //         }),
                        log("Data added to Firestore")
                      });
              Get.toNamed('/login');
            } on FirebaseAuthException catch (e) {
              print("Error $e");
              setState(() {
                errorMsg = e.message;
              });
            }
          }
        },
        child: const Text('Register'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Register'),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _entryField('Name', _nameCtrl),
            _entryField('Email', _emailCtrl),
            _entryField('Phone Number', _regNoCtrl),
            _entryField('Password', _passwordCtrl),
            _errorMessage(),
            _registerBtn(),
            ElevatedButton(
                onPressed: () {
                  // Get.to(const LoginPage());
                  Get.toNamed('/login');
                },
                child: const Text("Already Have an account")),
          ],
        ),
      ),
    );
  }
}
