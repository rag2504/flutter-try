import 'package:darshan/screens/home_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'database/database_helper.dart';

// Import correct SQLite library based on platform
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb; // Use web-compatible database
  } else {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  try {
    await DatabaseHelper().database; // Initialize database
    print('Database initialized successfully');
  } catch (e) {
    print('Error initializing database: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matrimony App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}