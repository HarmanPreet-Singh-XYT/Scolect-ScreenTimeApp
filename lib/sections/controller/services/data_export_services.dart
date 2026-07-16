import 'dart:convert';
import 'dart:io';
import 'package:screentime/utils/platform_utils.dart';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/export_models.dart';
import '../app_data_controller.dart'; // Your existing file

class DataExportService {
  final AppDataStore _dataStore;

  // File extension for exports
  static const String exportExtension = '.stbackup'; // screentime backup
  static const String exportMimeType = 'application/octet-stream';

  DataExportService(this._dataStore);

  /// Export all data to a compressed file
  Future<ExportResult> exportData({
    Function(double progress, String status)? onProgress,
    bool compress = true,
  }) async {
    try {
      onProgress?.call(0.0, 'Preparing export...');

      if (!_dataStore.isInitialized) {
        return ExportResult.failure('Data store not initialized');
      }

      // Step 1: Collect all data
      onProgress?.call(0.1, 'Collecting usage data...');
      final appUsageData = await _collectAppUsageData();

      onProgress?.call(0.3, 'Collecting focus sessions...');
      final focusSessionData = await _collectFocusSessionData();

      onProgress?.call(0.5, 'Collecting app metadata...');
      final metadataData = await _collectMetadataData();

      // Step 2: Create export data structure
      onProgress?.call(0.6, 'Creating export package...');
      final exportData = ExportData(
        appUsage: appUsageData,
        focusSessions: focusSessionData,
        appMetadata: metadataData,
      );

      // Step 3: Create envelope with metadata
      final envelope = ExportEnvelope.create(
        data: exportData,
        deviceId: await _getDeviceId(),
        appVersion: await _getAppVersion(),
      );

      // Step 4: Convert to JSON
      onProgress?.call(0.7, 'Serializing data...');
      final jsonString = jsonEncode(envelope.toJson());

      // Step 5: Compress (optional)
      Uint8List fileData;
      String fileName;

      if (compress) {
        onProgress?.call(0.8, 'Compressing data...');
        fileData = _compressData(utf8.encode(jsonString));
        fileName =
            'screentime_backup_${_formatDateTime(DateTime.now())}$exportExtension';
      } else {
        fileData = Uint8List.fromList(utf8.encode(jsonString));
        fileName = 'screentime_backup_${_formatDateTime(DateTime.now())}.json';
      }

      // Step 6: Save to file
      onProgress?.call(0.9, 'Saving file...');
      final filePath = await _saveToFile(fileData, fileName);

      onProgress?.call(1.0, 'Export complete!');

      return ExportResult.success(
        filePath: filePath,
        fileName: fileName,
        fileSize: fileData.length,
        recordCount:
            appUsageData.length + focusSessionData.length + metadataData.length,
      );
    } catch (e, stackTrace) {
      debugPrint('Export error: $e\n$stackTrace');
      return ExportResult.failure('Export failed: $e');
    }
  }

