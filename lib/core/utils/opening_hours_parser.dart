import 'package:flutter/material.dart'; // Pour TimeOfDay

class OpeningHoursParser {
  static const Map<String, int> _dayAbbreviations = {
    'lun': DateTime.monday,
    'mar': DateTime.tuesday,
    'mer': DateTime.wednesday,
    'jeu': DateTime.thursday,
    'ven': DateTime.friday,
    'sam': DateTime.saturday,
    'dim': DateTime.sunday,
  };

  static bool isStoreOpen(String? hoursString, DateTime now) {
    if (hoursString == null || hoursString.isEmpty || hoursString.toLowerCase() == 'horaires indisponibles') {
      return false;
    }

    final rules = _parseRules(hoursString);
    if (rules.isEmpty) {
      return false; // Si aucune règle valide n'est parsée, considérer comme fermé
    }

    final currentDayOfWeek = now.weekday;
    final currentTimeOfDay = TimeOfDay.fromDateTime(now);

    for (final rule in rules) {
      if (rule.appliesToDay(currentDayOfWeek)) {
        if (rule.isClosed) {
          return false; // Règle explicite de fermeture pour ce jour
        }
        if (rule.startTime != null && rule.endTime != null) {
          // Convertir TimeOfDay en minutes pour une comparaison facile
          final startTimeInMinutes = rule.startTime!.hour * 60 + rule.startTime!.minute;
          final endTimeInMinutes = rule.endTime!.hour * 60 + rule.endTime!.minute;
          final currentTimeInMinutes = currentTimeOfDay.hour * 60 + currentTimeOfDay.minute;

          if (startTimeInMinutes <= endTimeInMinutes) {
            // Cas normal: 09h00-17h00
            if (currentTimeInMinutes >= startTimeInMinutes && currentTimeInMinutes < endTimeInMinutes) {
              return true;
            }
          } else {
            // Cas où la plage passe minuit: 22h00-02h00
            // Ouvert si heure actuelle >= heure début OU heure actuelle < heure fin
            if (currentTimeInMinutes >= startTimeInMinutes || currentTimeInMinutes < endTimeInMinutes) {
              return true;
            }
          }
        }
      }
    }
    return false; // Aucune règle d'ouverture trouvée pour le jour/heure actuel
  }

  static List<_OpeningHoursRule> _parseRules(String hoursString) {
    final List<_OpeningHoursRule> rules = [];
    final segments = hoursString.split(';').map((s) => s.trim()).where((s) => s.isNotEmpty);

    for (final segment in segments) {
      final parts = segment.split(':');
      if (parts.length != 2) continue; // Format incorrect

      final daysPart = parts[0].trim();
      final timePart = parts[1].trim();

      final List<int> applicableDays = _parseDaysPart(daysPart);
      if (applicableDays.isEmpty) continue;

      if (timePart.toLowerCase() == 'fermé') {
        rules.add(_OpeningHoursRule(daysOfWeek: applicableDays, isClosed: true));
      } else {
        final timeRange = _parseTimePart(timePart);
        if (timeRange != null) {
          rules.add(_OpeningHoursRule(
            daysOfWeek: applicableDays,
            startTime: timeRange.startTime,
            endTime: timeRange.endTime,
          ));
        }
      }
    }
    return rules;
  }

  static List<int> _parseDaysPart(String daysPart) {
    final List<int> days = [];
    final daySegments = daysPart.split(',').map((s) => s.trim().toLowerCase());

    for (final segment in daySegments) {
      if (segment.contains('-')) {
        // C'est une plage, ex: "lun-ven"
        final rangeParts = segment.split('-');
        if (rangeParts.length == 2) {
          final startDayAbbr = rangeParts[0];
          final endDayAbbr = rangeParts[1];
          if (_dayAbbreviations.containsKey(startDayAbbr) && _dayAbbreviations.containsKey(endDayAbbr)) {
            int startDay = _dayAbbreviations[startDayAbbr]!;
            int endDay = _dayAbbreviations[endDayAbbr]!;

            // Gérer le cas où la plage traverse la fin de semaine (ex: Ven-Lun)
            // Pour simplifier, on assume que startDay <= endDay dans une semaine normale.
            // Une logique plus complexe serait nécessaire pour Ven-Lun, mais peu courant pour les spec.
            if (startDay <= endDay) {
              for (int i = startDay; i <= endDay; i++) {
                days.add(i);
              }
            } else { // Ex: Sam-Lun (Samedi, Dimanche, Lundi)
                for (int i = startDay; i <= DateTime.sunday; i++) {
                    days.add(i);
                }
                for (int i = DateTime.monday; i <= endDay; i++) {
                    days.add(i);
                }
            }
          }
        }
      } else {
        // C'est un jour unique
        if (_dayAbbreviations.containsKey(segment)) {
          days.add(_dayAbbreviations[segment]!);
        }
      }
    }
    return days.toSet().toList(); // Enlever les doublons et retourner
  }

  static _TimeRange? _parseTimePart(String timePart) {
    final match = RegExp(r"(\d{1,2})h(\d{2})-(\d{1,2})h(\d{2})").firstMatch(timePart);
    if (match != null) {
      try {
        final startHour = int.parse(match.group(1)!);
        final startMinute = int.parse(match.group(2)!);
        final endHour = int.parse(match.group(3)!);
        final endMinute = int.parse(match.group(4)!);

        if (startHour >= 0 && startHour < 24 && startMinute >= 0 && startMinute < 60 &&
            endHour >= 0 && endHour < 24 && endMinute >= 0 && endMinute < 60) {
          return _TimeRange(
            TimeOfDay(hour: startHour, minute: startMinute),
            TimeOfDay(hour: endHour, minute: endMinute),
          );
        }
      } catch (e) {
        // Erreur de parsing des entiers, ignorer cette plage
      }
    }
    return null;
  }
}

class _OpeningHoursRule {
  final List<int> daysOfWeek; // DateTime.monday, etc.
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final bool isClosed;

  _OpeningHoursRule({
    required this.daysOfWeek,
    this.startTime,
    this.endTime,
    this.isClosed = false,
  });

  bool appliesToDay(int dayOfWeek) {
    return daysOfWeek.contains(dayOfWeek);
  }
}

class _TimeRange {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  _TimeRange(this.startTime, this.endTime);
}
