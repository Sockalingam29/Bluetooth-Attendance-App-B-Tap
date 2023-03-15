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
  var userStream;
  var currentDateCollection;
  var currentDateStream;
  var userData;

  _StudentListState() {
    subject = Get.arguments['subject'];
    semester = Get.arguments['semester'];
    date = Get.arguments['date'];
    // print(subject + " " + semester + " " + date);
    userCollection = FirebaseFirestore.instance.collection('Users');
    userStream = FirebaseFirestore.instance.collection('Users').snapshots();

    currentDateCollection =
        FirebaseFirestore.instance.collection(date).doc("$semester $subject");

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
                    if (element.id == "$semester $subject") {
                      Map<String, dynamic> data =
                          element.data()! as Map<String, dynamic>;
                      email = data['email'] as List<dynamic>;
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
                          Map<String, dynamic> userLocal =
                              element.data()! as Map<String, dynamic>;
                          if (email.contains(userLocal['Email'])) {
                            user.add(userLocal);
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
                            Text(user.length.toString() +
                                " students are present"),
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

                  // var userData = userCollection.get();
                  // print("First element in currentDate Collection : " +
                  //     userData);
                  // print("First element in currentDate Collection : " +
                  //     userData.data()['email'][0]);
                  //       if (currentData.data() != null) {
                  //         userData.docs.forEach((element) {
                  //           for (int i = 0;
                  //               i < currentData.data()['email'].length;
                  //               i++) {
                  //             // print(currentData.data()['email'][i] +" " +element.data()['Email']);
                  //             if (currentData.data()['email'][i].toString() ==
                  //                 element.data()['Email'].toString()) {
                  //               tmp.add(element.data());
                  //               print("Added");
                  //               print(element.data()['Email']);
                  //             }
                  //           }
                  //           // print(element.data()['Name']);
                  //         });
                  //       }
                  //       tmp.forEach((element) {
                  //         log(element['Name']);
                  //       });
                  //       setState(() {
                  //         _studentList = tmp;
                  //         isLoaded = true;
                  //       });
                  //     },

                  // return Column(
                  //   children: [
                  //     const Text(
                  //       "Present Students: ",
                  //       style: TextStyle(fontSize: 20),
                  //       textAlign: TextAlign.left,
                  //     ),
                  //     Padding(
                  //       padding: const EdgeInsets.all(14.0),
                  //       child: SizedBox(
                  //         height: 600.0,
                  //         child: ListView.separated(
                  //           itemCount: email.length,
                  //           itemBuilder: (BuildContext context, int index) {
                  //             return ListTile(
                  //               title: Text(email[index]),
                  //               subtitle: Text("register number"),
                  //               tileColor:
                  //                   const Color.fromARGB(255, 168, 197, 219),
                  //             );
                  //           },
                  //           separatorBuilder:
                  //               (BuildContext context, int index) {
                  //             return const Divider(
                  //               color: Colors.black,
                  //             );
                  //           },
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // );
                  // return Text("Data");
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
