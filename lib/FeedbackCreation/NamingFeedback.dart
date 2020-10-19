import 'dart:io';

import 'package:fidbak/FeedbackCreation/CreateFeedback.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path/path.dart' as p;

class NamingFeedback extends StatefulWidget {
  @override
  _NamingFeedbackState createState() => _NamingFeedbackState();
}

class _NamingFeedbackState extends State<NamingFeedback> {
  final formKey = new GlobalKey<FormState>();
  String name;
  String type;
  String host;
  bool keyIdxFound = false;
  bool fileNeeded = false;
  File file;
  List<String> types = ['Workshop', 'Training', 'Seminar', 'Faculty'];
  List<String> emails = new List<String>();

  // Form validators
  validateAndSave() {
    final form = formKey.currentState;

    if (form.validate() && fileNeeded && file == null) {
      return false;
    }

    if (fileNeeded && !keyIdxFound) return false;

    if (form.validate() && type != null) {
      form.save();
      return true;
    }
    return false;
  }

  validateAndSubmit() async {
    if (validateAndSave()) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateFeedback(
                host: host, name: name, type: type, allAttenders: emails),
          ));
    } else {
      Fluttertoast.showToast(msg: 'Form not filled properly');
    }
  }

  @override
  void initState() {
    super.initState();
    name = '';
    host = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Host new feedback')),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(15),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: creationForm(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> creationForm() {
    return <Widget>[
      TextFormField(
        decoration: InputDecoration(labelText: 'Name of the feedback'),
        validator: (value) => value.isEmpty ? "This field is required" : null,
        onSaved: (value) => name = value,
      ),
      SizedBox(height: 15),
      TextFormField(
        decoration: InputDecoration(labelText: 'Host name'),
        validator: (value) => value.isEmpty ? "This field is required" : null,
        onSaved: (value) => host = value,
      ),
      SizedBox(height: 25),
      Text(
        'What is the feedback for?',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      SizedBox(height: 15),
      RadioButtonGroup(
        labels: ["Workshop", "Training", "Seminar", "Faculty"],
        onSelected: (value) {
          type = value;
        },
      ),
      SizedBox(
        height: 15,
      ),
      CheckboxGroup(
        labels: ['Restrict feedback to limited users'],
        onSelected: (list) {
          setState(() {
            fileNeeded = list.isNotEmpty;
            if (!fileNeeded) {
              // Admin lifted restriction on feedback, so clear the emails list and file
              file = null;
              emails.clear();
            }
          });
        },
      ),
      SizedBox(
        height: 15,
      ),
      fileNeeded
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    MdiIcons.attachment,
                    size: 40,
                  ),
                  color: Colors.blue,
                  onPressed: () async {
                    await setEmailsFromExcel();
                  },
                ),
                SizedBox(width: 15),
                file == null
                    ? Text('Pick an excel sheet')
                    : Expanded(
                        child: Text(
                        p.basename(file.path),
                        overflow: TextOverflow.clip,
                      ))
              ],
            )
          : SizedBox(
              height: 1,
            ),
      SizedBox(
        height: 15,
      ),
      RaisedButton(
        child: Text(
          'Next',
          style: TextStyle(color: Colors.white),
        ),
        color: Colors.blue,
        onPressed: validateAndSubmit,
      ),
    ];
  }

  // Logic always below the UI code or in utility files
  setEmailsFromExcel() async {
    file = await FilePicker.getFile(
        type: FileType.custom, allowedExtensions: ['xlsx']);

    // This reloads the page to render file picker UI
    setState(() {
      file = file;
    });

    // User picked the file
    if (file != null) {
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes, update: true);
      var sheet = excel.tables.keys.first; // Sheet name
      var header =
          excel.tables[sheet].rows.elementAt(0); // Header row in excel sheet
      var table = excel.tables[sheet]
          .rows; // Converting entire excel into matrix(Map techincally)
      var totalRows = excel.tables[sheet].maxRows;

      int colIdx = 0; // Variable that holds index of mail IDs
      keyIdxFound = false;
      for (var colName in header) {
        if (colName.toString().toLowerCase().contains('mail')) {
          keyIdxFound = true;
          break;
        }
        colIdx++;
      }

      // Pushing all the mail IDs
      for (int rowIdx = 1; rowIdx < totalRows; rowIdx++) {
        emails.add(table[rowIdx][colIdx]);
      }
    }
  }
}
