import 'package:aguaconectada/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'views/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agua Conectada',
      theme: ThemeData(
        primaryColor: Colors.blue[800],
        scaffoldBackgroundColor: Colors.blue[400],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[800],
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.white,
          secondary: Colors.blue[400]!,
          // background: Colors.blue[50]!,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black), //blue[900]
          bodyMedium: TextStyle(color: Colors.black), //blue[800]
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            // foregroundColor: Colors.white,
            backgroundColor: Colors.blue[800],
          ),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
