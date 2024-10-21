import 'package:flutter/material.dart';

class UserMenu extends StatefulWidget {
  final String userType;
  final String userName;

  const UserMenu({super.key, required this.userType, required this.userName});

  @override
  _UserMenuState createState() => _UserMenuState();
}

class _UserMenuState extends State<UserMenu> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Menú de ${widget.userName}'),
          backgroundColor: Colors.blue[400],
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.black87),
              iconSize: 40.0,
              onPressed: () {
                print('Notificaciones presionadas');
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(),
          ),
        ),
        body: <Widget>[
          // Home page
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.all(20.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.black87,
                    width: 2.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
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
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.black87),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Pagar'),
                    ),
                  ],
                ),
              ),
              const Divider(
                thickness: 4,
                color: Colors.black87,
                indent: 60,
                endIndent: 60,
              ),
            ],
          ),

          // Notifications page
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Card(
                  child: ListTile(
                    leading: Icon(Icons.notifications_sharp),
                    title: Text('Notification 1'),
                    subtitle: Text('This is a notification'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.notifications_sharp),
                    title: Text('Notification 2'),
                    subtitle: Text('This is a notification'),
                  ),
                ),
              ],
            ),
          ),

          // Messages page
          ListView.builder(
            reverse: true,
            itemCount: 2,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'Hello',
                      style: theme.textTheme.bodyLarge!
                          .copyWith(color: theme.colorScheme.onPrimary),
                    ),
                  ),
                );
              }
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'Hi!',
                    style: theme.textTheme.bodyLarge!
                        .copyWith(color: theme.colorScheme.onPrimary),
                  ),
                ),
              );
            },
          ),
        ][currentPageIndex],
        bottomNavigationBar: LayoutBuilder(
          builder: (context, constraints) {
            return NavigationBar(
              backgroundColor: Colors.blue[400],
              height: 80,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              selectedIndex: currentPageIndex == -1 ? 0 : currentPageIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
                switch (index) {
                  case 0:
                    print('Navegar a: /generar-reporte');
                    break;
                  case 1:
                    print('Navegar a: /subir-estado-agua');
                    break;
                  case 2:
                    print('Navegar a: /perfil');
                    break;
                }
              },
              destinations: const <Widget>[
                NavigationDestination(
                  icon: Icon(Icons.notifications, color: Colors.black87),
                  label: 'Generar reporte',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_photo_alternate, color: Colors.black87),
                  label: 'Subir consumo',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person, color: Colors.black87),
                  label: 'Perfil',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}