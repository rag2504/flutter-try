import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';

class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  String? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _addUser() async {
    if (_formKey.currentState!.validate() && _selectedGender != null) {
      int age = int.parse(_ageController.text);
      if (age < 18) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Age must be 18 or above')));
        return;
      }

      User user = User(
        name: _nameController.text,
        email: _emailController.text,
        mobile: _mobileController.text,
        age: age,
        city: _cityController.text,
        gender: _selectedGender!,
      );

      await _dbHelper.insertUser(user);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User Added!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add User')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                  validator: (value) => RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
                      .hasMatch(value!) ? null : 'Enter a valid email',
                ),
                TextFormField(
                  controller: _mobileController,
                  decoration: InputDecoration(labelText: 'Mobile Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.length == 10 ? null : 'Enter a valid 10-digit number',
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  validator: (value) => int.tryParse(value!) != null ? null : 'Enter a valid age',
                ),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(labelText: 'City'),
                  validator: (value) => value!.isEmpty ? 'Enter city' : null,
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
                ElevatedButton(onPressed: _addUser, child: Text('Add User')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
