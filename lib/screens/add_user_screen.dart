import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';

class AddUserScreen extends StatefulWidget {
  final User? user;

  AddUserScreen({this.user});

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  String? _selectedGender;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _firstNameController.text = widget.user!.name.split(' ')[0];
      _lastNameController.text = widget.user!.name.split(' ').length > 1 ? widget.user!.name.split(' ')[1] : '';
      _emailController.text = widget.user!.email;
      _mobileController.text = widget.user!.mobile;
      _dobController.text = DateFormat('dd/MM/yyyy').format(DateTime.now().subtract(Duration(days: 365 * widget.user!.age)));
      _passwordController.text = widget.user!.password;
      _confirmPasswordController.text = widget.user!.password;
      _selectedGender = widget.user!.gender;
      _cityController.text = widget.user!.city;
      if (widget.user!.profileImagePath != null) {
        _profileImage = File(widget.user!.profileImagePath!);
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a valid name';
    }
    if (value.contains(' ') || value.contains(RegExp(r'[^a-zA-Z]'))) {
      return 'Name cannot contain spaces or special characters';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[!@#\$&*~]).{6,}$').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter and one special character';
    }
    return null;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _addUser() async {
    if (_formKey.currentState!.validate() && _selectedGender != null) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match')));
        return;
      }

      DateTime dob = DateFormat('dd/MM/yyyy').parse(_dobController.text);
      int age = DateTime.now().year - dob.year;
      if (age < 18) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Age must be 18 or above')));
        return;
      }

      User user = User(
        name: '${_firstNameController.text} ${_lastNameController.text}',
        email: _emailController.text,
        mobile: _mobileController.text,
        age: age,
        city: _cityController.text,
        gender: _selectedGender!,
        password: _passwordController.text,
        profileImagePath: _profileImage?.path,
      );

      int result;
      if (widget.user == null) {
        result = await _dbHelper.insertUser(user);
      } else {
        user.id = widget.user!.id;
        result = await _dbHelper.updateUser(user);
      }

      if (result != -1) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User ${widget.user == null ? 'Added' : 'Updated'}!')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to ${widget.user == null ? 'add' : 'update'} user.')));
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(Duration(days: 365 * 18)),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Add User' : 'Edit User'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade200, Colors.teal.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                      child: _profileImage == null ? Icon(Icons.add_a_photo, size: 50) : null,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(_firstNameController, 'First Name', _validateName),
                _buildTextField(_lastNameController, 'Last Name', _validateName),
                _buildTextField(_emailController, 'Email', (value) => RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$").hasMatch(value!) ? null : 'Enter a valid email'),
                _buildPasswordField(_passwordController, 'Password', _isPasswordVisible, () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                }),
                _buildPasswordField(_confirmPasswordController, 'Confirm Password', _isConfirmPasswordVisible, () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                }),
                _buildTextField(_mobileController, 'Mobile Number', (value) => value!.length == 10 ? null : 'Enter a valid 10-digit number', keyboardType: TextInputType.phone, maxLength: 10),
                _buildTextField(_cityController, 'City', (value) => value == null || value.isEmpty ? 'Enter city' : null),
                _buildDateField(_dobController, 'Date of Birth', 'DD/MM/YYYY'),
                _buildDropdownField(),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _addUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreenAccent,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text(widget.user == null ? 'Add User' : 'Update User'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, String? Function(String?) validator, {TextInputType keyboardType = TextInputType.text, int maxLength = 100}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
        ),
        validator: validator,
        keyboardType: keyboardType,
        maxLength: maxLength,
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String labelText, bool isPasswordVisible, VoidCallback onSuffixIconPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          suffixIcon: IconButton(
            icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: onSuffixIconPressed,
          ),
        ),
        validator: _validatePassword,
        obscureText: !isPasswordVisible,
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String labelText, String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ),
        readOnly: true,
        validator: (value) => value!.isEmpty ? 'Enter date of birth' : null,
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        items: ['Male', 'Female', 'Other'].map((gender) {
          return DropdownMenuItem(value: gender, child: Text(gender));
        }).toList(),
        onChanged: (value) => setState(() => _selectedGender = value),
        decoration: InputDecoration(
          labelText: 'Gender',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
        ),
        validator: (value) => value == null ? 'Select gender' : null,
      ),
    );
  }
}