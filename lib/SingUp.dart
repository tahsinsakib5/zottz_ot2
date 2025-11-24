// screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:zottz_otone/firebase_datamodel.dart';
import 'package:zottz_otone/firebase_service.dart';
import 'package:zottz_otone/sign_inscrean.dart';
// import '../services/firebase_service.dart';
// import '../utils/date_utils.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'User Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter user name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'User Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter user age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        String name = _nameController.text;
        bool nameAvailable = await _firebaseService.isUsernameAvailable(name);
        
        if (nameAvailable) {
          int age = int.parse(_ageController.text);
          // String currentDate = DateUtils.getCurrentDate();

          String currentDate = DateTime.now().toIso8601String().split('T').first;
          
          UserInformation userInfo = UserInformation(
            userName: name,
            userAge: age,
            scissor: 0,
            pencil: 0,
            pincher: 0,
            button: 0,
            sessionDate: currentDate,
            timer: 0,
            createdAt: DateTime.now(),
          );
          
          await _firebaseService.addUserInformation(userInfo);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignInScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Username not available')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}