import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/operator_controller.dart';
import '../../controllers/user_controller.dart';
import 'consumption_chart.dart';
import 'package:aguaconectada/controllers/consumption_controller.dart';
import 'create_report_page.dart';
import '../../controllers/payment_controller.dart';

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
  late PaymentController _paymentController;
  late ConsumptionController _consumptionController;
  String? selectedYear;
  int? currentMonthConsumption;

  @override
  void initState() {
    super.initState();
    _paymentController = PaymentController();
    _paymentController.initializeData(widget.userRut);
    _consumptionController = ConsumptionController();
    _consumptionController.setUserRut(widget.userRut);
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
                              await _paymentController
                                  .handlePayment(widget.userRut);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Pago registrado exitosamente')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error: ${e.toString()}')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.black87),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Gráfico de consumo',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const ConsumptionChart(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Historial de Pagos',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: UserController()
                            .getPaymentStatusByMonth(widget.userRut),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Text(
                                'No hay datos de pago disponibles.');
                          } else {
                            final paymentData = snapshot.data!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: paymentData.entries.map((entry) {
                                final month = entry.key;
                                final details = entry.value;
                                return Card(
                                  color: Colors.white, // Make each card background transparent
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),

                                    child: Center(
                                      child: Text(
                                        details['valor'] == 0
                                            ? '$month: Mes no pagado'
                                            : '$month: Pago ${details['fecha']}\nTotal: \$${details['valor']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,

                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CreateReportPage(
              userRut: widget.userRut,
              nombre: widget.userName,
              apellidoPaterno: widget.apellidoPaterno,
              socio: widget.socio,
            ),
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
                icon: Icon(Icons.report_problem, color: Colors.black87),
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
