import 'package:flutter/services.dart';

class ItemCodeInputFormatter extends TextInputFormatter {
  const ItemCodeInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limitedDigits = digits.length > 12 ? digits.substring(0, 12) : digits;
    final formattedCode = formatItemCode(limitedDigits);

    return TextEditingValue(
      text: formattedCode,
      selection: TextSelection.collapsed(offset: formattedCode.length),
    );
  }
}

class SearchInputFormatter extends TextInputFormatter {
  const SearchInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final hasLetters = RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(text);
    final digits = text.replaceAll(RegExp(r'\D'), '');

    if (hasLetters || digits.isEmpty) {
      return newValue;
    }

    final limitedDigits = digits.length > 12 ? digits.substring(0, 12) : digits;
    final formattedCode = formatItemCode(limitedDigits);

    return TextEditingValue(
      text: formattedCode,
      selection: TextSelection.collapsed(offset: formattedCode.length),
    );
  }
}

String formatItemCode(String digits) {
  final groups = <String>[];

  for (var index = 0; index < digits.length; index += 4) {
    final end = (index + 4).clamp(0, digits.length);
    groups.add(digits.substring(index, end));
  }

  return groups.join('.');
}