  /// Import data from a file
  Future<ImportResult> importData({
    String? filePath,
    ImportMode mode = ImportMode.merge,
    Function(double progress, String status)? onProgress,
  }) async {
    try {
      onProgress?.call(0.0, 'Starting import...');

      if (!_dataStore.isInitialized) {
        return ImportResult.failure('Data store not initialized');
      }

      // Step 1: Get file path if not provided
      String? path = filePath;
      if (path == null) {
        onProgress?.call(0.05, 'Selecting file...');
        path = await _pickImportFile();
        if (path == null) {
          return ImportResult.failure('No file selected');
        }
      }

      // Step 2: Read file
      onProgress?.call(0.1, 'Reading file...');
      final file = File(path);
      if (!await file.exists()) {
        return ImportResult.failure('File not found');
      }

      final fileBytes = await file.readAsBytes();

      // Step 3: Decompress if needed
      onProgress?.call(0.2, 'Processing file...');
      String jsonString;

      if (path.endsWith(exportExtension)) {
        try {
          jsonString = _decompressData(fileBytes);
        } catch (e) {
          return ImportResult.failure('Failed to decompress file: $e');
        }
      } else {
        jsonString = utf8.decode(fileBytes);
      }

      // Step 4: Parse JSON
      onProgress?.call(0.3, 'Parsing data...');
      Map<String, dynamic> jsonData;
      try {
        jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return ImportResult.failure('Invalid file format: $e');
      }

      // Step 5: Validate envelope
      onProgress?.call(0.35, 'Validating data...');
      ExportEnvelope envelope;
      try {
        envelope = ExportEnvelope.fromJson(jsonData);
      } catch (e) {
        return ImportResult.failure('Invalid backup format: $e');
      }

      // Validate checksum
      if (!envelope.validateChecksum()) {
        return ImportResult.failure(
            'Data integrity check failed. The file may be corrupted.');
      }

      // Check version compatibility
      if (!_isVersionCompatible(envelope.version)) {
        return ImportResult.failure(
            'Incompatible backup version: ${envelope.version}. '
            'Please update the app to import this backup.');
      }

      // Step 6: Import data based on mode
      int usageImported = 0;
      int focusImported = 0;
      int metadataImported = 0;
      int skipped = 0;
      int updated = 0;

      // Import metadata first
      onProgress?.call(0.4, 'Importing app metadata...');
      final metadataResult = await _importMetadata(
        envelope.data.appMetadata,
        mode,
      );
      metadataImported = metadataResult['imported'] ?? 0;
      skipped += metadataResult['skipped'] ?? 0;
      updated += metadataResult['updated'] ?? 0;

      // Import usage data
      onProgress?.call(0.6, 'Importing usage data...');
      final usageResult = await _importUsageData(
        envelope.data.appUsage,
        mode,
      );
      usageImported = usageResult['imported'] ?? 0;
      skipped += usageResult['skipped'] ?? 0;
      updated += usageResult['updated'] ?? 0;

      // Import focus sessions
      onProgress?.call(0.8, 'Importing focus sessions...');
      final focusResult = await _importFocusSessions(
        envelope.data.focusSessions,
        mode,
      );
      focusImported = focusResult['imported'] ?? 0;
      skipped += focusResult['skipped'] ?? 0;
      updated += focusResult['updated'] ?? 0;

      onProgress?.call(1.0, 'Import complete!');

      return ImportResult.success(
        usageRecords: usageImported,
        focusSessions: focusImported,
        metadataRecords: metadataImported,
        skipped: skipped,
        updated: updated,
      );
    } catch (e, stackTrace) {
      debugPrint('Import error: $e\n$stackTrace');
      return ImportResult.failure('Import failed: $e');
    }
  }

