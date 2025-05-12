import 'package:flutter/material.dart';
import 'package:mobile/models/journal_entry.dart';
import 'package:fl_chart/fl_chart.dart';

class TimelineGraph extends StatelessWidget {
  final List<JournalEntry> entries;

  const TimelineGraph({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(child: Text('No data for graph')),
      );
    }

    // Process entries to count entries per day
    // Group entries by date (year, month, day)
    Map<String, int> entriesPerDay = {};
    for (var entry in entries) {
      // Format date as YYYY-MM-DD for easy grouping
      String dateKey =
          "${entry.createdAt.year}-${entry.createdAt.month.toString().padLeft(2, '0')}-${entry.createdAt.day.toString().padLeft(2, '0')}";
      entriesPerDay[dateKey] = (entriesPerDay[dateKey] ?? 0) + 1;
    }

    // Sort the dates and create chart data
    List<String> sortedDates = entriesPerDay.keys.toList()..sort();
    List<BarChartGroupData> barGroups = [];
    double maxY = 0;
    for (int i = 0; i < sortedDates.length; i++) {
      String date = sortedDates[i];
      int count = entriesPerDay[date]!;
      barGroups.add(
        BarChartGroupData(
          x: i, // Use index as x-value
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: Colors.blueAccent,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      if (count > maxY) maxY = count.toDouble();
    }
    // Add some padding to maxY
    maxY = maxY + (maxY * 0.2); // Increase max Y by 20%

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Entries per Day',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 200, // Height for the chart
            child: BarChart(
              BarChartData(
                maxY:
                    maxY == 0
                        ? 1
                        : maxY, // Avoid max Y of 0 if there are entries
                barGroups: barGroups,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // Display date for relevant bars
                        int index = value.toInt();
                        if (index >= 0 && index < sortedDates.length) {
                          // Simple label, consider showing fewer dates for readability
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 4.0,
                            child: Text(
                              sortedDates[index]
                                  .substring(5)
                                  .replaceFirst('-', '/'),
                              style: TextStyle(fontSize: 10),
                            ), // Show MM-DD
                          );
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4.0,
                          child: Text(''),
                        );
                      },
                      reservedSize: 20, // Space for labels
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4.0,
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 10),
                          ),
                        );
                      },
                      reservedSize: 28, // Space for labels
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                // Optional: Tooltip for showing value on touch
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (BarChartGroupData group) {
                      return Colors.blueGrey;
                    },
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.toInt().toString(),
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
