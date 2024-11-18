import 'package:aguaconectada/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/login_screen.dart';
import 'controllers/user_provider.dart';

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
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
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
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black),
            bodyMedium: TextStyle(color: Colors.black),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
            ),
          ),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}