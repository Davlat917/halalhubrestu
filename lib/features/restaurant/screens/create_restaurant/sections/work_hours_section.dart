import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/create_restaurant/widgets/day_hours_tile.dart';

class WorkHoursSection extends StatelessWidget {
  const WorkHoursSection({
    super.key,
    required this.availableWidth,
    required this.days,
    required this.openDays,
    required this.startTimes,
    required this.endTimes,
    required this.toggleDay,
    required this.onPickStart,
    required this.onPickEnd,
    required this.completeButton,
  });

  final double availableWidth;
  final List<String> days;
  final List<bool> openDays;
  final List<TimeOfDay> startTimes;
  final List<TimeOfDay> endTimes;
  final void Function(int index, bool value) toggleDay;
  final void Function(int index) onPickStart;
  final void Function(int index) onPickEnd;
  final Widget completeButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...List.generate(
          days.length,
          (i) => DayHoursTile(
            availableWidth: availableWidth,
            day: days[i],
            isOpen: openDays[i],
            onChanged: (v) => toggleDay(i, v),
            startTime: startTimes[i],
            endTime: endTimes[i],
            onPickStart: () => onPickStart(i),
            onPickEnd: () => onPickEnd(i),
          ),
        ),
        completeButton,
      ],
    );
  }
}
