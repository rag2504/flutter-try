import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';

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
    _searchController.dispose(); // Fix: Dispose controller to prevent memory leaks
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

  void _toggleFavorite(int userId) async {
    await _dbHelper.toggleFavorite(userId);
    setState(() {
      for (var user in _users) {
        if (user.id == userId) {
          user.isFavorite = !user.isFavorite; // Update only the toggled user
          break;
        }
      }
      _filterUsers(); // Apply search filter again
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User List')),
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
                    leading: CircleAvatar(child: Text(user.name[0])),
                    title: Text(user.name),
                    subtitle: Text('${user.age} years old, ${user.city}'),
                    trailing: IconButton(
                      icon: Icon(user.isFavorite ? Icons.favorite : Icons.favorite_border, color: user.isFavorite ? Colors.red : null),
                      onPressed: () => _toggleFavorite(user.id!),
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
