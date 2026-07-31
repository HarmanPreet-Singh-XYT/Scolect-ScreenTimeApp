import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<bool> saveXlsxFile(
    List<int> bytes, String fileName, String dialogTitle) async {
  final outputPath = await FilePicker.platform.saveFile(
    dialogTitle: dialogTitle,
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: ['xlsx'],
  );
  if (outputPath == null) return false;
  File(outputPath)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes);
  return true;
}
