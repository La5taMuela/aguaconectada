import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:aguaconectada/controllers/consumption_controller.dart';

class ConsumptionChart extends StatelessWidget {
  const ConsumptionChart({super.key});

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

        final Map<String, double> chartData = controller.monthlyDifferences.isEmpty
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
          'Diciembre': 0,
        }
            : controller.monthlyDifferences;

        final maxY =
        chartData.values.reduce((max, value) => value > max ? value : max);

        final months = [
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
          'Diciembre',
        ];

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
                      final index = value.toInt();
                      if (index >= 0 && index < months.length) {
                        return Text(
                          months[index].substring(0, 3),
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
              barGroups: List.generate(months.length, (index) {
                final month = months[index];
                final value = chartData[month] ?? 0;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: value,
                      color: Colors.orange[200],
                      width: 16,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              }),
              maxY: maxY > 0 ? maxY : 1, // Use 1 como mínimo para mostrar el eje x
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final value = rod.toY.toStringAsFixed(0); // Mostrar como entero
                    return BarTooltipItem(
                      '$value',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
            swapAnimationDuration: const Duration(milliseconds: 500),
          ),
        );
      },
    );
  }
}




