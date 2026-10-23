
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Envelope containing all exported data with metadata
class ExportEnvelope {
  final String version;
  final DateTime exportDate;
  final String deviceId;
  final String appVersion;
  final ExportData data;
  final String checksum;

  ExportEnvelope({
    required this.version,
    required this.exportDate,
    required this.deviceId,
    required this.appVersion,
    required this.data,
    required this.checksum,
  });

  factory ExportEnvelope.create({
    required ExportData data,
    required String deviceId,
    required String appVersion,
  }) {
    final dataJson = jsonEncode(data.toJson());
    final checksum = md5.convert(utf8.encode(dataJson)).toString();
    
    return ExportEnvelope(
      version: '1.0',
      exportDate: DateTime.now(),
      deviceId: deviceId,
      appVersion: appVersion,
      data: data,
      checksum: checksum,
    );
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'exportDate': exportDate.toIso8601String(),
    'deviceId': deviceId,
    'appVersion': appVersion,
    'data': data.toJson(),
    'checksum': checksum,
  };

  factory ExportEnvelope.fromJson(Map<String, dynamic> json) {
    return ExportEnvelope(
      version: json['version'] as String,
      exportDate: DateTime.parse(json['exportDate'] as String),
      deviceId: json['deviceId'] as String,
      appVersion: json['appVersion'] as String,
      data: ExportData.fromJson(json['data'] as Map<String, dynamic>),
      checksum: json['checksum'] as String,
    );
  }

  /// Validate the checksum of the data
  bool validateChecksum() {
    final dataJson = jsonEncode(data.toJson());
    final calculatedChecksum = md5.convert(utf8.encode(dataJson)).toString();
    return calculatedChecksum == checksum;
  }
}

/// Container for all exportable data
class ExportData {
  final List<ExportableAppUsage> appUsage;
  final List<ExportableFocusSession> focusSessions;
  final List<ExportableAppMetadata> appMetadata;

  ExportData({
    required this.appUsage,
    required this.focusSessions,
    required this.appMetadata,
  });

  Map<String, dynamic> toJson() => {
    'appUsage': appUsage.map((e) => e.toJson()).toList(),
    'focusSessions': focusSessions.map((e) => e.toJson()).toList(),
    'appMetadata': appMetadata.map((e) => e.toJson()).toList(),
  };

