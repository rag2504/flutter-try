import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _dbHelper = DatabaseHelper();
  List<User> _favorites = [];

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    List<User> users = await _dbHelper.getFavoriteUsers();
    setState(() {
      _favorites = users;
    });
  }

  void _removeFromFavorites(int userId) async {
    await _dbHelper.toggleFavorite(userId);
    setState(() {
      _favorites.removeWhere((user) => user.id == userId); // Remove only the unfavored user
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorites')),
      body: _favorites.isEmpty
          ? Center(child: Text('No favorite users yet'))
          : ListView.builder(
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          User user = _favorites[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ListTile(
              leading: CircleAvatar(child: Text(user.name[0])),
              title: Text(user.name),
              subtitle: Text('${user.age} years old, ${user.city}'),
              trailing: IconButton(
                icon: Icon(Icons.favorite, color: Colors.red),
                onPressed: () => _removeFromFavorites(user.id!),
              ),
            ),
          );
        },
      ),
    );
  }
}
