import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';
import '../utils/validations.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedGender;

  void _registerUser() async {
    if (_formKey.currentState!.validate() && _selectedGender != null) {
      User user = User(
        name: _nameController.text,
        email: _emailController.text,
        mobile: _mobileController.text,
        age: 18, // Default age (to be changed in Add User form)
        city: '',
        gender: _selectedGender!,
      );
      await _dbHelper.insertUser(user);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User Registered!')));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

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
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) => value!.isEmpty ? 'Enter full name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: Validations.validateEmail,
              ),
              TextFormField(
                controller: _mobileController,
                decoration: InputDecoration(labelText: 'Mobile Number'),
                validator: Validations.validateMobile,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: Validations.validatePassword,
              ),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: ['Male', 'Female', 'Other'].map((gender) {
                  return DropdownMenuItem(value: gender, child: Text(gender));
                }).toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
                decoration: InputDecoration(labelText: 'Gender'),
                validator: (value) => value == null ? 'Select gender' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _registerUser, child: Text('Sign Up')),
              TextButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen())),
                child: Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
