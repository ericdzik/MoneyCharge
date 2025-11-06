import 'package:flutter_test/flutter_test.dart';
import 'package:locacharge/core/utils/opening_hours_parser.dart';
// Pour TimeOfDay, bien que non directement utilisé dans les asserts ici

void main() {
  group('OpeningHoursParser.isStoreOpen', () {
    // Helper pour créer des DateTime spécifiques pour les tests
    DateTime dateTime(int year, int month, int day, int hour, int minute) {
      return DateTime(year, month, day, hour, minute);
    }

    test('should return false for null, empty or invalid hours string', () {
      final now = DateTime.now();
      expect(OpeningHoursParser.isStoreOpen(null, now), isFalse);
      expect(OpeningHoursParser.isStoreOpen('', now), isFalse);
      expect(OpeningHoursParser.isStoreOpen('horaires indisponibles', now), isFalse);
      expect(OpeningHoursParser.isStoreOpen('format incorrect', now), isFalse);
    });

    group('Single rule, same day:', () {
      // Lundi 13 Mai 2024
      final monday = dateTime(2024, 5, 13, 0, 0); // Un lundi

      test('open during working hours', () {
        final hours = "Lun: 09h00-17h00";
        // Test à 10h00 un lundi
        expect(OpeningHoursParser.isStoreOpen(hours, monday.copyWith(hour: 10)), isTrue);
      });

      test('closed before opening hours', () {
        final hours = "Lun: 09h00-17h00";
        // Test à 08h00 un lundi
        expect(OpeningHoursParser.isStoreOpen(hours, monday.copyWith(hour: 8)), isFalse);
      });

      test('closed after closing hours (at closing hour, considered closed)', () {
        final hours = "Lun: 09h00-17h00";
        // Test à 17h00 un lundi (limite exclusive pour la fin)
        expect(OpeningHoursParser.isStoreOpen(hours, monday.copyWith(hour: 17)), isFalse);
      });

      test('open exactly at opening hour', () {
        final hours = "Lun: 09h00-17h00";
        // Test à 09h00 un lundi
        expect(OpeningHoursParser.isStoreOpen(hours, monday.copyWith(hour: 9, minute: 0)), isTrue);
      });

      test('closed on a different day', () {
        final hours = "Lun: 09h00-17h00";
        // Test un mardi (jour 14)
        expect(OpeningHoursParser.isStoreOpen(hours, monday.copyWith(day: 14, hour: 10)), isFalse);
      });

      test('explicitly closed', () {
        final hours = "Lun: Fermé";
        expect(OpeningHoursParser.isStoreOpen(hours, monday.copyWith(hour: 10)), isFalse);
      });
    });

    group('Day ranges:', () {
      final monday = dateTime(2024, 5, 13, 10, 0); // Lundi 10h00
      final wednesday = dateTime(2024, 5, 15, 10, 0); // Mercredi 10h00
      final saturday = dateTime(2024, 5, 18, 10, 0); // Samedi 10h00

      test('open within Lun-Ven range', () {
        final hours = "Lun-Ven: 09h00-17h00";
        expect(OpeningHoursParser.isStoreOpen(hours, monday), isTrue);
        expect(OpeningHoursParser.isStoreOpen(hours, wednesday), isTrue);
      });

      test('closed outside Lun-Ven range (e.g., Saturday)', () {
        final hours = "Lun-Ven: 09h00-17h00";
        expect(OpeningHoursParser.isStoreOpen(hours, saturday), isFalse);
      });

      test('range Sam-Dim, open on Dimanche', () {
        final hours = "sam-dim: 10h00-16h00";
        final sunday = dateTime(2024, 5, 19, 11, 0); // Dimanche 11h00
        expect(OpeningHoursParser.isStoreOpen(hours, sunday), isTrue);
      });

      test('range Ven-Mar (Friday to Tuesday), open on Monday', () {
        final hours = "Ven-Mar: 08h00-20h00";
         // Lundi 13 Mai 2024 à 10h00
        expect(OpeningHoursParser.isStoreOpen(hours, dateTime(2024, 5, 13, 10, 0)), isTrue);
        // Mardi 14 Mai 2024 à 10h00
        expect(OpeningHoursParser.isStoreOpen(hours, dateTime(2024, 5, 14, 10, 0)), isTrue);
        // Mercredi 15 Mai 2024 à 10h00 (doit être fermé)
        expect(OpeningHoursParser.isStoreOpen(hours, dateTime(2024, 5, 15, 10, 0)), isFalse);
        // Vendredi 17 Mai 2024 à 10h00
        expect(OpeningHoursParser.isStoreOpen(hours, dateTime(2024, 5, 17, 10, 0)), isTrue);
      });
    });

    group('Multiple rules:', () {
      final hours = "Lun-Ven: 09h00-18h00; Sam: 10h00-14h00; Dim: Fermé";

      test('open on weekday', () {
        // Mercredi 10h00
        expect(OpeningHoursParser.isStoreOpen(hours, dateTime(2024, 5, 15, 10, 0)), isTrue);
      });

      test('open on Saturday', () {
        // Samedi 11h00
        expect(OpeningHoursParser.isStoreOpen(hours, dateTime(2024, 5, 18, 11, 0)), isTrue);
      });

      test('closed on Saturday outside hours', () {
        // Samedi 15h00
        expect(OpeningHoursParser.isStoreOpen(hours, dateTime(2024, 5, 18, 15, 0)), isFalse);
      });

      test('closed on Sunday', () {
        // Dimanche 11h00
        expect(OpeningHoursParser.isStoreOpen(hours, dateTime(2024, 5, 19, 11, 0)), isFalse);
      });
    });

    group('Overnight hours:', () {
      // Mardi 14 Mai 2024
      final tuesday = dateTime(2024, 5, 14, 0, 0);

      test('open late at night (before midnight)', () {
        final hours = "Mar: 22h00-02h00"; // Mardi 22h au Mercredi 2h
        // Test Mardi à 23h00
        expect(OpeningHoursParser.isStoreOpen(hours, tuesday.copyWith(hour: 23)), isTrue);
      });

      test('open early morning (after midnight, same rule)', () {
        final hours = "Mar: 22h00-02h00"; // Mardi 22h au Mercredi 2h
        // Test Mercredi à 01h00 (correspond à la règle de Mardi)
        expect(OpeningHoursParser.isStoreOpen(hours, tuesday.copyWith(day: 15, hour: 1)), isTrue);
      });

      test('closed after overnight closing time', () {
        final hours = "Mar: 22h00-02h00";
        // Test Mercredi à 03h00
        expect(OpeningHoursParser.isStoreOpen(hours, tuesday.copyWith(day: 15, hour: 3)), isFalse);
      });

      test('closed before overnight starting time', () {
        final hours = "Mar: 22h00-02h00";
        // Test Mardi à 21h00
        expect(OpeningHoursParser.isStoreOpen(hours, tuesday.copyWith(hour: 21)), isFalse);
      });

      test('complex overnight with other rules', () {
        final hours = "Lun: 09h00-17h00; Mar: 22h00-02h00; Mer: 09h00-17h00";
        // Test Mardi à 23h00 -> Ouvert
        expect(OpeningHoursParser.isStoreOpen(hours, dateTime(2024,5,14,23,0)), isTrue, reason: "Mardi 23h");
        // Test Mercredi à 01h00 -> Ouvert (règle de Mardi)
        expect(OpeningHoursParser.isStoreOpen(hours, dateTime(2024,5,15,1,0)), isTrue, reason: "Mercredi 1h (règle de Mar)");
        // Test Mercredi à 08h00 -> Fermé
        expect(OpeningHoursParser.isStoreOpen(hours, dateTime(2024,5,15,8,0)), isFalse, reason: "Mercredi 8h");
        // Test Mercredi à 10h00 -> Ouvert (règle de Mercredi)
        expect(OpeningHoursParser.isStoreOpen(hours, dateTime(2024,5,15,10,0)), isTrue, reason: "Mercredi 10h");
      });
    });

    group('Day list parsing', () {
      test('open on listed day (Sam,Dim)', () {
        final hours = "Sam,Dim: 10h00-15h00";
        // Samedi 11h00
        expect(OpeningHoursParser.isStoreOpen(hours, dateTime(2024,5,18,11,0)), isTrue);
        // Dimanche 11h00
        expect(OpeningHoursParser.isStoreOpen(hours, dateTime(2024,5,19,11,0)), isTrue);
        // Lundi 11h00
        expect(OpeningHoursParser.isStoreOpen(hours, dateTime(2024,5,13,11,0)), isFalse);
      });
    });

    group('Case insensitivity and spacing', () {
      test('handles varied casing and spacing for days and "Fermé"', () {
        // Lundi 13 Mai 2024
        final monday = dateTime(2024, 5, 13, 0, 0);
        final tuesday = dateTime(2024, 5, 14, 0, 0);

        expect(OpeningHoursParser.isStoreOpen("LUN: 09h00-17h00", monday.copyWith(hour: 10)), isTrue, reason: "LUN majuscule");
        expect(OpeningHoursParser.isStoreOpen("mar:fermé", tuesday.copyWith(hour: 10)), isFalse, reason: "mar minuscule et 'fermé'");
        expect(OpeningHoursParser.isStoreOpen(" Mer : 10h00-12h00 ", monday.copyWith(day:15, hour:11)), isTrue, reason: "Espaces autour de Mer");
        expect(OpeningHoursParser.isStoreOpen("jeu: FERMÉ", monday.copyWith(day:16, hour:11)), isFalse, reason: "Jeu FERMÉ majuscule");
      });
    });

     group('Parsing robustness and edge cases', () {
      test('handles single digit hour in HHhMM format in parser', () {
        // Le parser _parseTimePart devrait gérer ça grâce à \d{1,2}
        final hours = "Lun: 9h00-17h00";
        // Lundi 13 Mai 2024 à 10h00
        expect(OpeningHoursParser.isStoreOpen(hours, dateTime(2024, 5, 13, 10, 0)), isTrue);
      });

      test('malformed time range string', () {
        final hours = "Lun: 09h00-17h"; // Minute manquante
        expect(OpeningHoursParser.isStoreOpen(hours, dateTime(2024, 5, 13, 10, 0)), isFalse);
      });

      test('malformed day specification', () {
        final hours = "Lunn-Ven: 09h00-17h00";
        expect(OpeningHoursParser.isStoreOpen(hours, dateTime(2024, 5, 13, 10, 0)), isFalse);
      });

      test('empty segments or extra semicolons', () {
        final hours = "Lun: 09h00-17h00;;Mar: 10h00-12h00";
        expect(OpeningHoursParser.isStoreOpen(hours, dateTime(2024, 5, 13, 10, 0)), isTrue); // Lundi
        expect(OpeningHoursParser.isStoreOpen(hours, dateTime(2024, 5, 14, 11, 0)), isTrue); // Mardi
      });
    });

  });
}
