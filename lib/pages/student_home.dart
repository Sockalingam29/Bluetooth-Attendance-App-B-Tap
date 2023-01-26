import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final String userName = Random().nextInt(10000).toString();
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
                  userName,
                  strategy,
                  onEndpointFound: (id, name, serviceId) {
                    // show sheet automatically to request connection

                    showModalBottomSheet(
                      context: context,
                      builder: (builder) {
                        return Center(
                          child: Column(
                            children: <Widget>[
                              Text("id: " + id),
                              Text("Name: " + name),
                              Text("ServiceId: " + serviceId),
                              ElevatedButton(
                                child: Text("Request Connection"),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Nearby().requestConnection(
                                    userName,
                                    id,
                                    onConnectionInitiated: (id, info) {
                                      onConnectionInit(id, info);
                                    },
                                    onConnectionResult: (id, status) {
                                      showSnackbar(status);
                                    },
                                    onDisconnected: (id) {
                                      setState(() {
                                        endpointMap.remove(id);
                                      });
                                      showSnackbar(
                                          "Disconnected from: ${endpointMap[id]!.endpointName}, id $id");
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        );
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
