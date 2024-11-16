import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:aguaconectada/controllers/consumption_controller.dart';

class ConsumptionChart extends StatelessWidget {
  const ConsumptionChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConsumptionController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.isNotEmpty) {
          return Center(child: Text(controller.error));
        }

        final Map<String, double> chartData = controller.consumptionData.isEmpty
            ? {
                'Enero': 0,
                'Febrero': 0,
                'Marzo': 0,
                'Abril': 0,
                'Mayo': 0,
                'Junio': 0,
                'Julio': 0,
                'Agosto': 0,
                'Septiembre': 0,
                'Octubre': 0,
                'Noviembre': 0,
                'Diciembre': 0
              }
            : controller.consumptionData;

        final maxY =
            chartData.values.reduce((max, value) => value > max ? value : max);

        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      const months = [
                        'Ene',
                        'Feb',
                        'Mar',
                        'Abr',
                        'May',
                        'Jun',
                        'Jul',
                        'Ago',
                        'Sep',
                        'Oct',
                        'Nov',
                        'Dic'
                      ];
                      final index = value.toInt();
                      if (index >= 0 && index < months.length) {
                        return Text(
                          months[index],
                          style: const TextStyle(
                            color: Color(0xff68737d),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(
                        '${value.toInt()}',
                        style: const TextStyle(
                          color: Color(0xff67727d),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d), width: 1),
              ),
              barGroups: chartData.entries.map((entry) {
                return BarChartGroupData(
                  x: chartData.keys.toList().indexOf(entry.key),
                  barRods: [
                    BarChartRodData(
                      toY: entry.value,
                      color: Colors.orange[200],
                      width: 16,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              }).toList(),
              maxY: maxY > 0 ? maxY : 1, // Use 1 as minimum to show the x-axis
            ),
          ),
        );
      },
    );
  }
}
