import 'package:flutter/material.dart'; // Pour TimeOfDay

class OpeningHoursParser {
  static String getDayOfWeek(DateTime now) {
    switch (now.weekday) {
      case DateTime.monday: return 'Lundi';
      case DateTime.tuesday: return 'Mardi';
      case DateTime.wednesday: return 'Mercredi';
      case DateTime.thursday: return 'Jeudi';
      case DateTime.friday: return 'Vendredi';
      case DateTime.saturday: return 'Samedi';
      case DateTime.sunday: return 'Dimanche';
      default: return '';
    }
  }

  static TimeOfDay? parseTime(String? timeStr) {
    if (timeStr == null) return null;
    try {
      final normalized = timeStr
          .trim()
          .toLowerCase()
          .replaceAll('.', ':')
          .replaceAll('h', ':')
          .replaceAll(RegExp(r"\s+"), '');
      if (normalized.isEmpty) return null;
      final parts = normalized.contains(':') ? normalized.split(':') : [normalized, '00'];
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts.length > 1 && parts[1].isNotEmpty ? parts[1] : '00');
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  static bool isStoreOpenFromMap(Map<String, dynamic>? hoursMap, DateTime now) {
    if (hoursMap == null || hoursMap.isEmpty) return false;

    // Construire la liste des plages pour aujourd'hui
    final todayRanges = _rangesForDay(hoursMap, now.weekday);

    // Ajouter les plages de la veille qui passent minuit
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayRanges = _rangesForDay(hoursMap, yesterday.weekday);
    final currentMinutes = TimeOfDay.fromDateTime(now).hour * 60 + TimeOfDay.fromDateTime(now).minute;

    bool openInRanges(List<_TimeRange> ranges, {bool treatOvernight = false}) {
      for (final r in ranges) {
        final start = r.startTime.hour * 60 + r.startTime.minute;
        final end = r.endTime.hour * 60 + r.endTime.minute;
        if (start <= end) {
          if (currentMinutes >= start && currentMinutes < end) return true;
        } else if (treatOvernight) {
          // Plage overnight (ex: 22:00 - 02:00)
          if (currentMinutes < end) return true; // après minuit jusqu'à end
        }
      }
      return false;
    }

    if (openInRanges(todayRanges)) return true;
    if (openInRanges(yesterdayRanges, treatOvernight: true)) return true;
    return false;
  }

  // Formate les horaires du jour courant à partir d'une map d'horaires.
  // Retourne par exemple: "Lundi: 09:00-12:00, 14:00-18:00" ou "Fermé aujourd'hui".
  static String formatTodayHours(Map<String, dynamic>? hoursMap, DateTime now) {
    if (hoursMap == null || hoursMap.isEmpty) {
      return 'Non disponible';
    }

    final dayLabel = getDayOfWeek(now);
    final ranges = _rangesForDay(hoursMap, now.weekday);
    if (ranges.isEmpty) {
      return 'Fermé aujourd\'hui';
    }

    String _two(int n) => n.toString().padLeft(2, '0');
    String fmt(TimeOfDay t) => '${_two(t.hour)}:${_two(t.minute)}';
    final parts = ranges.map((r) => '${fmt(r.startTime)}-${fmt(r.endTime)}').join(', ');
    return '$dayLabel: $parts';
  }

  // Récupère les plages horaires pour un jour, en supportant plusieurs formats
  static List<_TimeRange> _rangesForDay(Map<String, dynamic> hoursMap, int weekday) {
    final List<_TimeRange> ranges = [];

    // Clés possibles pour ce jour (fr, abréviations, en)
    final keys = _possibleDayKeys(weekday);
    dynamic value;
    for (final k in keys) {
      if (hoursMap.containsKey(k)) {
        value = hoursMap[k];
        break;
      }
    }
    if (value == null) return ranges;

    void addRange(TimeOfDay? start, TimeOfDay? end) {
      if (start != null && end != null) ranges.add(_TimeRange(start, end));
    }

    if (value is String) {
      final v = value.trim().toLowerCase();
      if (v == 'fermé' || v == 'ferme' || v == 'closed') {
        return ranges;
      }
      // Supporte "09:00-12:00, 14:00-18:00" ou séparé par ";"
      final parts = v.replaceAll(';', ',').split(',');
      for (final p in parts) {
        final match = RegExp(r"(\d{1,2}[:h]\d{2})\s*-\s*(\d{1,2}[:h]\d{2})").firstMatch(p.trim());
        if (match != null) {
          addRange(parseTime(match.group(1)), parseTime(match.group(2)));
        }
      }
    } else if (value is Map) {
      // {open: "09:00", close: "18:00"} ou {morning:{open,close}, afternoon:{open,close}}
      if (value['open'] != null || value['close'] != null) {
        addRange(parseTime(value['open']?.toString()), parseTime(value['close']?.toString()));
      }
      for (final key in ['morning', 'afternoon', 'evening', 'pause1', 'pause2']) {
        final slot = value[key];
        if (slot is Map) {
          addRange(parseTime(slot['open']?.toString()), parseTime(slot['close']?.toString()));
        }
      }
    } else if (value is List) {
      // [ {open:..., close:...}, "09:00-12:00" ]
      for (final item in value) {
        if (item is Map) {
          addRange(parseTime(item['open']?.toString()), parseTime(item['close']?.toString()));
        } else if (item is String) {
          final match = RegExp(r"(\d{1,2}[:h]\d{2})\s*-\s*(\d{1,2}[:h]\d{2})").firstMatch(item.trim().toLowerCase());
          if (match != null) {
            addRange(parseTime(match.group(1)), parseTime(match.group(2)));
          }
        }
      }
    }

    return ranges;
  }

  static List<String> _possibleDayKeys(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return ['Lundi', 'lundi', 'lun', 'Lun', 'monday', 'Monday', 'mon'];
      case DateTime.tuesday:
        return ['Mardi', 'mardi', 'mar', 'Mar', 'tuesday', 'Tuesday', 'tue'];
      case DateTime.wednesday:
        return ['Mercredi', 'mercredi', 'mer', 'Mer', 'wednesday', 'Wednesday', 'wed'];
      case DateTime.thursday:
        return ['Jeudi', 'jeudi', 'jeu', 'Jeu', 'thursday', 'Thursday', 'thu'];
      case DateTime.friday:
        return ['Vendredi', 'vendredi', 'ven', 'Ven', 'friday', 'Friday', 'fri'];
      case DateTime.saturday:
        return ['Samedi', 'samedi', 'sam', 'Sam', 'saturday', 'Saturday', 'sat'];
      case DateTime.sunday:
        return ['Dimanche', 'dimanche', 'dim', 'Dim', 'sunday', 'Sunday', 'sun'];
      default:
        return [];
    }
  }

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