  factory ExportData.fromJson(Map<String, dynamic> json) {
    return ExportData(
      appUsage: (json['appUsage'] as List)
          .map((e) => ExportableAppUsage.fromJson(e as Map<String, dynamic>))
          .toList(),
      focusSessions: (json['focusSessions'] as List)
          .map((e) => ExportableFocusSession.fromJson(e as Map<String, dynamic>))
          .toList(),
      appMetadata: (json['appMetadata'] as List)
          .map((e) => ExportableAppMetadata.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// JSON-serializable version of AppUsageRecord
class ExportableAppUsage {
  final String appName;
  final String dateKey;
  final String date;
  final int timeSpentMicroseconds;
  final int openCount;
  final List<ExportableTimeRange> usagePeriods;

  /// Seconds per hour of day. Null in exports made before this was recorded.
  final Map<int, int>? hourlySeconds;

  /// Sessions archived out of [usagePeriods]. Null in older exports.
  final Map<String, int>? sessionArchive;

  /// Sampled seconds per window title. Absent unless title recording was on.
  final Map<String, int>? titleSeconds;

  ExportableAppUsage({
    required this.appName,
    required this.dateKey,
    required this.date,
    required this.timeSpentMicroseconds,
    required this.openCount,
    required this.usagePeriods,
    this.hourlySeconds,
    this.sessionArchive,
    this.titleSeconds,
  });

  Map<String, dynamic> toJson() => {
    'appName': appName,
    'dateKey': dateKey,
    'date': date,
    'timeSpentMicroseconds': timeSpentMicroseconds,
    'openCount': openCount,
    'usagePeriods': usagePeriods.map((e) => e.toJson()).toList(),
    if (hourlySeconds != null)
      'hourlySeconds': hourlySeconds!.map((h, s) => MapEntry('$h', s)),
    if (sessionArchive != null) 'sessionArchive': sessionArchive,
    if (titleSeconds != null && titleSeconds!.isNotEmpty)
      'titleSeconds': titleSeconds,
  };

  factory ExportableAppUsage.fromJson(Map<String, dynamic> json) {
    return ExportableAppUsage(
      appName: json['appName'] as String,
      dateKey: json['dateKey'] as String,
      date: json['date'] as String,
      timeSpentMicroseconds: json['timeSpentMicroseconds'] as int,
      openCount: json['openCount'] as int,
      usagePeriods: (json['usagePeriods'] as List)
          .map((e) => ExportableTimeRange.fromJson(e as Map<String, dynamic>))
          .toList(),
      hourlySeconds: (json['hourlySeconds'] as Map?)
          ?.map((h, s) => MapEntry(int.parse('$h'), (s as num).toInt())),
      sessionArchive: (json['sessionArchive'] as Map?)
          ?.map((k, v) => MapEntry('$k', (v as num).toInt())),
      titleSeconds: (json['titleSeconds'] as Map?)
          ?.map((k, v) => MapEntry('$k', (v as num).toInt())),
    );
  }
}

/// JSON-serializable version of TimeRange
class ExportableTimeRange {
  final String startTime;
  final String endTime;

  ExportableTimeRange({
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() => {
    'startTime': startTime,
    'endTime': endTime,
  };

  factory ExportableTimeRange.fromJson(Map<String, dynamic> json) {
    return ExportableTimeRange(
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );
  }
}

/// JSON-serializable version of FocusSessionRecord
class ExportableFocusSession {
  final String key;
  final String date;
  final String startTime;
  final int durationMicroseconds;
  final List<String> appsBlocked;
  final bool completed;
  final int breakCount;
  final int totalBreakTimeMicroseconds;

  ExportableFocusSession({
    required this.key,
    required this.date,
    required this.startTime,
    required this.durationMicroseconds,
    required this.appsBlocked,
    required this.completed,
    required this.breakCount,
    required this.totalBreakTimeMicroseconds,
  });

  Map<String, dynamic> toJson() => {
    'key': key,
    'date': date,
    'startTime': startTime,
    'durationMicroseconds': durationMicroseconds,
    'appsBlocked': appsBlocked,
    'completed': completed,
    'breakCount': breakCount,
    'totalBreakTimeMicroseconds': totalBreakTimeMicroseconds,
  };

  factory ExportableFocusSession.fromJson(Map<String, dynamic> json) {
    return ExportableFocusSession(
      key: json['key'] as String,
      date: json['date'] as String,
      startTime: json['startTime'] as String,
      durationMicroseconds: json['durationMicroseconds'] as int,
      appsBlocked: (json['appsBlocked'] as List).cast<String>(),
      completed: json['completed'] as bool,
      breakCount: json['breakCount'] as int,
      totalBreakTimeMicroseconds: json['totalBreakTimeMicroseconds'] as int,
    );
  }
}

/// JSON-serializable version of AppMetadata
class ExportableAppMetadata {
  final String appName;
  final String category;
  final bool isProductive;
  final bool isTracking;
  final bool isVisible;
  final int dailyLimitMicroseconds;
  final bool limitStatus;

  ExportableAppMetadata({
    required this.appName,
    required this.category,
    required this.isProductive,
    required this.isTracking,
    required this.isVisible,
    required this.dailyLimitMicroseconds,
    required this.limitStatus,
  });

  Map<String, dynamic> toJson() => {
    'appName': appName,
    'category': category,
    'isProductive': isProductive,
    'isTracking': isTracking,
    'isVisible': isVisible,
    'dailyLimitMicroseconds': dailyLimitMicroseconds,
    'limitStatus': limitStatus,
  };

  factory ExportableAppMetadata.fromJson(Map<String, dynamic> json) {
    return ExportableAppMetadata(
      appName: json['appName'] as String,
      category: json['category'] as String,
      isProductive: json['isProductive'] as bool,
      isTracking: json['isTracking'] as bool,
      isVisible: json['isVisible'] as bool,
      dailyLimitMicroseconds: json['dailyLimitMicroseconds'] as int,
      limitStatus: json['limitStatus'] as bool,
    );
  }
}

/// Import options
enum ImportMode {
  replace,  // Replace all existing data
  merge,    // Merge with existing data (newer wins)
  append,   // Only add new data, don't update existing
}

/// Result of import operation
class ImportResult {
  final bool success;
  final String? error;
  final int usageRecordsImported;
  final int focusSessionsImported;
  final int metadataRecordsImported;
  final int recordsSkipped;
  final int recordsUpdated;

  ImportResult({
    required this.success,
    this.error,
    this.usageRecordsImported = 0,
    this.focusSessionsImported = 0,
    this.metadataRecordsImported = 0,
    this.recordsSkipped = 0,
    this.recordsUpdated = 0,
  });

  factory ImportResult.failure(String error) {
    return ImportResult(success: false, error: error);
  }

  factory ImportResult.success({
    required int usageRecords,
    required int focusSessions,
    required int metadataRecords,
    int skipped = 0,
    int updated = 0,
  }) {
    return ImportResult(
      success: true,
      usageRecordsImported: usageRecords,
      focusSessionsImported: focusSessions,
      metadataRecordsImported: metadataRecords,
      recordsSkipped: skipped,
      recordsUpdated: updated,
    );
  }
}