import 'package:flutter/material.dart';
import 'add_user_screen.dart';
import 'user_list_screen.dart';
import 'favorites_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Matrimony App')),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildHomeButton(context, 'Add User', Icons.person_add, AddUserScreen()),
            _buildHomeButton(context, 'User List', Icons.list, UserListScreen()),
            _buildHomeButton(context, 'Favorites', Icons.favorite, FavoritesScreen()),
            _buildHomeButton(context, 'About Us', Icons.info, AboutScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context, String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