  /// Share exported file
  Future<bool> shareExport(String filePath) async {
    try {
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Screen Time Backup',
        text: 'My Screen Time data backup',
      );
      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('Share error: $e');
      return false;
    }
  }

  // ============ Private Helper Methods ============

  /// Collect all app usage data
  Future<List<ExportableAppUsage>> _collectAppUsageData() async {
    final List<ExportableAppUsage> result = [];

    for (final appName in _dataStore.allAppNames) {
      // Get usage for last 365 days (or all available)
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 365));

      final usageRecords = _dataStore.getAppUsageRange(appName, startDate, now);

      for (final record in usageRecords) {
        result.add(ExportableAppUsage(
          appName: appName,
          dateKey: '$appName:${_formatDateKey(record.date)}',
          date: record.date.toIso8601String(),
          timeSpentMicroseconds: record.timeSpent.inMicroseconds,
          openCount: record.openCount,
          usagePeriods: record.usagePeriods
              .map((period) => ExportableTimeRange(
                    startTime: period.startTime.toIso8601String(),
                    endTime: period.endTime.toIso8601String(),
                  ))
              .toList(),
        ));
      }
    }

    return result;
  }

  /// Collect all focus session data
  Future<List<ExportableFocusSession>> _collectFocusSessionData() async {
    final List<ExportableFocusSession> result = [];

    // Get sessions for last 365 days
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 365));

    final sessions = _dataStore.getFocusSessionsRange(startDate, now);

    for (final session in sessions) {
      final key =
          '${_formatDateKey(session.date)}:${session.startTime.millisecondsSinceEpoch}';

      result.add(ExportableFocusSession(
        key: key,
        date: session.date.toIso8601String(),
        startTime: session.startTime.toIso8601String(),
        durationMicroseconds: session.duration.inMicroseconds,
        appsBlocked: session.appsBlocked,
        completed: session.completed,
        breakCount: session.breakCount,
        totalBreakTimeMicroseconds: session.totalBreakTime.inMicroseconds,
      ));
    }

    return result;
  }

  /// Collect all app metadata
  Future<List<ExportableAppMetadata>> _collectMetadataData() async {
    final List<ExportableAppMetadata> result = [];

    for (final appName in _dataStore.allAppNames) {
      final metadata = _dataStore.getAppMetadata(appName);

      if (metadata != null) {
        result.add(ExportableAppMetadata(
          appName: appName,
          category: metadata.category,
          isProductive: metadata.isProductive,
          isTracking: metadata.isTracking,
          isVisible: metadata.isVisible,
          dailyLimitMicroseconds: metadata.dailyLimit.inMicroseconds,
          limitStatus: metadata.limitStatus,
        ));
      }
    }

    return result;
  }

  /// Import metadata records
  Future<Map<String, int>> _importMetadata(
    List<ExportableAppMetadata> data,
    ImportMode mode,
  ) async {
    int imported = 0;
    int skipped = 0;
    int updated = 0;

    for (final item in data) {
      final existing = _dataStore.getAppMetadata(item.appName);

      if (existing != null) {
        switch (mode) {
          case ImportMode.replace:
          case ImportMode.merge:
            await _dataStore.updateAppMetadata(
              item.appName,
              category: item.category,
              isProductive: item.isProductive,
              isTracking: item.isTracking,
              isVisible: item.isVisible,
              dailyLimit: Duration(microseconds: item.dailyLimitMicroseconds),
              limitStatus: item.limitStatus,
            );
            updated++;
            break;
          case ImportMode.append:
            skipped++;
            break;
        }
      } else {
        await _dataStore.updateAppMetadata(
          item.appName,
          category: item.category,
          isProductive: item.isProductive,
          isTracking: item.isTracking,
          isVisible: item.isVisible,
          dailyLimit: Duration(microseconds: item.dailyLimitMicroseconds),
          limitStatus: item.limitStatus,
        );
        imported++;
      }
    }

    return {'imported': imported, 'skipped': skipped, 'updated': updated};
  }

  /// Import usage records
  Future<Map<String, int>> _importUsageData(
    List<ExportableAppUsage> data,
    ImportMode mode,
  ) async {
    int imported = 0;
    int skipped = 0;
    int updated = 0;

    for (final item in data) {
      final date = DateTime.parse(item.date);
      final existing = _dataStore.getAppUsage(item.appName, date);

      final usagePeriods = item.usagePeriods
          .map((p) => TimeRange(
                startTime: DateTime.parse(p.startTime),
                endTime: DateTime.parse(p.endTime),
              ))
          .toList();

      if (existing != null) {
        switch (mode) {
          case ImportMode.replace:
            // Replace with imported data
            await _dataStore.recordAppUsage(
              item.appName,
              date,
              Duration(microseconds: item.timeSpentMicroseconds) -
                  existing.timeSpent,
              item.openCount - existing.openCount,
              usagePeriods,
            );
            updated++;
            break;
          case ImportMode.merge:
            // Merge - add only new time ranges
            final newPeriods =
                _filterNewPeriods(usagePeriods, existing.usagePeriods);
            if (newPeriods.isNotEmpty) {
              await _dataStore.recordAppUsage(
                item.appName,
                date,
                Duration.zero, // Will be recalculated
                0,
                newPeriods,
              );
              updated++;
            } else {
              skipped++;
            }
            break;
          case ImportMode.append:
            skipped++;
            break;
        }
      } else {
        await _dataStore.recordAppUsage(
          item.appName,
          date,
          Duration(microseconds: item.timeSpentMicroseconds),
          item.openCount,
          usagePeriods,
        );
        imported++;
      }
    }

    return {'imported': imported, 'skipped': skipped, 'updated': updated};
  }

  /// Import focus sessions (UPDATED for new API)
  Future<Map<String, int>> _importFocusSessions(
    List<ExportableFocusSession> data,
    ImportMode mode,
  ) async {
    int imported = 0;
    int skipped = 0;
    int updated = 0;

    for (final item in data) {
      final date = DateTime.parse(item.date);
      final startTime = DateTime.parse(item.startTime);
      final existingSessions = _dataStore.getFocusSessions(date);

      // Check if this session already exists and get its index
      int? existingIndex;
      for (int i = 0; i < existingSessions.length; i++) {
        if (existingSessions[i].startTime.millisecondsSinceEpoch ==
            startTime.millisecondsSinceEpoch) {
          existingIndex = i;
          break;
        }
      }

      final sessionRecord = FocusSessionRecord(
        date: date,
        startTime: startTime,
        duration: Duration(microseconds: item.durationMicroseconds),
        appsBlocked: item.appsBlocked,
        completed: item.completed,
        breakCount: item.breakCount,
        totalBreakTime: Duration(microseconds: item.totalBreakTimeMicroseconds),
      );

      if (existingIndex != null) {
        // Session exists
        switch (mode) {
          case ImportMode.replace:
            // Delete existing and add new
            await _dataStore.deleteFocusSession(date, existingIndex);
            await _dataStore.recordFocusSession(sessionRecord);
            updated++;
            break;
          case ImportMode.merge:
          case ImportMode.append:
            skipped++;
            break;
        }
      } else {
        // New session
        await _dataStore.recordFocusSession(sessionRecord);
        imported++;
      }
    }

    return {'imported': imported, 'skipped': skipped, 'updated': updated};
  }

  /// Filter out time periods that already exist
  List<TimeRange> _filterNewPeriods(
    List<TimeRange> imported,
    List<TimeRange> existing,
  ) {
    return imported.where((importedPeriod) {
      return !existing.any((existingPeriod) =>
          importedPeriod.startTime.isAtSameMomentAs(existingPeriod.startTime) ||
          (importedPeriod.startTime.isAfter(existingPeriod.startTime) &&
              importedPeriod.startTime.isBefore(existingPeriod.endTime)));
    }).toList();
  }

  /// Compress data using GZip
  Uint8List _compressData(List<int> data) {
    final encoder = GZipEncoder();
    final compressed = encoder.encode(data);
    return Uint8List.fromList(compressed!);
  }

  /// Decompress GZip data
  String _decompressData(Uint8List data) {
    final decoder = GZipDecoder();
    final decompressed = decoder.decodeBytes(data);
    return utf8.decode(decompressed);
  }

  /// Save data to a file (with save dialog on macOS)
  Future<String> _saveToFile(Uint8List data, String fileName) async {
    if (PlatformUtils.isMacOS) {
      // On macOS, let user choose location via save dialog
      try {
        final String? outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Backup',
          fileName: fileName,
          allowedExtensions: ['stbackup'],
          type: FileType.custom,
        );

        if (outputPath == null) {
          throw Exception('Save cancelled by user');
        }

        final file = File(outputPath);
        await file.writeAsBytes(data);

        debugPrint('✅ Backup saved to: ${file.path}');
        return file.path;
      } catch (e) {
        debugPrint('Save dialog error: $e');
        // Fallback to default location
        return await _saveToDefaultLocation(data, fileName);
      }
    } else {
      // Windows/Linux: use default location
      return await _saveToDefaultLocation(data, fileName);
    }
  }

  /// Fallback: save to default location
  Future<String> _saveToDefaultLocation(Uint8List data, String fileName) async {
    Directory? directory;

    try {
      directory = await getDownloadsDirectory();
    } catch (e) {
      debugPrint('Could not access Downloads: $e');
    }
    directory ??= await getApplicationDocumentsDirectory();

    final exportDir = Directory('${directory.path}/TimeMark-Backups');

    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final file = File('${exportDir.path}/$fileName');
    await file.writeAsBytes(data);

    debugPrint('✅ Backup saved to: ${file.path}');
    return file.path;
  }

  /// Pick a file for import
  Future<String?> _pickImportFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['stbackup', 'json'],
      allowMultiple: false,
    );

    return result?.files.single.path;
  }

  /// Get device identifier
  Future<String> _getDeviceId() async {
    // You can use device_info_plus package for real device ID
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Get app version
  Future<String> _getAppVersion() async {
    // You can use package_info_plus for real version
    return '1.0.0';
  }

  /// Check version compatibility
  bool _isVersionCompatible(String version) {
    // Add version compatibility logic
    final supportedVersions = ['1.0'];
    return supportedVersions.contains(version);
  }

  /// Format date for file names
  String _formatDateTime(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}_'
        '${date.hour.toString().padLeft(2, '0')}${date.minute.toString().padLeft(2, '0')}';
  }

  /// Format date key (same as in AppDataStore)
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Result of export operation
class ExportResult {
  final bool success;
  final String? error;
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final int? recordCount;

  ExportResult({
    required this.success,
    this.error,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.recordCount,
  });

  factory ExportResult.failure(String error) {
    return ExportResult(success: false, error: error);
  }

  factory ExportResult.success({
    required String filePath,
    required String fileName,
    required int fileSize,
    required int recordCount,
  }) {
    return ExportResult(
      success: true,
      filePath: filePath,
      fileName: fileName,
      fileSize: fileSize,
      recordCount: recordCount,
    );
  }
}
