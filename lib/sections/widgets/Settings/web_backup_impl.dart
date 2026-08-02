// ─── Web backup implementation (web platform only) ───────────────────────────
// Imported via conditional import from web_backup.dart.

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '../../../web/chrome_storage_interop.dart';

Future<void> downloadStorageAsJson() async {
  final all = await chromeStorageGetAll();
  final json = const JsonEncoder.withIndent('  ').convert({
    'version': 1,
    'exportedAt': DateTime.now().toIso8601String(),
    'data': all,
  });

  final bytes = Uint8List.fromList(utf8.encode(json));
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/json'),
  );
  final url = web.URL.createObjectURL(blob);
  final now = DateTime.now();
  final stamp =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = 'scolect-backup-$stamp.json';
  web.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}

/// Returns the number of scolect_* keys restored.
Future<int> restoreStorageFromJson(String jsonText) async {
  final decoded = jsonDecode(jsonText) as Map<String, dynamic>;

  final Map<String, dynamic> storageData;
  if (decoded.containsKey('data') && decoded['data'] is Map) {
    storageData = decoded['data'] as Map<String, dynamic>;
  } else {
    storageData = decoded;
  }

  final scolectEntries = storageData.entries
      .where((e) => e.key.startsWith('scolect_'))
      .toList();

  for (final entry in scolectEntries) {
    await chromeStorageSet({entry.key: entry.value});
  }
  return scolectEntries.length;
}

Future<String?> pickAndReadJsonFile() async {
  final input = web.document.createElement('input') as web.HTMLInputElement
    ..type = 'file'
    ..accept = '.json,application/json';
  web.document.body!.append(input);

  final fileCompleter = Completer<web.FileList?>();
  late final JSFunction changeListener;
  changeListener = (web.Event e) {
    if (!fileCompleter.isCompleted) {
      final target = e.target as web.HTMLInputElement?;
      fileCompleter.complete(target?.files);
    }
  }.toJS;
  input.addEventListener('change', changeListener);
  input.click();

  final files = await fileCompleter.future;
  input.remove();

  if (files == null || files.length == 0) return null;
  final file = files.item(0)!;

  final reader = web.FileReader();
  final textCompleter = Completer<String>();

  reader.addEventListener('load', (web.Event _) {
    if (!textCompleter.isCompleted) {
      textCompleter.complete(reader.result as String);
    }
  }.toJS);
  reader.addEventListener('error', (web.Event _) {
    if (!textCompleter.isCompleted) {
      textCompleter.completeError('FileReader error');
    }
  }.toJS);

  reader.readAsText(file);
  return textCompleter.future;
}
