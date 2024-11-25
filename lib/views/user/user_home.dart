import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tutorial_modals.dart';
import '../../controllers/tutorial_controller.dart';
import '../../models/user.dart';
import 'upload_consumo_page.dart';
import 'consumption_chart.dart';
import 'package:aguaconectada/controllers/consumption_controller.dart';
import 'create_report_page.dart';
import '../../controllers/payment_controller.dart';
import '../../widgets/profile_widget.dart';
import '../../controllers/user_controller.dart';
import 'notification_report_user.dart';

class UserMenu extends StatefulWidget {
  final User user;

  const UserMenu({
    super.key,
    required this.user,
  });

  @override
  _UserMenuState createState() => _UserMenuState();
}

class _UserMenuState extends State<UserMenu> {
  int currentPageIndex = 0;
  late PaymentController _paymentController;
  late ConsumptionController _consumptionController;
  late Stream<DocumentSnapshot> _userStream;
  late UserController _userController;
  String? selectedYear;
  int? currentMonthConsumption;

  late TutorialController _tutorialController;
  int _currentTutorialStep = 0;
  bool _showTutorial = false;  // Add this line to define _showTutorial

  @override
  void initState() {
    super.initState();
    _paymentController = PaymentController();
    _paymentController.initializeData(widget.user.rut);
    _consumptionController = ConsumptionController();
    _consumptionController.setUserRut(widget.user.rut);
    _userStream = FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.user.rut)
        .snapshots();
    _userController = UserController();
    _tutorialController = TutorialController();

