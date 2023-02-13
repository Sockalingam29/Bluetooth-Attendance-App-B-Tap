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
                    if (name == "TCE_Faculty") {
                      try {
                        // add if not exists, else update
                        var db = FirebaseFirestore.instance
                            .collection(DateTime(DateTime.now().year,
                                    DateTime.now().month, DateTime.now().day)
                                .toString()
                                .replaceAll("00:00:00.000", ""))
                            .doc('Maths');
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
                  //         try {
                  //   // FirebaseAuth.instance
                  //       // .createUserWithEmailAndPassword(
                  //       //     email: email, password: password)
                  //       // .then((value) => {
                  //       //       log("User created to FireAuth"),
                  //             FirebaseFirestore.instance
                  //                 .collection(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day).toString().replaceAll("00:00:00.000", ""))
                  //                 .doc('Maths')
                  //                 .set({
                  //                   //append currmail to email key
                  //                   'email': FieldValue.arrayUnion([currEmail]),

                  //               }),
                  //             // .then((value) => {
                  //             //           FirebaseAuth.instance.signOut(),
                  //             //           Get.toNamed('/login'),
                  //             //         }),
                  //             // log("Data added to Firestore")
                  //           );
                  // } on FirebaseAuthException catch (e) {
                  //   print("Error $e");
                  //   setState(() {
                  //     errorMsg = e.message;
                  //   });
                  // }
                  //       })
                  //         // show sheet automatically to request connection
                  //         // Firebase
                  //       //   showModalBottomSheet(
                  //       //     context: context,
                  //       //     builder: (builder) {
                  //       //       return Center(
                  //       //         child: Column(
                  //       //           children: <Widget>[
                  //       //             Text("id: " + id),
                  //       //             Text("Name: " + name),
                  //       //             Text("ServiceId: " + serviceId),
                  //       //             ElevatedButton(
                  //       //               child: const Text("Request Connection"),
                  //       //               onPressed: () {
                  //       //                 Navigator.pop(context);
                  //       //                 Nearby().requestConnection(
                  //       //                   userName,
                  //       //                   id,
                  //       //                   onConnectionInitiated: (id, info) {
                  //       //                     onConnectionInit(id, info);
                  //       //                   },
                  //       //                   onConnectionResult: (id, status) {
                  //       //                     showSnackbar(status);
                  //       //                   },
                  //       //                   onDisconnected: (id) {
                  //       //                     setState(() {
                  //       //                       endpointMap.remove(id);
                  //       //                     });
                  //       //                     showSnackbar(
                  //       //                         "Disconnected from: ${endpointMap[id]!.endpointName}, id $id");
                  //       //                   },
                  //       //                 );
                  //       //               },
                  //       //             ),
                  //       //           ],
                  //       //         ),
                  //       //       );
                  //       //     },
                  //       //   );
                  //       // },
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
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Center(
          child: Column(
            children: <Widget>[
              Text("id: $id"),
              Text("Token: ${info.authenticationToken}"),
              Text("Name: ${info.endpointName}"),
              Text("Incoming: " + info.isIncomingConnection.toString()),
              ElevatedButton(
                child: Text("Accept Connection"),
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
                child: Text("Reject Connection"),
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
