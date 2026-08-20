import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<bool> saveTextFile(
    String content, String fileName, String dialogTitle) async {
  final outputPath = await FilePicker.saveFile(
    dialogTitle: dialogTitle,
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: ['txt'],
  );
  if (outputPath == null) return false;
  File(outputPath)
    ..createSync(recursive: true)
    ..writeAsStringSync(content);
  return true;
}
