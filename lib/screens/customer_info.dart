import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cricket_scorer/firestore/db.dart';
import 'package:cricket_scorer/screens/add_new_data.dart';
import 'package:flutter/material.dart';

String convertedDate(Timestamp timestamp) {
  DateTime date = timestamp.toDate();
  return "${date.day}/${date.month}/${date.year}";
}

String dateToString(DateTime date) {
  return "${date.day}/${date.month}/${date.year}";
}

class CustomerInfo extends StatefulWidget {
  final DocumentSnapshot document;
  CustomerInfo(this.document);
  @override
  _CustomerInfoState createState() => _CustomerInfoState();
}

class _CustomerInfoState extends State<CustomerInfo> {
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController newDataDateController = TextEditingController();
  DateTime startDate;
  DateTime endDate = DateTime.now();
  bool filterList = false;
  bool isLoading = false;

  @override
  void initState() {
    startDateController.text = convertedDate(widget.document['startDate']);
    startDate = widget.document['startDate'].toDate();
    endDateController.text = dateToString(DateTime.now());
    super.initState();
  }

  void chooseDate(BuildContext context, {bool isStart}) async {
    DateTime tdate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (tdate != null) {
      setState(() {
        if (isStart) {
          startDate = tdate;
          startDateController.text = dateToString(tdate);
        } else {
          endDate = tdate;
          endDateController.text = dateToString(tdate);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final DocumentSnapshot document = widget.document;

    Widget regularList() {
      return StreamBuilder(
        stream: FirestoreService.customerNotesList(document),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text("Loading"));
          }

          if (snapshot.data.size == 0) {
            return Center(child: Text("No deliveries"));
          }

          List<QueryDocumentSnapshot> documents = snapshot.data.docs;
          return ListView.separated(
            itemBuilder: (context, index) => ListTile(
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });

                  await FirestoreService.deleteDocument(
                      documents[index].reference);
                  setState(() {
                    isLoading = false;
                  });
                },
              ),
              title: Text(
                '${documents[index].data()['data']}',
              ),
              subtitle:
                  Text('${convertedDate(documents[index].data()['date'])}'),
            ),
            separatorBuilder: (context, index) => Divider(),
            itemCount: documents.length,
          );
        },
      );
    }

    Widget filteredList() {
      return StreamBuilder(
        stream: FirestoreService.filteredData(document,
            Timestamp.fromDate(startDate), Timestamp.fromDate(endDate)),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text("Loading"));
          }

          if (snapshot.data.size == 0) {
            return Center(child: Text("No deliveries"));
          }

          List<QueryDocumentSnapshot> documents = snapshot.data.docs;
          return ListView.separated(
            itemBuilder: (context, index) => ListTile(
              title: Text(
                '${documents[index].data()['data']}',
              ),
              subtitle:
                  Text('${convertedDate(documents[index].data()['date'])}'),
            ),
            separatorBuilder: (context, index) => Divider(),
            itemCount: documents.length,
          );
        },
      );
    }

    List<Widget> filter() {
      return [
        TextField(
          controller: startDateController,
          showCursor: false,
          onTap: () {
            chooseDate(context, isStart: true);
          },
        ),
        Center(
          child: Text(
            "to",
          ),
        ),
        TextField(
          controller: endDateController,
          showCursor: false,
          onTap: () {
            chooseDate(context, isStart: false);
          },
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              filterList = true;
            });
          },
          child: Text(
            'filter',
          ),
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${document['name']}',
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                ...filter(),
                Expanded(
                  child: filterList ? filteredList() : regularList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return AddNewData(document);
            },
          ));
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}
