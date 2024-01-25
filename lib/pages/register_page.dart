// ignore_for_file: avoid_print, unused_import

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  final TextEditingController _confirmPasswordCtrl = TextEditingController();
  final TextEditingController _regNoCtrl = TextEditingController();
  //Dropdown for Semester
  String? _selectedSemester;
  final List<String> _semester = [
    'Semester',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8'
  ];
  //Dropdown for Slot
  String? _selectedSlot;
  final List<String> _slot = ['Slot', 'A', 'B', 'C'];

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

  //Widget for Dropdown for Semester
  Widget _semesterDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          hintText: 'Semester',
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
        value: _selectedSemester,
        items: _semester.map((semester) {
          return DropdownMenuItem(
            value: semester,
            child: Text(semester),
          );
        }).toList(),
        onChanged: (value) {
          if (value.toString() != 'Semester') {
            setState(() {
              _selectedSemester = value.toString();
            });
          }
        },
      ),
    );
  }

  //Widget for Dropdown for Slot
  Widget _slotDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          hintText: 'Slot',
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
        value: _selectedSlot,
        items: _slot.map((slot) {
          return DropdownMenuItem(
            value: slot,
            child: Text(slot),
          );
        }).toList(),
        onChanged: (value) {
          if (value.toString() != 'Slot') {
            setState(() {
              _selectedSlot = value.toString();
            });
          }
        },
      ),
    );
  }

  Widget _errorMessage() {
    return Text(errorMsg == '' ? '' : 'Humm ? $errorMsg');
  }

  //Widget to show snackbar with a parameter of String
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
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
            var confirmPassword = _confirmPasswordCtrl.text.trim();
            // var semester = _selectedSemester;
            // var slot = _selectedSlot;

            if (name == '' ||
                email == '' ||
                regno == '' ||
                password == '' ||
                confirmPassword == '' ||
                _selectedSemester == null ||
                _selectedSlot == null) {
              _showSnackBar('Please fill all the fields');
            } else if (password != confirmPassword) {
              _showSnackBar('Passwords don\'t match');
            } else if (!email.toLowerCase().endsWith('@student.tce.edu')) {
              // setState(() {
              //   errorMsg = 'Not a valid Email';
              // });
              _showSnackBar('Not a valid Email');
            } else {
              try {
                DocumentReference<Map<String, dynamic>> db;
                DocumentSnapshot<Map<String, dynamic>> data;
                await FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                        email: email, password: password)
                    .then((value) async => {
                          // setState(() {
                          //   errorMsg = "Created";
                          // }),
                          _showSnackBar("Created"),
                          // print("User created to FireAuth"),
                          db = await FirebaseFirestore.instance
                              .collection("Student")
                              .doc(
                                  "Semester $_selectedSemester Slot $_selectedSlot"),

                          data = await db.get(),

                          if (!data.exists)
                            {
                              db.set({
                                "Students": FieldValue.arrayUnion([
                                  {
                                    "Name": name,
                                    "Register number": regno,
                                    "Email": email,
                                    // "UserID": currentUser?.uid,
                                  }
                                ])
                              })
                            }
                          else
                            {
                              db.update({
                                "Students": FieldValue.arrayUnion([
                                  {
                                    "Name": name,
                                    "Register number": regno,
                                    "Email": email,
                                    // "UserID": currentUser?.uid,
                                  }
                                ])
                              })
                            },

                          //     data.update({
                          //   "Students": FieldValue.arrayUnion([
                          //     {
                          //       "Name": name,
                          //       "Register number": regno,
                          //       "Email": email,
                          //       // "UserID": currentUser?.uid,
                          //     }
                          //   ])
                          // }),
                          _showSnackBar("Added to Database"),
                          Get.offNamed('/studentHome')
                        });
              } on FirebaseAuthException catch (e) {
                print(e.code);
                String? err = e.message;
                _showSnackBar(err!);
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text('Register', style: TextStyle(color: Colors.white)),
        ));
  }

  //Fix the bottom overflowed by 54 pixels

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Apply safe area to avoid the notch

      backgroundColor: Colors.white,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
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
                  _semesterDropdown(),
                  _slotDropdown(),
                  _entryField('Password', _passwordCtrl),
                  _entryField('Confirm Password', _confirmPasswordCtrl),
                  _errorMessage(),
                  _registerBtn(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
        ),
      ),
    );
  }
}
