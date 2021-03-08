import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cricket_scorer/firestore/db.dart';
import 'package:cricket_scorer/screens/addNew_customer_dialog.dart';
import 'package:cricket_scorer/screens/customer_info.dart';
import 'package:flutter/material.dart';

String convertedDate(Timestamp timestamp) {
  DateTime date = timestamp.toDate();
  return "${date.day}/${date.month}/${date.year}";
}

class CustomerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Customer List',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return AddNewCustomer();
              },
              fullscreenDialog: true,
            ),
          );
        },
        child: Icon(
          Icons.add,
        ),
      ),
      body: StreamBuilder(
        stream: FirestoreService.customerList,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text("Loading"));
          }

          if (snapshot.data.size == 0) {
            return Text("No Customers");
          }

          List<QueryDocumentSnapshot> documents = snapshot.data.docs;
          return ListView.separated(
            itemBuilder: (context, index) => ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return CustomerInfo(documents[index]);
                    },
                  ),
                );
              },
              title: Text(
                '${documents[index].data()['name']}',
              ),
              subtitle: Text(
                  '${convertedDate(documents[index].data()['startDate'])}'),
            ),
            separatorBuilder: (context, index) => Divider(),
            itemCount: documents.length,
          );
        },
      ),
    );
  }
}
