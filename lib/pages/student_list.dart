// ignore_for_file: avoid_function_literals_in_foreach_calls, prefer_typing_uninitialized_variables, unused_field


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
  String slot = '';
  var userCollection;
  var userStream;
  var currentDateCollection;
  var currentDateStream;
  var userData;

  _StudentListState() {
    subject = Get.arguments['subject'];
    semester = Get.arguments['semester'];
    date = Get.arguments['date'];
    slot = Get.arguments['slot'];
    // print(subject + " " + semester + " " + date);
    userCollection = FirebaseFirestore.instance.collection('Student');
    userStream = FirebaseFirestore.instance.collection('Student').snapshots();

    currentDateCollection =
        FirebaseFirestore.instance.collection(date).doc("$semester Slot $slot");

    currentDateStream = FirebaseFirestore.instance.collection(date).snapshots();
  }

  Widget studentListBody() {
    return Center(
      child: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
              stream: currentDateStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text("Error");
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData) {
                  List<dynamic> email = [];

                  snapshot.data!.docs.forEach((element) {
                    if (element.id == "$semester Slot $slot") {
                      Map<String, dynamic> data =
                          element.data()! as Map<String, dynamic>;
                      email = data[subject] as List<dynamic>;
                    }
                  });

                  return StreamBuilder<QuerySnapshot>(
                    stream: userStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text("Error");
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasData) {
                        List<Map<String, dynamic>> user = [];
                        snapshot.data!.docs.forEach((element) {
                          // print(element.data());
                          if (element.id == "$semester Slot $slot") {
                            // print(element.data());
                            Map<String, dynamic> userLocal =
                                element.data() as Map<String, dynamic>;

                            // print(userLocal["Students"]);
                            for (var i = 0;
                                i < userLocal["Students"].length;
                                i++) {
                              if (email.contains(
                                  userLocal["Students"][i]["Email"])) {
                                user.add(userLocal["Students"][i]);
                              }
                            }
                            print("here!!!");
                            print(user);
                          }
                        });
                        // print(user);
                        return Column(
                          children: [
                            const SizedBox(height: 30),
                            const Text(
                              "Present Students: ",
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            Text("${user.length} students are present"),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: ListView.separated(
                                  itemCount: user.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ListTile(
                                      title:
                                          Text(user[index]['Register number']),
                                      subtitle: Text(user[index]['Name']),
                                      tileColor: const Color.fromARGB(
                                          255, 168, 197, 219),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const Divider(
                                      color: Colors.black,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                        // return const Text("Data is There");
                      }

                      return const Text("No Data");
                    },
                  );
                }
                return const Text("No data");
              }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student List')),
      body: studentListBody(),
    );
    // return StudentListBody();
  }
}
