import 'package:flutter/material.dart';
import 'package:aguaconectada/views/login_screen.dart';

class OperatorHome extends StatefulWidget {
  final String userType;
  final String userName;

  const OperatorHome({Key? key, required this.userType, required this.userName}) : super(key: key);

  @override
  _OperatorHomeState createState() => _OperatorHomeState();
}

class _OperatorHomeState extends State<OperatorHome> {
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
          backgroundColor: Colors.green[600],
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
          // Tasks page
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
                    color: Colors.green[600]!,
                    width: 2.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tareas Pendientes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildTaskItem('Revisar medidor #1234', 'Alta'),
                    _buildTaskItem('Mantenimiento bomba sector norte', 'Media'),
                    _buildTaskItem('Actualizar lecturas sector sur', 'Baja'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        print('Ver todas las tareas');
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text('Ver Todas las Tareas'),
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 4,
                color: Colors.green[600],
                indent: 60,
                endIndent: 60,
              ),
            ],
          ),

          // Reports page
          ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Icon(Icons.description, color: Colors.green[600]),
                  title: Text('Reporte #${1000 + index}'),
                  subtitle: Text('Fecha: ${DateTime.now().subtract(Duration(days: index)).toString().split(' ')[0]}'),
                  trailing: IconButton(
                    icon: Icon(Icons.visibility),
                    onPressed: () {
                      print('Ver Reporte #${1000 + index}');
                    },
                  ),
                ),
              );
            },
          ),

          // Profile page
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perfil del Operador',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Nombre'),
                  subtitle: Text(widget.userName),
                ),
                ListTile(
                  leading: Icon(Icons.work),
                  title: Text('Cargo'),
                  subtitle: Text('Operador'),
                ),
                ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text('Zona Asignada'),
                  subtitle: Text('Sector Norte'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    print('Editar Perfil');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text('Editar Perfil'),
                ),
              ],
            ),
          ),
        ][currentPageIndex],
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.green[600],
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
              icon: Icon(Icons.task, color: Colors.white),
              label: 'Tareas',
            ),
            NavigationDestination(
              icon: Icon(Icons.assessment, color: Colors.white),
              label: 'Reportes',
            ),
            NavigationDestination(
              icon: Icon(Icons.person, color: Colors.white),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(String title, String priority) {
    Color priorityColor;
    switch (priority.toLowerCase()) {
      case 'alta':
        priorityColor = Colors.red;
        break;
      case 'media':
        priorityColor = Colors.orange;
        break;
      case 'baja':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: priorityColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}