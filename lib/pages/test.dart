import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  // Data for the dropdowns
  List<String> _semesters = ['Semester 1', 'Semester 2', 'Semester 3'];
  List<String> _subjects = ['Maths', 'Science', 'English'];

  // Selected values
  late String _selectedSemester = "Semester 1";
  late String _selectedSubject = "Maths";
  // late DateTime _selectedDate="";

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Page'),
      ),
      body: Stack(
        children: [
          // Background image

          // Form elements
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Semester dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Choose Semester',
                      ),
                      value: _selectedSemester,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedSemester = newValue!;
                        });
                      },
                      items: _semesters.map((semester) {
                        return DropdownMenuItem(
                          value: semester,
                          child: Text(semester),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16.0),
                    // Subject dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Choose Subject',
                      ),
                      value: _selectedSubject,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedSubject = newValue!;
                        });
                      },
                      items: _subjects.map((subject) {
                        return DropdownMenuItem(
                          value: subject,
                          child: Text(subject),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16.0),
                    // Date input
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Choose Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        // final DateTime picked = await showDatePicker(
                        //   context: context,
                        //   initialDate: DateTime.now(),
                        //   firstDate: DateTime(2015, 8),
                        //   lastDate: DateTime(2101),
                        // );
                        // if (picked != null) {
                        //   setState(() {
                        //     _selectedDate = picked;
                        //   });
                        // }
                      },
                      validator: (value) {
                        // if (_selectedDate == null) {
                        //   return 'Please choose a date';
                        // } else {
                        //   return null;
                        // }
                      },
                    ),
                    SizedBox(height: 16.0),
                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // if (_formKey.currentState?.validate()) {
                            //   // Perform action on button press
                            // }
                          },
                          child: Text('Save'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Perform action on button press
                          },
                          child: Text('Reset'),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.grey[400],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Perform action on button press
                          },
                          child: Text('Cancel'),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
