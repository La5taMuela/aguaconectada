import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aguaconectada/controllers/auth_controller.dart';
import 'package:aguaconectada/views/operator/operator_home.dart';
import 'package:aguaconectada/views/user/user_home.dart';
import 'package:aguaconectada/utils/utils.dart';
import 'package:aguaconectada/models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _socioController = TextEditingController();
  final AuthController _authController = AuthController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
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
              physics: const NeverScrollableScrollPhysics(),
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
                        const Spacer(flex: 1),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.water_drop,
                              size: 120,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 48),
                            const Text(
                              'Inicio de sesión',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'AguaConectada',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 48),
                            TextField(
                              controller: _rutController,
                              decoration: InputDecoration(
                                hintText: 'Ingrese su R.U.T',
                                prefixIcon: const Icon(Icons.person, color: Colors.white70),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                hintStyle: const TextStyle(color: Colors.white70),
                              ),
                              style: const TextStyle(color: Colors.white),
                              onChanged: (value) {
                                setState(() {
                                  _rutController.text = formatRut(value);
                                  _rutController.selection = TextSelection.fromPosition(
                                    TextPosition(offset: _rutController.text.length),
                                  );
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _socioController,
                              decoration: InputDecoration(
                                hintText: 'Ingrese su N° de socio',
                                prefixIcon: const Icon(Icons.numbers, color: Colors.white70),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                hintStyle: const TextStyle(color: Colors.white70),
                              ),
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.blue[800],
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 50,
                                  vertical: 15,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text('Iniciar sesión'),
                            ),
                          ],
                        ),
                        const Spacer(flex: 3),
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
    String rut = formatRut(_rutController.text.trim());
    String socioString = _socioController.text.trim();

    var result = await _authController.login(rut, socioString);

    if (result["success"]) {
      User user = result['user'];
      Widget homeScreen;

      switch (result['userType']) {
        case 'Operador':
          homeScreen = OperatorHome(
            user: user,
            userName: user.nombreCompleto(),
            userType: result['userType'],
          );
          break;
        case 'Usuarios':
          homeScreen = UserMenu(user: user);
          break;
        default:
          _showMessage('Error: Tipo de usuario desconocido');
          return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => homeScreen),
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