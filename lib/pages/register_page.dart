// ignore_for_file: avoid_print, unused_import

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../auth.dart';
import 'package:att_blue/pages/home_page.dart';

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

  Widget _errorMessage() {
    return Text(errorMsg == '' ? '' : 'Humm ? $errorMsg');
  }

  Widget _registerBtn() {
    return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () async {
            var name = _nameCtrl.text.trim();
            var email = _emailCtrl.text.trim();
            var regno = _regNoCtrl.text.trim();
            var password = _passwordCtrl.text.trim();

            if (!email.toLowerCase().endsWith('@student.tce.edu')) {
              setState(() {
                errorMsg = 'Not a valid Email';
              });
            } else {
              try {
                await FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                        email: email, password: password)
                    .then((value) => {
                          setState(() {
                            errorMsg = "Created";
                          }),
                          print("User created to FireAuth"),
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
                          print("Data added to Firestore")
                        });
              } on FirebaseAuthException catch (e) {
                print(e.code);
                // print("Error : $e");
                setState(() {
                  errorMsg = e.message;
                });
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text('Register'),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Create an account',
                style: Theme.of(context).textTheme.headline4,
              ),
              _entryField('Name', _nameCtrl),
              _entryField('Email', _emailCtrl),
              _entryField('Register Number', _regNoCtrl),
              _entryField('Password', _passwordCtrl),
              _errorMessage(),
              _registerBtn(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: () {
                      Get.offNamed('/login');
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
            ]),
      ),
    );
  }
}
