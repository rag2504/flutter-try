import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import '../database/database_helper.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();
  String _email = '';
  String _password = '';

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      bool isValid = await _dbHelper.validateUser(_email, _password);

      if (isValid) {
        print('Login successful'); // Debugging statement
        await Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Invalid email or password!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                value!.isEmpty || !value.contains('@') ? 'Enter a valid email' : null,
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Enter your password' : null,
                onSaved: (value) => _password = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _login, child: Text('Login')),
              TextButton(
                child: Text("Don't have an account? Sign Up"),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => SignUpScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}