// ignore_for_file: use_build_context_synchronously

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
              // _logOutBtn(),
            ],
          ),
        ),
      ),
    );
  }
}
