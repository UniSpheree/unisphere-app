import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _currentWeekStart = _getStartOfWeek(DateTime.now());

  static DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  void _goToPreviousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _goToNextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final weekDates = List.generate(
      7,
      (i) => _currentWeekStart.add(Duration(days: i)),
    );
    final hours = List.generate(24, (i) => i);
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left),
                  onPressed: _goToPreviousWeek,
                ),
                Text(
                  '${weekDates.first.month}/${weekDates.first.day} - ${weekDates.last.month}/${weekDates.last.day}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: _goToNextWeek,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(width: 48),
                ...daysOfWeek.map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: hours.length,
                itemBuilder: (context, hourIdx) {
                  return SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          child: Center(
                            child: Text(
                              '${hours[hourIdx].toString().padLeft(2, '0')}:00',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        ...List.generate(7, (dayIdx) {
                          // Placeholder for events
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200),
                                color: Colors.white,
                              ),
                              // TODO: Display events here
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
