// ignore_for_file: use_build_context_synchronously, unnecessary_new, avoid_print, depend_on_referenced_packages, unused_import, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings

// import 'dart:math';
// import 'package:att_deepPurple/pages/student_list.dart';
// import 'package:att_deepPurple/models/sub.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'student_list.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _StaffHomePage createState() => _StaffHomePage();
}

class _StaffHomePage extends State<StaffHomePage> {
  String semesterChoosen = "Select an Option";
  String subjectChoosen = "Select an Option";
  String slotChoosen = "Select an Option";
  TextEditingController dateController = TextEditingController();

  String userName = "";
  final Strategy strategy = Strategy.P2P_STAR; //1 to N
  Map<String, ConnectionInfo> endpointMap = {}; //connection details

  String? tempFileUri; //reference to the file currently being transferred
  Map<int, String> map = {}; //store filename mapped to corresponding payloadId
  User? user = FirebaseAuth.instance.currentUser;
  //Current User Details from firebaseauth.instance

  late final String currEmail = user?.email.toString() ?? "null";

  // List of items in our dropdown menu
  var semester = [
    "Select an Option",
  ];
  var subject = [
    "Select an Option",
  ];
  var slot = ["Select an Option"];

  bool isAdvertising = false;
  var semesters;
  var subjects;
  var slots;
  var subjectsHandling;

  @override
  void initState() {
    super.initState();
    dateController.text = "";
    // print(currEmail);
    //Fetch the current user details from firebaseauth.instance from Faculty Collection
    FirebaseFirestore.instance
        .collection("Faculty")
        .where("Email", isEqualTo: currEmail)
        .get()
        .then((value) {
      for (var element in value.docs) {
        //Get the subjects handled by the faculty
        subjectsHandling = element.data()['SubjectsHandling'];
        //Get the keys of the subjects handled by the faculty
        setState(() {
          semesters = subjectsHandling.keys;
        });

        semester.addAll(semesters);
        semester.sort();
        // print(semester);
      }
    });
  }

