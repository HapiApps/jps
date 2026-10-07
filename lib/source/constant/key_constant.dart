
import 'package:flutter/services.dart';

final InputFormatters constInputFormatters = InputFormatters._();
class InputFormatters{

  InputFormatters._();
  // final List<TextInputFormatter> mobileNumberInput=[
  //   TextInputFormatter.withFunction((oldValue, newValue) {
  //     String text = newValue.text;
  //     text = text.replaceAll(RegExp(r'\D'), '');
  //     if (text.startsWith('91') && text.length > 10) {
  //       text = text.substring(2);
  //     }
  //     if (text.length > 10) {
  //       text = text.substring(text.length - 10);
  //     }
  //     return TextEditingValue(
  //       text: text,
  //       selection: TextSelection.collapsed(offset: text.length),
  //     );
  //   }),
  // ];


  final List<TextInputFormatter> mobileNumberInput = [
    TextInputFormatter.withFunction((oldValue, newValue) {
      String newText = newValue.text;
      String oldDigits = oldValue.text.replaceAll(RegExp(r'\D'), '');

      int cursorPos = newValue.selection.end;
      if (cursorPos < 0) cursorPos = newText.length;

      // cursor varaikum irukura raw text-la ethana digit irukku nu count pannunga
      int digitsBeforeCursor = 0;
      for (int i = 0; i < cursorPos && i < newText.length; i++) {
        if (RegExp(r'\d').hasMatch(newText[i])) {
          digitsBeforeCursor++;
        }
      }

      String digits = newText.replaceAll(RegExp(r'\D'), '');

      // 91 prefix strip
      if (digits.startsWith('91') && digits.length > 10) {
        digits = digits.substring(2);
        digitsBeforeCursor = (digitsBeforeCursor - 2).clamp(0, digits.length);
      }

      // 10 digit-ku mela irundha
      if (digits.length > 10) {
        // already 10 digits full ah irundhu, innoru digit mattum extra ah insert pannirundha
        // (paste illa, typing than) -> old value-ah return pannunga, edhuvum change pannadhu
        if (oldDigits.length >= 10 && digits.length - oldDigits.length <= 1) {
          return oldValue;
        }
        // idhu paste case (multiple digits ஒரே முறை add aachu) -> first 10 mattum clamp
        digits = digits.substring(0, 10);
      }

      int newCursor = digitsBeforeCursor.clamp(0, digits.length);

      return TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: newCursor),
      );
    }),
  ];

  final List<TextInputFormatter> daInput=[
    FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
  ];
  final List<TextInputFormatter> amtInput=[
    FilteringTextInputFormatter.digitsOnly,
    FilteringTextInputFormatter.allow(RegExp("[0-9]")),
    LengthLimitingTextInputFormatter(7),
  ];
// final List<TextInputFormatter> mobileNumberInput=[
//   LengthLimitingTextInputFormatter(10),
//   FilteringTextInputFormatter.digitsOnly,
//   FilteringTextInputFormatter.allow(RegExp("[0-9]"))
// ];
final List<TextInputFormatter> passwordInput=[
  LengthLimitingTextInputFormatter(16),
];
final List<TextInputFormatter> dateInput=[
  LengthLimitingTextInputFormatter(10),
  FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
];
final List<TextInputFormatter> decimalInput=[
  FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
];
final List<TextInputFormatter> aadharInput=[
  LengthLimitingTextInputFormatter(12),
  FilteringTextInputFormatter.digitsOnly,
  FilteringTextInputFormatter.allow(RegExp("[0-9]"))
];
final List<TextInputFormatter> panInput=[
  LengthLimitingTextInputFormatter(10),
  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]"))
];
final List<TextInputFormatter> pinCodeInput=[
  LengthLimitingTextInputFormatter(6),
  FilteringTextInputFormatter.allow(RegExp("[0-9]"))
];
final List<TextInputFormatter> numberInput=[
  FilteringTextInputFormatter.digitsOnly,
  FilteringTextInputFormatter.allow(RegExp("[0-9]"))
];

final List<TextInputFormatter> accNoInput=[
  LengthLimitingTextInputFormatter(20),
  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]"))
];
  final List<TextInputFormatter> dsaAccNoInput=[
    LengthLimitingTextInputFormatter(20),
    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]"))
  ];
final List<TextInputFormatter> ifscInput=[
  LengthLimitingTextInputFormatter(11),
  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]"))
];final List<TextInputFormatter> numTextInput=[
  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9 ]"))
];
final  List<TextInputFormatter> textInput=[
  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))];
  final List<TextInputFormatter> addressInput=[
    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9/,. ]"))
];
}