    // Remove the duplicate call to _checkTutorialStatus
    // Only keep the post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTutorial();
    });

    print("User stream initialized for user: ${widget.user.rut}");
  }


  void _handleRestartTutorial(bool restart) {
    if (restart) {
      setState(() {
        currentPageIndex = 0;
        _currentTutorialStep = 0;
        _showTutorial = true;
      });
      _showTutorialStep();
    }
  }

  Future<void> _checkAndShowTutorial() async {
    bool tutorialCompleted = await _tutorialController.checkTutorialStatus(widget.user.rut);
    if (!tutorialCompleted) {
      setState(() {
        _currentTutorialStep = 0;
        _showTutorial = true;
      });
      _showTutorialStep();
    }
  }


  void _showTutorialStep() {
    final List<Map<String, dynamic>> tutorialSteps = [
      {
        'title': '¡Bienvenido a Agua Conectada!',
        'description': 'Esta es tu página principal donde podrás gestionar todos tus servicios de agua. Aquí encontrarás información sobre tus pagos, consumos y más.',
        'alignment': Alignment.center,
      },
      {
        'title': 'Sistema de Notificaciones',
        'description': 'El icono de campana te mantendrá informado sobre el estado de tus reportes y otras notificaciones importantes. ¡No te pierdas ninguna actualización!',
        'alignment': const Alignment(0.8, -0.8),
        'highlightWidget': _buildHighlightedArea(
            top: 0, height: 60, left: MediaQuery.of(context).size.width - 60, width: 60),
      },
      {
        'title': 'Estado de Pagos',
        'description': 'Aquí podrás ver tu monto actual a pagar y realizar pagos de manera rápida y segura. El sistema te mostrará si el mes está pagado o pendiente.',
        'alignment': const Alignment(0, -0.5),
        'highlightWidget': _buildHighlightedArea(top: 80, height: 120),
      },
      {
        'title': 'Gráfico de Consumo',
        'description': 'Visualiza y analiza tu consumo mensual de agua en este gráfico interactivo. Te ayudará a entender mejor tus patrones de consumo y planificar mejor.',
        'alignment': const Alignment(0, 0.3),
        'highlightWidget': _buildHighlightedArea(top: 220, height: 200),
      },
      {
        'title': 'Historial de Pagos',
        'description': 'Accede a tu historial completo de pagos y consumos mensuales. Mantén un registro detallado de todas tus transacciones anteriores.',
        'alignment': const Alignment(0, -0.3),
        'highlightWidget': _buildHighlightedArea(top: 440, height: 200),
      },
      {
        'title': 'Crear Reportes',
        'description': 'En esta sección podrás crear reportes sobre problemas o consultas. Incluye un título, descripción y hasta 4 imágenes para mejor explicación.',
        'alignment': Alignment.bottomCenter,
        'navigateTo': 1,
      },
      {
        'title': 'Subir Consumo',
        'description': 'Aquí podrás registrar tu consumo mensual de agua. Recuerda que debes incluir una foto del medidor para mantener un registro preciso.',
        'alignment': Alignment.bottomCenter,
        'navigateTo': 2,
      },
    ];

    if (_currentTutorialStep < tutorialSteps.length) {
      if (tutorialSteps[_currentTutorialStep]['navigateTo'] != null) {
        setState(() {
          currentPageIndex = tutorialSteps[_currentTutorialStep]['navigateTo'];
        });
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return TutorialModal(
            title: tutorialSteps[_currentTutorialStep]['title'],
            description: tutorialSteps[_currentTutorialStep]['description'],
            isLastStep: _currentTutorialStep == tutorialSteps.length - 1,
            alignment: tutorialSteps[_currentTutorialStep]['alignment'],
            highlightWidget: tutorialSteps[_currentTutorialStep]['highlightWidget'],
            onNext: () async {
              Navigator.of(context).pop();
              if (_currentTutorialStep == tutorialSteps.length - 1) {
                await _tutorialController.completeTutorial(widget.user.rut);
              } else {
                setState(() {
                  _currentTutorialStep++;
                });
                _showTutorialStep();
              }
            },
            onSkip: _currentTutorialStep == 0 ? () async {
              Navigator.of(context).pop();
              await _tutorialController.completeTutorial(widget.user.rut);
            } : null,
          );
        },
      );
    }
  }

  Widget _buildHighlightedArea({required double top, required double height, double? left, double? width}) {
    return Stack(
      children: [
        // Fondo oscuro superior
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: top,
          child: Container(color: Colors.black12),
        ),
        // Área destacada (transparente)
        Positioned(
          top: top,
          left: left ?? 0,
          width: width ?? double.infinity,
          height: height,
          child: Container(color: Colors.transparent),
        ),
        // Fondo oscuro inferior
        Positioned(
          top: top + height,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(color: Colors.black12),
        ),
      ],
    );
  }

  void _showNotificationModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<QuerySnapshot>(
          stream: _userController.getUserReportsStream(widget.user.rut),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return AlertDialog(
                title: const Text("Error"),
                content: Text("Error: ${snapshot.error}"),
                actions: [
                  TextButton(
                    child: const Text("Cerrar"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            }

            final reports = snapshot.data?.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'reportId': doc.id,
                'title': data['title'] as String? ?? 'Sin título',
                'description': data['description'] as String? ?? '',
                'status': data['status'] as String? ?? 'Desconocido',
                'operatorComment': data['operatorComment'] as String?,
                'read': data['read'] as bool? ?? false,
              };
            }).toList() ??
                [];

            if (reports.isEmpty) {
              return AlertDialog(
                title: const Text("Notificaciones"),
                content: const Text("No hay notificaciones nuevas"),
                actions: [
                  TextButton(
                    child: const Text("Cerrar"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            }

            return NotificationModal(
              reports: reports,
              onReportTap: (String reportId) {
                _userController.markNotificationAsRead(reportId);
                setState(() {}); // Trigger a rebuild to update the UI
              },
            );
          },
        );
      },
    );
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
            title: Text('${widget.user.nombreCompleto()}'),
            backgroundColor: Colors.blue[400],
            actions: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reportes')
                    .where('userRut', isEqualTo: widget.user.rut)
                    .where('notificationState', isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  final unreadNotifications =
                  snapshot.hasData ? snapshot.data!.docs.length : 0;

                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications,
                            color: Colors.black87),
                        iconSize: 40.0,
                        onPressed: () => _showNotificationModal(context),
                      ),
                      if (unreadNotifications > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              '$unreadNotifications',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          body: <Widget>[
            // Home page
            SingleChildScrollView(
              child: Column(
                children: [
                  StreamBuilder<DocumentSnapshot>(
                    stream: _userStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        print('Error fetching user data: ${snapshot.error}');
                        return Text('Error: ${snapshot.error}');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        print('User data not found');
                        return const Text('No user data available');
                      }

                      var userData = snapshot.data!.data() as Map<String, dynamic>;
                      var currentYear = DateTime.now().year.toString();
                      var currentMonth = DateTime.now().month;
                      var monthNames = [
                        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
                      ];
                      var currentMonthName = monthNames[currentMonth - 1];

                      // Check if the payment for the current month exists and is not zero
                      var isPaid = userData['historialPagos']?[currentYear]?[currentMonthName]?['valor'] != null &&
                          userData['historialPagos']?[currentYear]?[currentMonthName]?['valor'] != 0;

                      var currentMonthConsumption = userData['montosMensuales']?[currentYear]?[currentMonthName] ?? 0;

                      print('Current Month Consumption: $currentMonthConsumption');
                      print('User data fetched: $userData');

                      return Container(
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
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      isPaid ?
                                      'Mes Pagado' : 'Monto a pagar:',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    isPaid ? '' : '\$$currentMonthConsumption',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (!isPaid) // Only show the button if the month is not paid
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await _paymentController.handlePayment(widget.user.rut);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Pago registrado exitosamente')),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error: ${e.toString()}')),
                                        );
                                      }
                                    }
                                  },
                                  // ... (button styling remains unchanged)
                                  child: const Text(
                                    'Pagar',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
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
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: _userStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            print(
                                'Error fetching payment data: ${snapshot.error}');
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData ||
                              !snapshot.data!.exists) {
                            print('No payment data available.');
                            return const Text(
                                'No hay datos de pago disponibles.');
                          } else {
                            var userData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            var currentYear = DateTime.now().year.toString();
                            var paymentData =
                                userData['historialPagos'][currentYear] ?? {};
                            var monthNames = [
                              'Enero',
                              'Febrero',
                              'Marzo',
                              'Abril',
                              'Mayo',
                              'Junio',
                              'Julio',
                              'Agosto',
                              'Septiembre',
                              'Octubre',
                              'Noviembre',
                              'Diciembre'
                            ];
                            print(
                                'Payment data for year $currentYear: $paymentData');

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: List.generate(monthNames.length, (i) {
                                final currentMonth = monthNames[i];
                                final currentDetails = paymentData[currentMonth] ?? {'valor': 0, 'fecha': null};
                                final currentConsumption = userData['consumos'][currentYear]?[currentMonth] ?? 0;

                                // Calcular la diferencia de consumo con el mes anterior
                                int consumptionDifference = 0;
                                if (i > 0) {
                                  final previousMonth = monthNames[i - 1];
                                  final previousConsumption = userData['consumos'][currentYear]?[previousMonth] ?? 0;
                                  consumptionDifference = currentConsumption - previousConsumption;
                                  if (consumptionDifference < 0) consumptionDifference = 0; // Evitar valores negativos
                                } else {
                                  // Para enero (primer mes), no hay consumo anterior
                                  consumptionDifference = currentConsumption;
                                }

                                return Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        currentDetails['valor'] == 0
                                            ? '$currentMonth: Mes no pagado'
                                            : '$currentMonth: Pago ${currentDetails['fecha']}\nTotal: \$${currentDetails['valor']}\nConsumo: ${consumptionDifference}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                );
                              }),
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
              userRut: widget.user.rut,
              nombre: widget.user.nombre,
              apellidoPaterno: widget.user.apellidoPaterno,
              socio: widget.user.socio.toString(),
            ),
            UploadConsumoPage(
              rut: widget.user.rut,
              nombre: widget.user.nombre,
              apellidoPaterno: widget.user.apellidoPaterno,
              socio: widget.user.socio.toString(),
            ),
            ProfileWidget(
              user: widget.user,
              onLogout: () {
                print('Logging out user ${widget.user.rut}');
                Navigator.of(context).pushReplacementNamed('/login');
              },
              onRestartTutorial: _handleRestartTutorial,
            ),
          ][currentPageIndex],
          bottomNavigationBar: NavigationBar(
            backgroundColor: Colors.blue[400],
            height: 80,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: currentPageIndex,
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
                print('Page changed to index: $index');
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
                icon: Icon(Icons.image, color: Colors.black87),
                label: 'Subir consumo',
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