import 'package:flutter/material.dart';
import 'package:aguaconectada/views/login_screen.dart';

class AdminHome extends StatefulWidget {
  final String userType;
  final String userName;

  const AdminHome({Key? key, required this.userType, required this.userName}) : super(key: key);

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Panel de ${widget.userName}'),
          backgroundColor: Colors.blue[800],
          actions: [
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.white),
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
        body: <Widget>[
          // Dashboard page
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                margin: EdgeInsets.all(20.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue[800]!,
                    width: 2.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen del Sistema',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatCard('Usuarios Activos', '1,234'),
                        _buildStatCard('Consumo Total', '5,678 m³'),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        print('Ver informe detallado');
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text('Ver Informe Detallado'),
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 4,
                color: Colors.blue[800],
                indent: 60,
                endIndent: 60,
              ),
            ],
          ),

          // User Management page
          ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('U${index + 1}'),
                  ),
                  title: Text('Usuario ${index + 1}'),
                  subtitle: Text('Correo: usuario${index + 1}@example.com'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      print('Editar Usuario ${index + 1}');
                    },
                  ),
                ),
              );
            },
          ),

          // Settings page
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuración del Sistema',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.security),
                  title: Text('Seguridad'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    print('Configuración de Seguridad');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('Notificaciones'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    print('Configuración de Notificaciones');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.backup),
                  title: Text('Respaldo de Datos'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    print('Configuración de Respaldo');
                  },
                ),
              ],
            ),
          ),
        ][currentPageIndex],
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.blue[800],
          height: 80,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: currentPageIndex,
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          destinations: <Widget>[
            NavigationDestination(
              icon: Icon(Icons.dashboard, color: Colors.white),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.people, color: Colors.white),
              label: 'Usuarios',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings, color: Colors.white),
              label: 'Configuración',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }
}