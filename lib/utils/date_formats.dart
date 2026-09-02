import 'package:intl/intl.dart';

/// Central place for the date/time patterns used across the app so the
/// same logical value (e.g. "weekday, month day") always renders the
/// same way regardless of which screen formats it.
class AppDateFormat {
  AppDateFormat._();

  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');
  static final DateFormat _isoDateTime = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat _isoDateTimeSeconds =
      DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _exportTimestamp = DateFormat('yyyyMMdd_HHmmss');
  static final DateFormat _shortDate = DateFormat('MM/dd');
  static final DateFormat _dayMonth = DateFormat('d/M');
  static final DateFormat _weekdayShort = DateFormat('EEE');
  static final DateFormat _weekdayFull = DateFormat('EEEE');
  static final DateFormat _weekdayWithDate = DateFormat('EEE, MMM d');
  static final DateFormat _weekdayFullWithDate = DateFormat('EEEE, MMM d');
  static final DateFormat _month = DateFormat('MMM');
  static final DateFormat _monthYear = DateFormat('MMM yyyy');
  static final DateFormat _sessionTimestamp = DateFormat('MMM d, HH:mm');

  /// 'yyyy-MM-dd' — canonical machine-readable date, used as a
  /// serialization/lookup key as well as for display.
  static String isoDate(DateTime d) => _isoDate.format(d);
  static DateTime parseIsoDate(String s) => _isoDate.parse(s);

  /// 'yyyy-MM-dd HH:mm'
  static String isoDateTime(DateTime d) => _isoDateTime.format(d);

  /// 'yyyy-MM-dd HH:mm:ss'
  static String isoDateTimeSeconds(DateTime d) =>
      _isoDateTimeSeconds.format(d);

  /// 'yyyyMMdd_HHmmss' — used for export/backup file names.
  static String exportTimestamp(DateTime d) => _exportTimestamp.format(d);

  /// 'MM/dd' — short chart-axis / chip date, also used as an internal
  /// day key in a few places (parsed back with [parseShortDate]).
  static String shortDate(DateTime d) => _shortDate.format(d);
  static DateTime parseShortDate(String s) => _shortDate.parse(s);

  /// 'd/M' — compact chart-axis date.
  static String dayMonth(DateTime d) => _dayMonth.format(d);

  /// 'EEE' — Mon, Tue, ...
  static String weekdayShort(DateTime d) => _weekdayShort.format(d);

  /// 'EEEE' — Monday, Tuesday, ...
  static String weekdayFull(DateTime d) => _weekdayFull.format(d);

  /// 'EEE, MMM d' — canonical compact "weekday, month day" display used
  /// for chart tooltips and similar in-app UI.
  static String weekdayWithDate(DateTime d) => _weekdayWithDate.format(d);

  /// 'EEEE, MMM d' — full-weekday variant for formal contexts like the
  /// exported analytics spreadsheet.
  static String weekdayFullWithDate(DateTime d) =>
      _weekdayFullWithDate.format(d);

  /// 'MMM' — Jan, Feb, ...
  static String month(DateTime d) => _month.format(d);

  /// 'MMM yyyy' — Jan 2026
  static String monthYear(DateTime d) => _monthYear.format(d);

  /// 'MMM d, HH:mm' — used for focus session history rows.
  static String sessionTimestamp(DateTime d) => _sessionTimestamp.format(d);
}
