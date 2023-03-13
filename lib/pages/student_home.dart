// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:att_blue/components/rippleEffect/ripple_animation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:get/get.dart';
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
    return Scaffold(
        appBar: AppBar(
          title: const Text("Student HomePage"),
          actions: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: GestureDetector(
                onTap: () async {
                  await Nearby().stopDiscovery();
                  await FirebaseAuth.instance.signOut();
                  Get.toNamed('/login');
                },
                child: const Icon(Icons.logout_sharp),
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
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Start Discovery",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 20,
                      ),
                    ),
                  ),
                )
              else if (flag == 1)
                RipplesAnimation(
                  onPressed: () async {
                    await Nearby().stopDiscovery();
                    setState(() {
                      flag = 2;
                    });
                    ;
                  },
                  child: const Text("data"),
                )
              else if (flag == 2)
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 40,
                          ),
                          SizedBox(width: 10),
                          Text("Attendance recorded",
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
                                const Color.fromARGB(255, 243, 86, 33),
                            minimumSize: const Size(100, 60),
                            maximumSize: const Size(150, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                          ),
                          child: Row(
                            children: const [
                              SizedBox(width: 10),
                              Icon(Icons.logout, size: 26),
                              SizedBox(width: 10),
                              Text("Logout", style: TextStyle(fontSize: 18)),
                            ],
                          )),
                    ],
                  ),
                ),

              // ElevatedButton(
              //   child: const Text("Stop Discovery"),
              //   onPressed: () async {
              //     await Nearby().stopDiscovery();
              //   },
              // ),
            ])));
  }

  void endPointFoundHandler() async {
    setState(() {
      flag = 1;
    });
    if (!await Nearby().askLocationPermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permissions not granted :(")));
    }

    if (!await Nearby().enableLocationServices()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enabling Location Service Failed :(")));
    }

    if (!await Nearby().checkBluetoothPermission()) {
      Nearby().askBluetoothPermission();
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text("Bluetooth permissions not granted :(")));
    }

    try {
      bool a = await Nearby().startDiscovery(
        currEmail,
        strategy,
        onEndpointFound: (id, name, serviceId) async {
          print("endpoint found");
          print(name);
          print("Found endpoint: $id, $name, $serviceId");
          if (name.startsWith("TCE_Faculty")) {
            try {
              // add if not exists, else update
              DateTime now = DateTime.now();
              String formattedDate =
                  '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

              var db = FirebaseFirestore.instance
                  .collection(formattedDate)
                  .doc(name.replaceAll("TCE_Faculty ", ""));
              var data = await db.get();

              if (!data.exists) {
                db.set({
                  //append currmail to email key
                  'email': FieldValue.arrayUnion([currEmail]),
                });
              } else {
                db.update({
                  //append currmail to email key
                  'email': FieldValue.arrayUnion([currEmail]),
                });
              }

              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Attendance recorded!! :)")));
            } on FirebaseAuthException catch (e) {
              print("Error $e");
            } finally {
              print("finally");
              await Nearby().stopDiscovery();
              setState(() {
                flag = 2;
              });
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
      showSnackbar(e);
    }
  }

  void showSnackbar(dynamic a) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(a.toString()),
    ));
  }

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
