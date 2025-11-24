// screens/signin_screen.dart
import 'package:flutter/material.dart';

import 'package:zottz_otone/device_scan_activity.dart';
import 'package:zottz_otone/firebase_service.dart';
// import '../services/firebase_service.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<String> _usernames = [];
  String? _selectedUsername;

  @override
  void initState() {
    super.initState();
    _loadUsernames();
  }

  Future<void> _loadUsernames() async {
    try {
      final usernames = await _firebaseService.getAllUsernames();
      setState(() {
        _usernames = usernames;   
        if (_usernames.isNotEmpty) {
          _selectedUsername = _usernames.first;
        }
      });
    } catch (e) {
      print('Error loading usernames: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                _firebaseService.getAllUsernames();
              }, 
              child: Text("test")
            ),
            DropdownButtonFormField<String>(
              value: _selectedUsername,
              items: _usernames.map((String username) {
                return DropdownMenuItem<String>(
                  value: username,
                  child: Text(username),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedUsername = newValue;
                });
              },
              decoration: InputDecoration(labelText: 'Select User'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signIn,
              child: Text('Sign In'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: Text('Create New User'),
            ),
          ],
        ),
      ),
    );
  }

  void _signIn() {
    if (_selectedUsername != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DeviceScanActivity(username: _selectedUsername!),
          settings: RouteSettings(arguments: _selectedUsername),
        ),
      );
    }
  }
}