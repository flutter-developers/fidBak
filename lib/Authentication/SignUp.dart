import 'package:fidbak/Services/AuthManagement.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formKey = new GlobalKey<FormState>();
  String email = '', name = '', password = '';
  bool isHidden = true;
  Auth auth;

  // Form validators
  validateAndSave() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    }
    // Form is not filled properly, so return false
    return false;
  }

  validateAndSubmit() async {
    // Takes keyboard out of focus
    FocusScope.of(context).unfocus();
    if (validateAndSave()) {
      await auth.signUp(name.trim(), email.trim(), password.trim());
    }
  }

  @override
  void initState() {
    super.initState();
    // Create Auth object for accessing authentication services
    auth = Auth(context);
  }

  // UI Code starts
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(15),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: registerForm(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> registerForm() {
    double width = MediaQuery.of(context).size.width;
    return <Widget>[
      TextFormField(
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            labelText: 'Name', suffixIcon: Icon(MdiIcons.account)),
        validator: (value) {
          return value.isEmpty ? "Name is required" : null;
        },
        onSaved: (value) => name = value,
      ),
      SizedBox(
        height: 15,
      ),
      TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            labelText: 'Email', suffixIcon: Icon(MdiIcons.email)),
        validator: (value) {
          return value.isEmpty ? "Email is required" : null;
        },
        onSaved: (value) => email = value,
      ),
      SizedBox(height: 15),
      TextFormField(
        decoration: InputDecoration(
            labelText: 'Password',
            suffixIcon: IconButton(
              icon: Icon(isHidden ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  isHidden = !isHidden;
                });
              },
            )),
        obscureText: isHidden,
        validator: (value) {
          if (value.isEmpty)
            return "Password is required";
          else if (value.length < 6)
            return "Password must contain atleast 6 characters";
          else
            return null;
        },
        onSaved: (value) => password = value,
      ),
      SizedBox(height: 15),
      SizedBox(
        width: width,
        child: RaisedButton(
          color: Colors.blue,
          child: Text('Sign up', style: TextStyle(color: Colors.white)),
          onPressed: validateAndSubmit,
        ),
      ),
      SizedBox(
        height: 10,
      ),
      Center(
          child: Text(
        'Make sure you verify your email before login',
        style: TextStyle(fontWeight: FontWeight.bold),
      ))
    ];
  }
}
