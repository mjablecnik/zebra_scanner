import 'package:flutter/foundation.dart';

extension SubRoute on String {
  relative() {
    return '.' + this;
  }

  absolute() {
    return this;
  }
}

extension StringExtension on String {
  toEnum(values) => values.firstWhere((d) => describeEnum(d).toLowerCase() == this.toLowerCase());

  escapeEndLines() => this.replaceAll("\n", "\\n");
}

extension DateTimeExtension on DateTime {
  roundToHour() => DateTime(this.year, this.month, this.day, this.hour);
}