    for (final rule in rules) {
      if (rule.isOpenAt(now)) {
        return true;
      }
    }
    return false;
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

  bool isOpenAt(DateTime now) {
    if (isClosed) {
      return false;
    }
    if (startTime == null || endTime == null) {
      return false;
    }

    final currentTimeOfDay = TimeOfDay.fromDateTime(now);
    final startTimeInMinutes = startTime!.hour * 60 + startTime!.minute;
    final endTimeInMinutes = endTime!.hour * 60 + endTime!.minute;
    final currentTimeInMinutes = currentTimeOfDay.hour * 60 + currentTimeOfDay.minute;

    if (startTimeInMinutes <= endTimeInMinutes) {
      // Cas normal: 09h00-17h00
      return appliesToDay(now.weekday) &&
          currentTimeInMinutes >= startTimeInMinutes &&
          currentTimeInMinutes < endTimeInMinutes;
    } else {
      // Cas où la plage passe minuit: 22h00-02h00
      final previousDay = now.subtract(const Duration(days: 1));
      return (appliesToDay(now.weekday) && currentTimeInMinutes >= startTimeInMinutes) ||
          (appliesToDay(previousDay.weekday) && currentTimeInMinutes < endTimeInMinutes);
    }
  }
}

class _TimeRange {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  _TimeRange(this.startTime, this.endTime);
}
