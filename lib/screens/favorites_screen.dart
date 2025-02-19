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

  void _removeFromFavorites(User user) async {
    await _dbHelper.toggleFavorite(user.id!);
    setState(() {
      user.isFavorite = 0;
      _favorites.remove(user); // Remove only the unfavored user
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User marked as unfavorite!')),
    );
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
                onPressed: () => _removeFromFavorites(user),
              ),
            ),
          );
        },
      ),
    );
  }
}