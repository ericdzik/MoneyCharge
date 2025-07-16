import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class OpeningHoursSelector extends StatefulWidget {
  final Map<String, dynamic> initialHours;
  final Function(Map<String, dynamic>) onHoursChanged;

  const OpeningHoursSelector({
    super.key,
    required this.initialHours,
    required this.onHoursChanged,
  });

  @override
  _OpeningHoursSelectorState createState() => _OpeningHoursSelectorState();
}

class _OpeningHoursSelectorState extends State<OpeningHoursSelector> {
  late Map<String, dynamic> _openingHours;
  final List<String> _days = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
  ];

  @override
  void initState() {
    super.initState();
    _openingHours = Map.from(widget.initialHours);
  }

  Future<void> _selectTime(BuildContext context, String day, String type) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (_openingHours[day] == null) {
          _openingHours[day] = {'open': '09:00', 'close': '18:00'};
        }
        (_openingHours[day] as Map<String, String>)[type] = picked.format(context);
        widget.onHoursChanged(_openingHours);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Définir les horaires d\'ouverture'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _days.map((day) {
            final bool isDaySelected = _openingHours.containsKey(day);
            final openTime = isDaySelected ? _openingHours[day]['open'] : '--:--';
            final closeTime = isDaySelected ? _openingHours[day]['close'] : '--:--';

            return Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: isDaySelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _openingHours[day] = {'open': '09:00', 'close': '18:00'};
                          } else {
                            _openingHours.remove(day);
                          }
                          widget.onHoursChanged(_openingHours);
                        });
                      },
                      activeColor: AppColors.secondary,
                    ),
                    Expanded(child: Text(day)),
                  ],
                ),
                if (isDaySelected)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () => _selectTime(context, day, 'open'),
                        child: Text(openTime, style: const TextStyle(color: AppColors.secondary)),
                      ),
                      const Text(' - '),
                      GestureDetector(
                        onTap: () => _selectTime(context, day, 'close'),
                        child: Text(closeTime, style: const TextStyle(color: AppColors.secondary)),
                      ),
                    ],
                  ),
                Divider(),
              ],
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
