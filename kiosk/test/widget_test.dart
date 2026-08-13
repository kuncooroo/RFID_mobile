import 'package:flutter_test/flutter_test.dart';
import 'package:kiosk/services/rfid_keyboard_buffer.dart';
import 'package:flutter/services.dart';

void main() {
  test('RFID buffer commits on Enter', () {
    final buffer = RfidKeyboardBuffer();

    for (final rune in '0182120545'.runes) {
      final char = String.fromCharCode(rune);
      final result = buffer.handleKeyEvent(
        KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.keyA,
          logicalKey: LogicalKeyboardKey.keyA,
          character: char,
          timeStamp: Duration.zero,
        ),
      );
      expect(result, isNull);
    }

    final uid = buffer.handleKeyEvent(
      const KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.enter,
        logicalKey: LogicalKeyboardKey.enter,
        timeStamp: Duration.zero,
      ),
    );

    expect(uid, '0182120545');
  });
}
