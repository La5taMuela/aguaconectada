import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../login_screen.dart';

class PerfilPage extends StatelessWidget {
  final User user;
  final VoidCallback onLogout;

  const PerfilPage({
    Key? key,
    required this.user,
    required this.onLogout,
  }) : super(key: key);

  Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Cierre de Sesión'),
          content: const Text('¿Está seguro que desea cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información Personal',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoCard([
                      if (user.nombre.isNotEmpty) _buildInfoRow('Nombre', user.nombre),
                      if (user.segundoNombre.isNotEmpty) _buildInfoRow('Segundo Nombre', user.segundoNombre),
                      if (user.apellidoPaterno.isNotEmpty) _buildInfoRow('Apellido Paterno', user.apellidoPaterno),
                      if (user.apellidoMaterno.isNotEmpty) _buildInfoRow('Apellido Materno', user.apellidoMaterno),
                      if (user.rut.isNotEmpty) _buildInfoRow('RUT', user.rut),
                      if (user.socio != 0) _buildInfoRow('N° Socio', user.socio.toString()),
                      if (user.idUsuario != 0) _buildInfoRow('ID Usuario', user.idUsuario.toString()),
                    ]),
                    if (user.nota.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text('Nota', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 10),
                      _buildInfoCard([Text(user.nota, style: const TextStyle(fontSize: 16))]),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (await _showLogoutConfirmationDialog(context)) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (Route<dynamic> route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cerrar Sesión', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(value, style: const TextStyle(fontSize: 18, color: Colors.black87)),
        ],
      ),
    );
  }

}