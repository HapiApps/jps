import 'package:flutter/material.dart';

extension IntExtensions on int? {
  int validate({int value = 0}) {
    return this ?? value;
  }

  Widget get height => SizedBox(height: this?.toDouble());

  Widget get width => SizedBox(width: this?.toDouble());

  bool isSuccessful() {
    return this! >= 200 && this! <= 206;
  }

  Duration get microseconds => Duration(microseconds: validate());
  Duration get milliseconds => Duration(milliseconds: validate());
  Duration get seconds => Duration(seconds: validate());
  Duration get minutes => Duration(minutes: validate());
  Duration get hours => Duration(hours: validate());
  Duration get days => Duration(days: validate());

  // return suffix (th,st,nd,rd) of the given number
  String numberSuffix() {
    if (this! >= 11 && this! <= 13) {
      return '$this th';
    }
    if ((this! % 10 >= 1 || this! % 10 <= 3) && (this! % 100 / 10 == 1)) {
      return '$this th';
    }

    switch (this! % 10) {
      case 1:
        return '$this st';
      case 2:
        return '$this nd';
      case 3:
        return '$this rd';
      default:
        return '$this th';
    }
  }
}
