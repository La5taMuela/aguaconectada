import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';
import 'package:aguaconectada/views/login_screen.dart';

class ProfileWidget extends StatefulWidget {
  final User user;
  final VoidCallback? onLogout;
  final Function(bool)? onRestartTutorial;

  const ProfileWidget({
    Key? key,
    required this.user,
    this.onLogout,
    this.onRestartTutorial,
  }) : super(key: key);

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  bool isLoading = false;
  bool isUser = false;

  @override
  void initState() {
    super.initState();
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.user.rut)
        .get();

    setState(() {
      isUser = userDoc.exists;
    });
  }

  Future<void> _resetTutorial() async {
    try {
      setState(() {
        isLoading = true;
      });

      bool confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Reiniciar Tutorial'),
            content: const Text('¿Está seguro que desea volver a ver el tutorial?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(foregroundColor: Colors.black),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      ) ?? false;

      if (!confirm) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(widget.user.rut)
          .update({'tutorialCompleted': false});

      widget.onRestartTutorial?.call(true);

    } catch (e) {
      print('Error resetting tutorial: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al reiniciar el tutorial'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

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
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información Personal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoCard([
                  if (widget.user.nombre.isNotEmpty)
                    _buildInfoRow('Nombre', widget.user.nombre),
                  if (widget.user.segundoNombre.isNotEmpty)
                    _buildInfoRow('Segundo Nombre', widget.user.segundoNombre),
                  if (widget.user.apellidoPaterno.isNotEmpty)
                    _buildInfoRow('Apellido Paterno', widget.user.apellidoPaterno),
                  if (widget.user.apellidoMaterno.isNotEmpty)
                    _buildInfoRow('Apellido Materno', widget.user.apellidoMaterno),
                  if (widget.user.rut.isNotEmpty)
                    _buildInfoRow('RUT', widget.user.rut),
                  if (widget.user.socio != 0)
                    _buildInfoRow('N° Socio', widget.user.socio.toString()),
                ]),
                if (widget.user.nota.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Nota',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    [Text(widget.user.nota, style: const TextStyle(fontSize: 16))],
                  ),
                ],
                if (isUser) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _resetTutorial,
                      icon: isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Icon(Icons.help_outline),
                      label: Text(
                        isLoading ? 'Reiniciando...' : 'Ver Tutorial',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
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
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                        (Route<dynamic> route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

