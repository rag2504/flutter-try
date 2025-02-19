import 'package:flutter/material.dart';
import 'dart:io';
import '../database/database_helper.dart';
import '../models/user_model.dart';
import 'add_user_screen.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _dbHelper = DatabaseHelper();
  List<User> _users = [];
  List<User> _filteredUsers = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    List<User> users = await _dbHelper.getUsers();
    setState(() {
      _users = users;
      _filteredUsers = users;
    });
  }

  void _filterUsers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.city.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _navigateToAddUserScreen() async {
    bool? userAdded = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddUserScreen()),
    );
    if (userAdded == true) {
      _fetchUsers(); // Refresh user list
    }
  }

  void _editUser(User user) async {
    // Navigate to AddUserScreen with user data for editing
    bool? userEdited = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddUserScreen(user: user)),
    );
    if (userEdited == true) {
      _fetchUsers(); // Refresh user list
    }
  }

  void _deleteUser(int userId) async {
    await _dbHelper.deleteUser(userId);
    _fetchUsers(); // Refresh user list
  }

  void _toggleFavorite(User user) async {
    await _dbHelper.toggleFavorite(user.id!);
    setState(() {
      user.isFavorite = user.isFavorite == 1 ? 0 : 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(user.isFavorite == 1 ? 'User marked as favorite!' : 'User marked as unfavorite!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User List')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _navigateToAddUserScreen,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name or City',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                User user = _filteredUsers[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: () => _toggleFavorite(user),
                      child: CircleAvatar(
                        backgroundImage: user.profileImagePath != null
                            ? FileImage(File(user.profileImagePath!))
                            : null,
                        child: user.profileImagePath == null
                            ? Icon(Icons.person)
                            : null,
                      ),
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.city),
                    trailing: PopupMenuButton<String>(
                      onSelected: (String value) {
                        switch (value) {
                          case 'edit':
                            _editUser(user);
                            break;
                          case 'delete':
                            _deleteUser(user.id!);
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return {'Edit', 'Delete'}.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice.toLowerCase(),
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}