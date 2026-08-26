import 'package:flutter/services.dart';

/// Collects USB RFID keyboard-wedge keystrokes until Enter.
class RfidKeyboardBuffer {
  final StringBuffer _buffer = StringBuffer();

  String? handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return null;

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      final value = _buffer.toString().trim();
      _buffer.clear();
      return value.isEmpty ? null : value;
    }

    final character = event.character;
    if (character == null || character.isEmpty) return null;
    if (character == '\n' || character == '\r') return null;
    if (character.length == 1 && character.codeUnitAt(0) >= 32) {
      _buffer.write(character);
    }
    return null;
  }

  void clear() => _buffer.clear();
}
