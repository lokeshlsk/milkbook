import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cricket_scorer/firestore/db.dart';
import 'package:flutter/material.dart';

String dateToString(DateTime date) {
  return "${date.day}/${date.month}/${date.year}";
}

decoration(String name) {
  return InputDecoration(
    labelText: name,
  );
}

class AddNewCustomer extends StatefulWidget {
  @override
  _AddNewCustomerState createState() => _AddNewCustomerState();
}

class _AddNewCustomerState extends State<AddNewCustomer> {
  static DateTime date = DateTime.now();
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController dateController =
      TextEditingController(text: dateToString(date));
  TextEditingController nameController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  bool isLoading = false;

  void chooseDate(BuildContext context) async {
    DateTime tdate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (tdate != null) {
      setState(() {
        date = tdate;
        dateController.text = dateToString(date);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(date);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "Add Customer",
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formkey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: decoration(
                      "name",
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value.isEmpty) return "name is required";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: notesController,
                    decoration: decoration(
                      "notes",
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value.isEmpty) return "notes is required";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: dateController,
                    showCursor: false,
                    onTap: () {
                      chooseDate(context);
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formkey.currentState.validate()) {
                        setState(() {
                          isLoading = true;
                        });
                        Map<String, dynamic> customerData = {
                          "name": nameController.text,
                          "startDate": Timestamp.fromDate(date)
                        };
                        Map<String, dynamic> notesData = {
                          "date": Timestamp.fromDate(date),
                          "data": notesController.text,
                        };

                        await FirestoreService.createNewCustomer(
                            customerData, notesData);
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'Add',
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
