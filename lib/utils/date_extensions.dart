extension DateTimeCalendarMath on DateTime {
  /// Moves by [days] calendar days, keeping the wall-clock time.
  ///
  /// `add(Duration(days: n))` is n * 24h, which lands an hour off (and no
  /// longer at midnight) when the range crosses a DST change, so date-only
  /// keys built from it stop matching stored days.
  DateTime addDays(int days) => isUtc
      ? DateTime.utc(year, month, day + days, hour, minute, second,
          millisecond, microsecond)
      : DateTime(year, month, day + days, hour, minute, second, millisecond,
          microsecond);
}
