import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aguaconectada/controllers/auth_controller.dart';
import 'package:aguaconectada/views/user/user_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _socioController = TextEditingController();
  final AuthController _authController = AuthController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[400]!, Colors.blue[800]!],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        Spacer(flex: 1),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.water_drop,
                              size: 120,
                              color: Colors.white,
                            ),
                            SizedBox(height: 48),
                            Text(
                              'Inicio de sesión',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'AguaConectada',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 48),
                            TextField(
                              controller: _rutController,
                              decoration: InputDecoration(
                                hintText: 'Ingrese su R.U.T',
                                prefixIcon:
                                    Icon(Icons.person, color: Colors.white70),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                hintStyle: TextStyle(color: Colors.white70),
                              ),
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _socioController,
                              decoration: InputDecoration(
                                hintText: 'Ingrese su N° de socio',
                                prefixIcon:
                                    Icon(Icons.numbers, color: Colors.white70),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                hintStyle: TextStyle(color: Colors.white70),
                              ),
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _submit,
                              child: Text('Iniciar sesión'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.blue[800],
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                                textStyle: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Spacer(flex: 3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    String rut = _rutController.text.trim();
    String socioString = _socioController.text.trim();

    var result = await _authController.login(rut, socioString);

    if (result["success"]) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => UserMenu(userType: result['userType'])),
      );
    } else {
      _showMessage(result['message']);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
