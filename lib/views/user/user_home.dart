import 'package:flutter/material.dart';
import 'package:aguaconectada/views/login_screen.dart';

class UserMenu extends StatelessWidget {
  final String userType;

  const UserMenu({Key? key, required this.userType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menú de $userType'),
        backgroundColor: Colors.blue[400],
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black87),
            iconSize: 40.0,
            onPressed: () {
              print('Notificaciones presionadas');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.all(20.0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent, // Fondo transparente
              borderRadius: BorderRadius.circular(12), // Bordes redondeados
              border: Border.all( // Contorno
                color: Colors.black87, // Color del contorno
                width: 2.0, // Grosor del contorno
              ),
            ),
            child: Row( // Usamos un Row para alinear el texto y el botón
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Información Importante',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    print('Botón presionado');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, backgroundColor: Colors.white, // Texto negro
                    side: BorderSide(color: Colors.black87), // Borde negro
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Bordes del botón redondeados
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Relleno
                  ),
                  child: Text('Pagar'),
                ),
              ],
            ),
          ),
          Divider( // Barra divisoria
            thickness: 4, // Grosor de la barra
            color: Colors.black87, // Color de la barra
            indent: 60, // Espacio a la izquierda
            endIndent: 60, // Espacio a la derecha

          ),
          // Puedes agregar más contenido debajo si es necesario
          
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue[400], // Fondo azul
        child: Container(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(
                icon: Icons.notifications,
                label: 'Generar reporte',
                onTap: () {
                  print('Navegar a: /generar-reporte');
                },
              ),
              _buildNavItem(
                icon: Icons.add_photo_alternate,
                label: 'Subir consumo',
                onTap: () {
                  print('Navegar a: /subir-estado-agua');
                },
              ),
              _buildNavItem(
                icon: Icons.person,
                label: 'Perfil',
                onTap: () {
                  print('Navegar a: /perfil');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded( // Hace que todo el espacio sea clickeable
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,  // Desactiva el efecto splash
        highlightColor: Colors.transparent, // Desactiva el efecto de resaltado
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, // Alinea los elementos al centro
          children: [
            Icon(icon, color: Colors.black87, size: 22,), // Color negro para el icono
            SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 18, color: Colors.white70), // Texto blanco
            ),
          ],
        ),
      ),
    );
  }
}
