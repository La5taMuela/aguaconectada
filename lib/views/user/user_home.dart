import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/operator_controller.dart';
import '../../controllers/user_controller.dart';
import 'consumption_chart.dart';
import 'package:aguaconectada/controllers/consumption_controller.dart';
import 'create_report_page.dart'; // Añade esta importación

class UserMenu extends StatefulWidget {
  final String userType;
  final String userName;
  final String userRut;
  final String apellidoPaterno;
  final String socio;

  const UserMenu({
    Key? key,
    required this.userType,
    required this.userName,
    required this.userRut,
    required this.apellidoPaterno,
    required this.socio,

  }) : super(key: key);

  @override
  _UserMenuState createState() => _UserMenuState();
}

class _UserMenuState extends State<UserMenu> {
  int currentPageIndex = 0;
  late ConsumptionController _consumptionController;
  String? selectedYear;
  int? currentMonthConsumption;

  @override
  void initState() {
    super.initState();
    _consumptionController = ConsumptionController();
    _consumptionController.setUserRut(widget.userRut);

    final userController = UserController();
    userController.getCurrentMonthConsumption(widget.userRut).then((consumption) {
      setState(() {
        currentMonthConsumption = consumption;
      });
    });

    List<String> availableYears = _consumptionController.getAvailableYears();
    if (availableYears.isNotEmpty) {
      selectedYear = availableYears.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _consumptionController,
      child: WillPopScope(
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
          ),
          body: <Widget>[
            // Home page
            SingleChildScrollView(
              child: Column(
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
                        Text(
                          currentMonthConsumption != null
                              ? 'Monto a pagar: ${currentMonthConsumption} '
                              : 'Monto a pagar: Cargando...',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              // Aquí actualizamos el timestamp al momento de pagar
                              final operatorController = OperatorController();
                              await operatorController.saveMonthlyConsumption(widget.userRut, {
                                'Enero': currentMonthConsumption ?? 0,  // Puedes añadir otros meses si es necesario
                              });
                              setState(() {
                                currentMonthConsumption = 0; // Resetear o actualizar el monto si es necesario
                              });
                              print('Pago registrado y timestamp actualizado');
                            } catch (e) {
                              print('Error al procesar el pago: $e');
                            }
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Gráfico de consumo',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        DropdownButton<String>(
                          value: selectedYear,
                          hint: const Text('Selecciona un año'),
                          items: _consumptionController.getAvailableYears().map((String year) {
                            return DropdownMenuItem<String>(
                              value: year,
                              child: Text(year),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedYear = newValue;
                            });
                            print('Año seleccionado: $selectedYear');
                          },
                        ),
                      ],
                    ),
                  ),
                  const ConsumptionChart(),
                ],
              ),
            ),
            // Crear reporte page
            CreateReportPage(userRut: widget.userRut, nombre: widget.userName, apellidoPaterno: widget.apellidoPaterno, socio: widget.socio,), // Añade esta línea
            // Profile page
            const Center(child: Text('Página de Perfil')),
          ][currentPageIndex],
          bottomNavigationBar: NavigationBar(
            backgroundColor: Colors.blue[400],
            height: 80,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: currentPageIndex,
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            destinations: const <Widget>[
              NavigationDestination(
                icon: Icon(Icons.home, color: Colors.black87),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: Icon(Icons.report_problem, color: Colors.black87), // Cambiado a un icono más apropiado
                label: 'Crear un reporte',
              ),
              NavigationDestination(
                icon: Icon(Icons.person, color: Colors.black87),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}