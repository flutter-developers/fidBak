import 'package:fidbak/Services/AuthManagement.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String email = '';
  Auth auth;
  final formKey = new GlobalKey<FormState>();

  // Form validation
  validateAndSave() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  validateAndSubmit() async {
    FocusScope.of(context).unfocus();
    if (validateAndSave()) {
      await auth.resetPassword(email);
    }
  }
  
  @override
  void initState() {
    super.initState();
    auth = new Auth(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Container(
        margin: EdgeInsets.all(15),
        child: Container(
          margin: EdgeInsets.all(15),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: resetForm(),
            ),
          ),
        ),
      ),
    );
  }

  resetForm() {
    double width = MediaQuery.of(context).size.width;
    return <Widget>[
      TextFormField(
        decoration: InputDecoration(
            labelText: 'Email', suffixIcon: Icon(MdiIcons.email)),
        keyboardType: TextInputType.emailAddress,
        onChanged: (value) {
          email = value;
        },
        validator: (value) {
          return value.isEmpty ? "Email is required" : null;
        },
      ),
      SizedBox(height: 15),
      SizedBox(
        width: width,
        child: RaisedButton(
          color: Colors.blue,
          child: Text('Reset password', style: TextStyle(color: Colors.white)),
          onPressed: validateAndSubmit,
        ),
      ),
    ];
  }
}
