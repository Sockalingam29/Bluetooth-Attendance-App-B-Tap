// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:att_blue/components/checkmark.dart';
import 'package:att_blue/components/rippleEffect/ripple_animation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter/animations.dart'

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int flag = 0;
  User? user = FirebaseAuth.instance.currentUser;
  late final String currEmail = user?.email.toString() ?? "null";

  final Strategy strategy = Strategy.P2P_STAR;
  Map<String, ConnectionInfo> endpointMap = {};

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await Nearby().stopDiscovery();
        setState(() {
          flag = 0;
        });
        // Allow the app to be closed
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Student HomePage",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.deepPurple,
            actions: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: GestureDetector(
                  onTap: () async {
                    await Nearby().stopDiscovery();
                    await FirebaseAuth.instance.signOut();
                    Get.offNamed('/login');
                  },
                  child:
                      const Icon(Icons.logout_sharp, color: Colors.deepPurple),
                ),
              )
            ],
          ),
          body: Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                if (flag == 0)
                  GestureDetector(
                    onTap: endPointFoundHandler,
                    child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Column(
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(20),
                                    margin: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: const Offset(0,
                                              3), // changes position of shadow
                                        )
                                      ],
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(72),
                                    ),
                                    child: const Icon(Icons.bluetooth,
                                        size: 84, color: Colors.white)),
                              ],
                            ),
                            const Text(
                              "Tap to mark attendance",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            )
                          ],
                        )),
                  )
                else if (flag == 1)
                  RipplesAnimation(
                    onPressed: () async {
                      print("Ripple Animation");
                      await Nearby().stopDiscovery();
                      setState(() {
                        flag = 0;
                      });
                    },
                    child: const Text("data"),
                  )
                else if (flag == 2)
                  Center(
                    child: Column(
                      children: [
                        const CheckMarkPage(),
                        const SizedBox(height: 10),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Attendance recorded!",
                                style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                            onPressed: () {
                              setState(() {
                                flag = 0;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  const Color.fromARGB(255, 103, 58, 183),
                              minimumSize: const Size(100, 60),
                              maximumSize: const Size(150, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32.0),
                              ),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 8),
                                Icon(Icons.logout,
                                    size: 26, color: Colors.white),
                                SizedBox(width: 10),
                                Text("Back", style: TextStyle(fontSize: 18)),
                              ],
                            )),
                      ],
                    ),
                  ),
              ]))),
    );
  }

  void endPointFoundHandler() async {
    if (!await Nearby().askLocationPermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permissions not granted :(")));
    }

    if (!await Nearby().enableLocationServices()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enabling Location Service Failed :(")));
    }

    await Permission.nearbyWifiDevices.request();

    Nearby().askBluetoothPermission();

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

    // if (!await Nearby().checkBluetoothPermission()) {
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //       content: Text("Bluetooth permissions not granted :(")));
    // }

    // while (!await Permission.nearbyWifiDevices.isGranted) {
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //       content: Text("NearbyWifiDevices permissions not granted :(")));
    // }

    setState(() {
      flag = 1;
    });

    try {
      bool a = await Nearby().startDiscovery(
        currEmail,
        strategy,
        onEndpointFound: (id, name, serviceId) async {
          print("endpoint found");
          print(name);
          // print("Found endpoint: $id, $name, $serviceId");
          if (name.startsWith("TCE_Faculty")) {
            try {
              // add if not exists, else update
              // TCE_Facutly semester 1 oops A
              List<String> arr = name.split(" ");

              String sem = "${arr[1]} ${arr[2]}";
              String sub = arr[3];
              String slot = arr[4];

              print("STUDENT $sem $sub $slot");

              var studentDB = await FirebaseFirestore.instance
                  .collection("Student")
                  .doc('$sem Slot $slot');
              var studentData = await studentDB.get();
              // check if curr user's email is present in studentData
              bool isStudent = false;
              if (studentData.exists) {
                List<dynamic> emailList = studentData['Students'];
                print(emailList);
                for (int i = 0; i < emailList.length; i++) {
                  if (emailList[i]['Email'] == currEmail) {
                    isStudent = true;
                    break;
                  }
                }
              }
              if (isStudent) {
                DateTime now = DateTime.now();
                String formattedDate =
                    '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

                var db = FirebaseFirestore.instance
                    .collection(formattedDate)
                    .doc("$sem Slot $slot");
                var data = await db.get();

                if (!data.exists) {
                  db.set({
                    '$sub': FieldValue.arrayUnion([currEmail]),
                  });
                } else {
                  db.update({
                    '$sub': FieldValue.arrayUnion([currEmail]),
                  });
                }
                await Nearby().stopDiscovery();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Attendance recorded!! :)")));
                setState(() {
                  flag = 2;
                });
              }
            } on FirebaseAuthException catch (e) {
              print("Error $e");
            } catch (e) {
              showSnackbar("Error: $e");
            }
          }
        },
        onEndpointLost: (id) {
          showSnackbar(
              "Lost discovered Endpoint: ${endpointMap[id]!.endpointName}, id $id");
        },
      );
      showSnackbar("DISCOVERING: $a");
    } catch (e) {
      // print on console
      print("Error: $e");
      setState(() {
        flag = 0;
      });
      showSnackbar(e);
    }
  }

  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }
}
