// ignore_for_file: avoid_function_literals_in_foreach_calls, prefer_typing_uninitialized_variables, unused_field
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:csv/csv.dart';
// import 'package:path_provider/path_provider.dart';

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
  List<List<String>> csvData = [];
  List<Map<String, dynamic>> user = [];

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
                        user = [];
                        int presentCount = 0;
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
                                userLocal["Students"][i]["Status"] = "Present";
                                presentCount++;
                              } else {
                                userLocal["Students"][i]["Status"] = "Absent";
                              }
                              user.add(userLocal["Students"][i]);
                            }
                            print("here!!!");
                            print(user);
                          }
                        });
                        // print(user);
                        return Column(
                          children: [
                            // const SizedBox(height: 30),
                            // const Text(
                            //   "Present Students: ",
                            //   style: TextStyle(fontSize: 20),
                            //   textAlign: TextAlign.center,
                            // ),
                            // const SizedBox(height: 30),
                            // Text(
                            //     "${presentCount}/${user.length} students are present"),
                            // const SizedBox(height: 10),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.8,
                              child: Padding(
                                padding: const EdgeInsets.all(7.0),
                                child: ListView.separated(
                                  itemCount: user.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            left: BorderSide(
                                              color: user[index]['Status'] ==
                                                      'Present'
                                                  ? const Color.fromRGBO(
                                                      16, 142, 54, 0.8)
                                                  : const Color.fromRGBO(
                                                      185,
                                                      5,
                                                      5,
                                                      0.8), // Color of the left border
                                              width:
                                                  8.0, // Width of the left border
                                            ),
                                          ),
                                        ),
                                        child: ListTile(
                                          title: Text(
                                              user[index]['Register number']),
                                          subtitle: Text(user[index]['Name']),
                                        ));
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
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  onPressed: () async {
                                    generateCSV();
                                  },
                                  child: const Text('Export CSV',
                                      style: TextStyle(
                                        color: Colors.white,
                                      )),
                                ))
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

  Future<void> generateCSV() async {
    // try {
    //   var status = await Permission.manageExternalStorage.request();
    //   if (status.isDenied) {
    //     print("PERMISSION ERROR!!!!");
    //     return;
    //   }
    // } catch (e) {
    //   print("HERE!!");
    //   print(e);
    // }

    List<String> rowHeader = ["Register Number", "Name", "Present/Absent"];
    List<List<dynamic>> rows = [];
    rows.add(rowHeader);
    for (int i = 0; i < user.length; i++) {
      List<dynamic> dataRow = [];
      dataRow.add(user[i]['Register number']);
      dataRow.add(user[i]['Name']);
      dataRow.add(user[i]['Status']);
      rows.add(dataRow);
    }

    try {
      String csv = const ListToCsvConverter().convert(rows);
      // final directory = await getExternalStorageDirectory();
      // final String filePath = '${directory?.path}/my_data.csv';
      final String filePath =
          '/storage/emulated/0/Download/${date}_${semester}_${subject}_Slot-${slot}.csv';
      final File file = File(filePath);
      await file.writeAsString(csv);
      print('CSV file saved to $filePath');
      await _showSnackBar('CSV file saved to Downloads folder');
    } catch (e) {
      print("Error creating file!");
      print(e);
      _showSnackBar(e.toString());
    }
  }

  Future<void> _showSnackBar(String message) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
