// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

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
          actions: [
            GestureDetector(
                child: const Icon(Icons.logout_sharp),
                onTap: () async {
                  await Nearby().stopDiscovery();
                  await FirebaseAuth.instance.signOut();
                  Get.toNamed('/login');
                }),
          ],
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
                  onEndpointFound: (id, name, serviceId) async {
                    print("endpoint found");
                    print(name);
                    print("Found endpoint: $id, $name, $serviceId");
                    if (name.startsWith("TCE_Faculty")) {
                      try {
                        // add if not exists, else update
                        var db = FirebaseFirestore.instance
                            .collection(DateTime(DateTime.now().day,DateTime.now().month,DateTime.now().year)
                                .toString()
                                .replaceAll("00:00:00.000", ""))
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
                            const SnackBar(
                                content: Text("Attendance recorded!! :)")));
                      } on FirebaseAuthException catch (e) {
                        print("Error $e");
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
            },
          ),
          ElevatedButton(
            child: const Text("Stop Discovery"),
            onPressed: () async {
              await Nearby().stopDiscovery();
            },
          ),
        ])));
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
