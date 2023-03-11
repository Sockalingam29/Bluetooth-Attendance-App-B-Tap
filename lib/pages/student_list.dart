// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:developer';

import 'package:att_blue/models/sub.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentList extends StatefulWidget {
  const StudentList({super.key});

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  var userCollection = FirebaseFirestore.instance.collection('Users');

  late List<Map<String, dynamic>> _studentList;
  bool isLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student List')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () async {
                  List<Map<String, dynamic>> tmp = [];
                  var data = await userCollection.get();
                  data.docs.forEach((element) {
                    if (element.data()['Role'] == 'Student') {
                      tmp.add(element.data());
                    }
                    // log("element.data()");
                  });
                  // tmp.forEach((element) {log(element['Name']);});
                  setState(() {
                    _studentList = tmp;
                    isLoaded = true;
                  });
                },
                child: const Text('List Users')),
            const SizedBox(height: 30),
            if (isLoaded)
              const Text(
                "Present Students: ",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.left,
              ),
            if (isLoaded)
              Expanded(
                  // child: ListView.builder(
                  //     itemCount: _studentList.length,
                  //     itemBuilder: (context, index) {
                  //       return ListTile(
                  //         title: Text(_studentList[index]['Name']),
                  //         subtitle: Text(_studentList[index]['Register number']),
                  //       );
                  //     }),
                  child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: ListView.separated(
                  itemCount: _studentList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(_studentList[index]['Name']),
                      subtitle: Text(_studentList[index]['Register number']),
                      tileColor: const Color.fromARGB(255, 168, 197, 219),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      color: Colors.black,
                    );
                  },
                ),
              ))
          ],
        ),
      ),
    );
  }
}
