// ignore_for_file: use_build_context_synchronously, unnecessary_new, avoid_print

// import 'dart:math';
// import 'package:att_blue/pages/student_list.dart';
// import 'package:att_blue/models/sub.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'list.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _StaffHomePage createState() => _StaffHomePage();
}

class _StaffHomePage extends State<StaffHomePage> {
  bool _isLoading = false;

  String semesterChoosen = "Select a Option";
  String subjectChoosen = "Select a Option";
  TextEditingController dateController = TextEditingController();

  String userName = "";
  final Strategy strategy = Strategy.P2P_STAR; //1 to N
  Map<String, ConnectionInfo> endpointMap = Map(); //connection details

  String? tempFileUri; //reference to the file currently being transferred
  Map<int, String> map =
      Map(); //store filename mapped to corresponding payloadId

  @override
  void initState() {
    super.initState();
    dateController.text = "";
  }

  // List of items in our dropdown menu
  var semester = [
    "Select a Option",
    "Semester 1",
    "Semester 2",
    "Semester 3",
    "Semester 4",
  ];

  var subject = [
    "Select a Option",
    "Subject 1",
    "Subject 2",
    "Subject 3",
    "Subject 4",
  ];

  Widget _takeAttendance(bool _isLoading) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : _onPressed,
          child: Text("Take attendance"),
        ),
        Visibility(
          visible: _isLoading,
          child: CircularProgressIndicator(),
        ),
        Visibility(
          visible: _isLoading,
          child: Positioned(
            right: 0.0,
            child: IconButton(
              icon: Icon(Icons.cancel),
              onPressed: _onCancel,
            ),
          ),
        ),
      ],
    );

    // return SizedBox(
    // width: double.infinity,
    // height: 48,
    // child: ElevatedButton(
    //     onPressed: () async {
    //       if (!await Nearby().askLocationPermission()) {
    //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //             content: Text("Location permissions not granted :(")));
    //       }

    //       if (!await Nearby().enableLocationServices()) {
    //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //             content: Text("Enabling Location Service Failed :(")));
    //       }

    //       if (!await Nearby().checkBluetoothPermission()) {
    //         Nearby().askBluetoothPermission();
    //         // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //         //     content: Text("Bluetooth permissions not granted :(")));
    //       }

    //       if (semesterChoosen != "Select a Option" &&
    //           subjectChoosen != "Select a Option") {
    //         try {
    //           userName = "TCE_Faculty $semesterChoosen $subjectChoosen";
    //           bool a = await Nearby().startAdvertising(
    //             userName,
    //             strategy,
    //             onConnectionInitiated: onConnectionInit,
    //             onConnectionResult: (id, status) {
    //               showSnackbar(status);
    //             },
    //             onDisconnected: (id) {
    //               showSnackbar(
    //                   "Disconnected: ${endpointMap[id]!.endpointName}, id $id");
    //               setState(() {
    //                 endpointMap.remove(id);
    //               });
    //             },
    //           );
    //           showSnackbar("ADVERTISING: $a");
    //         } catch (exception) {
    //           showSnackbar(exception);
    //         }
    //       } else {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //             const SnackBar(content: Text("Please Select All Fields")));
    //       }
    //     },
    //     style: ElevatedButton.styleFrom(
    //       backgroundColor: Colors.deepPurple,
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(8.0),
    //       ),
    //     ),
    //     child: const Text('Take Attendance')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        automaticallyImplyLeading: false,
        title: const Text("Faculty Home"),
        actions: [
          GestureDetector(
              child: const Icon(Icons.logout_sharp),
              onTap: () async {
                await Nearby().stopAdvertising();
                await FirebaseAuth.instance.signOut();
                Get.toNamed('/login');
              }),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Choose Semester"),
              DropdownButton(
                value: semesterChoosen,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: semester.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    semesterChoosen = newValue!;
                  });
                },
              ),
              const Text('Choose Subject'),
              DropdownButton(
                value: subjectChoosen, // Initial Value
                icon: const Icon(Icons.keyboard_arrow_down), // Down Arrow Icon
                items: subject.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                // After selecting the desired option,it will change button value to selected value
                onChanged: (String? newValue) {
                  setState(() {
                    subjectChoosen = newValue!;
                  });
                },
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                    icon: Icon(Icons.calendar_today), labelText: "Enter Date"),
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
              const SizedBox(
                height: 60.0,
              ),
              _takeAttendance(_isLoading),
              ElevatedButton(
                child: Text("Stop Advertising"),
                onPressed: () async {
                  await Nearby().stopAdvertising();
                },
              ),
              ElevatedButton(
                  onPressed: () {
                    print(
                        "$semesterChoosen $subjectChoosen ${dateController.text}");

                    // Get.toNamed('/staffHome');
                  },
                  child: const Text("Student List")),
            ],
          ),
        ),
      ),
    );
  }

  void _onPressed() async {
    setState(() {
      _isLoading = true;
    });
    // timeout 2 secs
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

  void _onCancel() {
    setState(() {
      _isLoading = false;
    });
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
