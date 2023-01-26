// ignore_for_file: use_build_context_synchronously, unnecessary_new

import 'dart:math';

// import 'package:att_blue/pages/student_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nearby_connections/nearby_connections.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _StaffHomePage createState() => _StaffHomePage();
}

class _StaffHomePage extends State<StaffHomePage> {
  // Initial Selected Value
  String dropdownvalue1 = "Semester 1";
  String dropdownvalue2 = "Subject 1";

  TextEditingController dateController = TextEditingController();

  final String userName = Random().nextInt(10000).toString();
  final Strategy strategy = Strategy.P2P_STAR;
  Map<String, ConnectionInfo> endpointMap = Map();

  String? tempFileUri; //reference to the file currently being transferred
  Map<int, String> map =
      Map(); //store filename mapped to corresponding payloadId

  @override
  void initState() {
    super.initState();
    dateController.text = "";
  }

  // List of items in our dropdown menu
  var sem = [
    "Semester 1",
    "Semester 2",
    "Semester 3",
    "Semester 4",
    "Semester 5",
  ];

  var sub = [
    "Subject 1",
    "Subject 2",
    "Subject 3",
    "Subject 4",
    "Subject 5",
  ];

  Widget _takeAttendance() {
    return ElevatedButton(
        child: const Text('Take Attendance'),
        onPressed: () async {
          if (!await Nearby().askLocationPermission()) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Location permissions not granted :(")));
          }

          if (!await Nearby().enableLocationServices()) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Enabling Location Service Failed :(")));
          }

          if (!await Nearby().checkBluetoothPermission()) {
            Nearby().askBluetoothPermission();
            // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            //     content: Text("Bluetooth permissions not granted :(")));
          }

          try {
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
            showSnackbar("ADVERTISING: " + a.toString());
          } catch (exception) {
            showSnackbar(exception);
          }
        });
  }

  // Widget _logOutBtn() {
  // return ElevatedButton(child: const Text('Log Out'), onPressed: () {});
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TCE Faculty"),
        actions: [
          GestureDetector(
              child: const Icon(Icons.logout_sharp),
              onTap: () {
                FirebaseAuth.instance.signOut();
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
                // Initial Value
                value: dropdownvalue1,

                // Down Arrow Icon
                icon: const Icon(Icons.keyboard_arrow_down),

                // Array list of items
                items: sem.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                // After selecting the desired option,it will
                // change button value to selected value
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownvalue1 = newValue!;
                  });
                },
              ),
              const Text('Choose Subject'),
              DropdownButton(
                // Initial Value
                value: dropdownvalue2,

                // Down Arrow Icon
                icon: const Icon(Icons.keyboard_arrow_down),

                // Array list of items
                items: sub.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                // After selecting the desired option,it will
                // change button value to selected value
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownvalue2 = newValue!;
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
              _takeAttendance(),
              ElevatedButton(
                child: Text("Stop Advertising"),
                onPressed: () async {
                  await Nearby().stopAdvertising();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }

  // Future<bool> moveFile(String uri, String fileName) async {
  // String parentDir = (await getExternalStorageDirectory())!.absolute.path;
  // final b =
  //     await Nearby().copyFileAndDeleteOriginal(uri, '$parentDir/$fileName');

  // showSnackbar("Moved file:" + b.toString());
  // return b;
  // }

  /// Called upon Connection request (on both devices)
  /// Both need to accept connection to start sending/receiving
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
                    onPayLoadRecieved: (endid, payload) async {
                      //   if (payload.type == PayloadType.BYTES) {
                      //     String str = String.fromCharCodes(payload.bytes!);
                      //     showSnackbar(endid + ": " + str);

                      //     if (str.contains(':')) {
                      //       // used for file payload as file payload is mapped as
                      //       // payloadId:filename
                      //       int payloadId = int.parse(str.split(':')[0]);
                      //       String fileName = (str.split(':')[1]);

                      //       if (map.containsKey(payloadId)) {
                      //         if (tempFileUri != null) {
                      //           moveFile(tempFileUri!, fileName);
                      //         } else {
                      //           showSnackbar("File doesn't exist");
                      //         }
                      //       } else {
                      //         //add to map if not already
                      //         map[payloadId] = fileName;
                      //       }
                      //     }
                      //   } else if (payload.type == PayloadType.FILE) {
                      //     showSnackbar(endid + ": File transfer started");
                      //     tempFileUri = payload.uri;
                      //   }
                    },
                    onPayloadTransferUpdate: (endid, payloadTransferUpdate) {
                      // if (payloadTransferUpdate.status ==
                      //     PayloadStatus.IN_PROGRESS) {
                      //   print(payloadTransferUpdate.bytesTransferred);
                      // } else if (payloadTransferUpdate.status ==
                      //     PayloadStatus.FAILURE) {
                      //   print("failed");
                      //   showSnackbar(endid + ": FAILED to transfer file");
                      // } else if (payloadTransferUpdate.status ==
                      //     PayloadStatus.SUCCESS) {
                      //   showSnackbar(
                      //       "$endid success, total bytes = ${payloadTransferUpdate.totalBytes}");

                      //   if (map.containsKey(payloadTransferUpdate.id)) {
                      //     //rename the file now
                      //     String name = map[payloadTransferUpdate.id]!;
                      //     moveFile(tempFileUri!, name);
                      //   } else {
                      //     //bytes not received till yet
                      //     map[payloadTransferUpdate.id] = "";
                      //   }
                      // }
                    },
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
