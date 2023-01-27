import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  User? user = FirebaseAuth.instance.currentUser;
  late final String currEmail = user?.email.toString() ?? "null";
  final Strategy strategy = Strategy.P2P_STAR;
  Map<String, ConnectionInfo> endpointMap = Map();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Student HomePage"),
        ),
        body: Center(
            child: Column(children: [
          ElevatedButton(
            child: const Text("Start Discovery"),
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
                bool a = await Nearby().startDiscovery(
                  currEmail,
                  strategy,
                  onEndpointFound: (id, name, serviceId) {
                    print(id);
                    print(name);
                    print(serviceId);
                    Nearby().requestConnection(
                      currEmail,
                      id,
                      onConnectionInitiated: (id, info) {
                        onConnectionInit(id, info);
                      },
                      onConnectionResult: (id, status) async {
                        showSnackbar(status);
                        try {
                          FirebaseFirestore.instance
                              .collection(DateTime(DateTime.now().year,
                                      DateTime.now().month, DateTime.now().day)
                                  .toString()
                                  .replaceAll("00:00:00.000", ""))
                              .doc('Maths')
                              .update({
                            //append currmail to email key
                            'email': FieldValue.arrayUnion([currEmail])
                          });
                        } on FirebaseAuthException catch (e) {
                          print("Error $e");
                        }
                        showSnackbar("Attendance taken!");
                        // await Nearby().stopAllEndpoints();
                        // setState(() {
                        //   endpointMap.clear();
                        // });
                      },
                      onDisconnected: (id) {
                        showSnackbar(
                            "Disconnected: ${endpointMap[id]!.endpointName}, id $id");
                        setState(() {
                          endpointMap.remove(id);
                        });
                      },
                    );
                  },
                  onEndpointLost: (id) {
                    showSnackbar(
                        "Lost discovered Endpoint: ${endpointMap[id]!.endpointName}, id $id");
                  },
                );
                showSnackbar("DISCOVERING: " + a.toString());
              } catch (e) {
                showSnackbar(e);
              }
            },
          ),
          ElevatedButton(
            child: const Text("Stop Discovery"),
            onPressed: () async {
              await Nearby().stopDiscovery();
            },
          ),
          Text("Number of connected devices: ${endpointMap.length}"),
          // ElevatedButton(
          //   child: Text("Stop All Endpoints"),
          //   onPressed: () async {
          //     await Nearby().stopAllEndpoints();
          //     setState(() {
          //       endpointMap.clear();
          //     });
          //   },
          // ),
        ])));
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
    print("id: $id");
    print("Token: ${info.authenticationToken}");
    print("Name: ${info.endpointName}");
    setState(() {
      endpointMap[id] = info;
    });
    Nearby().acceptConnection(
      id,
      onPayLoadRecieved: (endid, payload) {},
      onPayloadTransferUpdate: (endid, payloadTransferUpdate) {},
    );
    // showModalBottomSheet(
    //   context: context,
    //   builder: (builder) {
    //     return Center(
    //       child: Column(
    //         children: <Widget>[
    //           Text("id: $id"),
    //           Text("Token: ${info.authenticationToken}"),
    //           Text("Name: ${info.endpointName}"),
    //           Text("Incoming: " + info.isIncomingConnection.toString()),
    //           ElevatedButton(
    //             child: Text("Accept Connection"),
    //             onPressed: () {
    //               Navigator.pop(context);
    //               setState(() {
    //                 endpointMap[id] = info;
    //               });
    //               Nearby().acceptConnection(
    //                 id,
    //                 onPayLoadRecieved: (endid, payload) async {},
    //                 onPayloadTransferUpdate: (endid, payloadTransferUpdate) {},
    //               );
    //             },
    //           ),
    //         ],
    //       ),
    //     );
    //   },
    // );
  }
}
