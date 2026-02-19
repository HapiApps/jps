
import 'package:flutter/services.dart';

final InputFormatters constInputFormatters = InputFormatters._();
class InputFormatters{

  InputFormatters._();
  final List<TextInputFormatter> daInput=[
    FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
  ];
  final List<TextInputFormatter> amtInput=[
    FilteringTextInputFormatter.digitsOnly,
    FilteringTextInputFormatter.allow(RegExp("[0-9]")),
    LengthLimitingTextInputFormatter(7),
  ];
final List<TextInputFormatter> mobileNumberInput=[
  LengthLimitingTextInputFormatter(10),
  FilteringTextInputFormatter.digitsOnly,
  FilteringTextInputFormatter.allow(RegExp("[0-9]"))
];
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