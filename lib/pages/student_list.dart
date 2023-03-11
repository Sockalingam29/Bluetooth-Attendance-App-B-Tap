// ignore_for_file: avoid_function_literals_in_foreach_calls, prefer_typing_uninitialized_variables, avoid_print, prefer_interpolation_to_compose_strings

import 'dart:developer';

import 'package:att_blue/models/sub.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentList extends StatefulWidget {
  const StudentList({super.key});

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  late List<Map<String, dynamic>> _studentList;
  bool isLoaded = false;
  String date = '';
  String subject = '';
  String semester = '';
  var userCollection;
  var currentDateCollection;

  _StudentListState() {
    subject = Get.arguments['subject'];
    semester = Get.arguments['semester'];
    date = Get.arguments['date'];

    userCollection = FirebaseFirestore.instance.collection('Users');

    currentDateCollection =
        FirebaseFirestore.instance.collection(date).doc("$semester $subject");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student List')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () async {
                  List<Map<String, dynamic>> tmp = [];
                  var userData = await userCollection.get();
                  var currentData = await currentDateCollection.get();
                  // print("First element in currentDate Collection : " +
                  //     currentData.data()['email'][0]);

                  if (currentData.data() != null) {
                    userData.docs.forEach((element) {
                      for (int i = 0;
                          i < currentData.data()['email'].length;
                          i++) {
                        print(currentData.data()['email'][i] +
                            " " +
                            element.data()['Email']);
                        if (currentData.data()['email'][i].toString() ==
                            element.data()['Email'].toString()) {
                          tmp.add(element.data());
                          print("Added");
                          print(element.data()['Email']);
                        }
                      }

                      // print(element.data()['Name']);
                    });
                  }
                  tmp.forEach((element) {
                    log(element['Name']);
                  });
                  setState(() {
                    _studentList = tmp;
                    isLoaded = true;
                  });
                },
                child: const Text('List Users')),
            const SizedBox(height: 30),
            if (isLoaded)
              const Text(
                "Present Students: ",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.left,
              ),
            if (isLoaded)
              Expanded(
                  // child: ListView.builder(
                  //     itemCount: _studentList.length,
                  //     itemBuilder: (context, index) {
                  //       return ListTile(
                  //         title: Text(_studentList[index]['Name']),
                  //         subtitle: Text(_studentList[index]['Register number']),
                  //       );
                  //     }),
                  child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: ListView.separated(
                  itemCount: _studentList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(_studentList[index]['Name']),
                      subtitle: Text(_studentList[index]['Register number']),
                      tileColor: const Color.fromARGB(255, 168, 197, 219),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      color: Colors.black,
                    );
                  },
                ),
              ))
          ],
        ),
      ),
    );
  }
}