  Widget _takeAttendance() {
    bool isToday =
        dateController.text == DateFormat("dd-MM-yyyy").format(DateTime.now());
    if (isToday) {
      return !isAdvertising
          ? SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      )),
                  child: const Text('Take Attendance',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    if (!isToday) {
                      return;
                    }
                    // if (!await Nearby().askLocationPermission()) {
                    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    //       content:
                    //           Text("Location permissions not granted :(")));
                    // }

                    // if (!await Nearby().enableLocationServices()) {
                    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    //       content:
                    //           Text("Enabling Location Service Failed :(")));
                    // }

                    if (!await Nearby().checkBluetoothPermission()) {
                      Nearby().askBluetoothPermission();
                      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      //     content: Text("Bluetooth permissions not granted :(")));
                    }

                    while (!await Permission.bluetooth.isGranted ||
                        !await Permission.bluetoothAdvertise.isGranted ||
                        !await Permission.bluetoothConnect.isGranted ||
                        !await Permission.bluetoothScan.isGranted) {
                      [
                        Permission.bluetooth,
                        Permission.bluetoothAdvertise,
                        Permission.bluetoothConnect,
                        Permission.bluetoothScan
                      ].request();
                    }

                    if (semesterChoosen != "Select an Option" &&
                        subjectChoosen != "Select an Option" &&
                        slotChoosen != "Select an Option") {
                      try {
                        userName =
                            "TCE_Faculty $semesterChoosen $subjectChoosen $slotChoosen";
                        bool a = await Nearby().startAdvertising(
                          userName,
                          strategy,
                          onConnectionInitiated: onConnectionInit,
                          onConnectionResult: (id, status) {
                            showSnackbar(status);
                          },
                          onDisconnected: (id) {
                            showSnackbar(
                                "Disconnected: ${endpointMap[id]!.endpointName}, id $id");
                            setState(() {
                              endpointMap.remove(id);
                            });
                          },
                        );
                        showSnackbar("ADVERTISING: $a");

                        setState(() {
                          isAdvertising = true;
                        });
                      } catch (exception) {
                        showSnackbar(exception);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Please Select All Fields")));
                    }
                  }),
            )
          : SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      await Nearby().stopAdvertising();
                      showSnackbar("Stopped Advertising");

                      setState(() {
                        isAdvertising = false;
                      });
                    } catch (exception) {
                      showSnackbar(exception);
                    }
                  },
                  child: const Text('Stop Attendance',
                      style: TextStyle(color: Colors.white))),
            );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        title: const Text("TCE Faculty", style: TextStyle(color: Colors.white)),
        actions: [
          GestureDetector(
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20.0,
                child: Icon(Icons.logout_sharp, color: Colors.deepPurple),
              ),
              onTap: () async {
                await Nearby().stopAdvertising();
                await FirebaseAuth.instance.signOut();
                Get.offNamed('/login');
              }),
        ],
      ),
      body: Container(
        // height: MediaQuery.of(context).size.height * 0.45,
        height: double.infinity,
        margin: EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.height * 0.05),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Select Semester
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.02,
                  horizontal: MediaQuery.of(context).size.height * 0.01),
              child: Row(
                children: [
                  const Text("Choose Semester ",
                      style: TextStyle(fontSize: 13)),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownButton(
                      value: semesterChoosen,
                      hint: const Text("Select an Option"),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: semester.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          slotChoosen = "Select an Option";
                          subjectChoosen = "Select an Option";
                          semesterChoosen = newValue!;
                          if (semesterChoosen != 'Select an Option') {
                            subjects = subjectsHandling[semesterChoosen].keys;
                            print(subjects);
                            subject.removeRange(1, subject.length);
                            subject.addAll(subjects);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            //Select Subject
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.02,
                  horizontal: MediaQuery.of(context).size.height * 0.01),
              child: Row(
                children: [
                  const Text('Choose Subject', style: TextStyle(fontSize: 13)),
                  DropdownButton(
                    value: subjectChoosen, // Initial Value
                    icon: const Icon(
                        Icons.keyboard_arrow_down), // Down Arrow Icon
                    items: subject.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    // After selecting the desired option,it will change button value to selected value
                    onChanged: (String? newValue) {
                      setState(() {
                        slotChoosen = "Select an Option";
                        subjectChoosen = newValue!;
                        if (semesterChoosen != 'Select an Option' &&
                            subjectChoosen != 'Select an Option') {
                          slots =
                              subjectsHandling[semesterChoosen][subjectChoosen];
                          print(slots);

                          slot.removeRange(1, slot.length);
                          slot.addAll(List<String>.from(slots));
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            //Select Slot
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.02,
                  horizontal: MediaQuery.of(context).size.height * 0.01),
              child: Row(
                children: [
                  const Text('Choose Slot', style: TextStyle(fontSize: 13)),
                  DropdownButton(
                    value: slotChoosen, // Initial Value
                    icon: const Icon(
                        Icons.keyboard_arrow_down), // Down Arrow Icon
                    items: slot.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    // After selecting the desired option,it will change button value to selected value
                    onChanged: (String? newValue) {
                      setState(() {
                        slotChoosen = newValue!;
                        print(slotChoosen);
                      });
                    },
                  ),
                ],
              ),
            ),
            //Select Date
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.02,
                  horizontal: MediaQuery.of(context).size.height * 0.01),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.calendar_today),
                      labelText: "Enter Date"),
                  readOnly: true,
                  onTap: (() async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      String formattedDate =
                          DateFormat("dd-MM-yyyy").format(pickedDate);
                      setState(() {
                        dateController.text = formattedDate.toString();
                      });
                    } else {
                      const Text("Not Selected Date!!!");
                    }
                  }),
                ),
              ),
            ),
            //Take Attendance Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _takeAttendance(),
            ),
            //Student List Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(color: Colors.deepPurple),
                    ),
                  ),
                  onPressed: () {
                    // print("$semesterChoosen $subjectChoosen ${dateController.text}");

                    if (semesterChoosen == "Select an Option" ||
                        subjectChoosen == "Select an Option" ||
                        dateController.text == "") {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Please Select All Fields")));
                      return;
                    }

                    Get.toNamed('/studentList', arguments: {
                      "semester": semesterChoosen,
                      "subject": subjectChoosen,
                      "date": dateController.text,
                      "slot": slotChoosen
                    });
                  },
                  child: const Text("Student List",
                      style: TextStyle(color: Colors.deepPurple))),
            ),
          ],
        ),
      ),
    );
  }

  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }

  //  Called upon Connection request (on both devices)
  // Both need to accept connection to start sending/receiving
  void onConnectionInit(String id, ConnectionInfo info) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Center(
          child: Column(
            children: <Widget>[
              Text("id: $id"),
              Text("Token: ${info.authenticationToken}"),
              Text("Name: ${info.endpointName}"),
              Text("Incoming: ${info.isIncomingConnection}"),
              ElevatedButton(
                child: const Text("Accept Connection"),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    endpointMap[id] = info;
                  });
                  Nearby().acceptConnection(
                    id,
                    onPayLoadRecieved: (endid, payload) async {},
                    onPayloadTransferUpdate: (endid, payloadTransferUpdate) {},
                  );
                },
              ),
              ElevatedButton(
                child: const Text("Reject Connection"),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await Nearby().rejectConnection(id);
                  } catch (e) {
                    showSnackbar(e);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
