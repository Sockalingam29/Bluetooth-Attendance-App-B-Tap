import 'package:att_blue/models/sub.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ItemList extends StatelessWidget {
  ItemList({
    Key? key,
    // required Subdetails subdet,
  }) : super(key: key) {
    _stream = _referenceStudentList.snapshots();
  }
  final CollectionReference _referenceStudentList =
      FirebaseFirestore.instance.collection('Maths');

  //_reference.get()  ---> returns Future<QuerySnapshot>
  //_reference.snapshots()--> Stream<QuerySnapshot> -- realtime updates
  late Stream<QuerySnapshot> _stream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Students'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            //Check error
            if (snapshot.hasError) {
              return Center(
                  child: Text('Some error occurred ${snapshot.error}'));
            }

            //Check if data arrived
            if (snapshot.hasData) {
              //get the data
              QuerySnapshot querySnapshot = snapshot.data;
              List<QueryDocumentSnapshot> documents = querySnapshot.docs;

              //Convert the documents to Maps
              List<Map> items = documents
                  .map((e) => {
                        'Name': e['Reg_No'],
                      })
                  .toList();

              //Display the list
              return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    //Get the item at this index
                    Map thisItem = items[index];
                    //REturn the widget for the list items
                    return ListTile(
                      title: Text('${thisItem['Name']}'),
                    );
                  });
            }
            //Show loader
            return const Center(child: CircularProgressIndicator());
          },
        ));
//Display a list // Add a FutureBuilder
  }
}
