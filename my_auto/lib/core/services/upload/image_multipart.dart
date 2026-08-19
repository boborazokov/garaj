import 'package:cross_file/cross_file.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

String _fileExtension(String filePath) {
  final dot = filePath.lastIndexOf('.');
  if (dot < 0 || dot >= filePath.length - 1) return '';
  return filePath.substring(dot).toLowerCase();
}

String _basename(String filePath) {
  final sep = filePath.contains('\\') ? '\\' : '/';
  final i = filePath.lastIndexOf(sep);
  return i < 0 ? filePath : filePath.substring(i + 1);
}

MediaType mediaTypeForImageFile(String filePath) {
  switch (_fileExtension(filePath)) {
    case '.jpg':
    case '.jpeg':
      return MediaType('image', 'jpeg');
    case '.png':
      return MediaType('image', 'png');
    case '.webp':
      return MediaType('image', 'webp');
    case '.gif':
      return MediaType('image', 'gif');
    case '.heic':
      return MediaType('image', 'heic');
    case '.heif':
      return MediaType('image', 'heif');
    default:
      return MediaType('image', 'jpeg');
  }
}

/// Multipart part from [XFile] bytes — works on mobile and web (blob URLs).
Future<http.MultipartFile> multipartImageFromXFile(
  XFile file, {
  String fieldName = 'files',
}) async {
  final path = file.path;
  var filename = file.name.trim();
  if (filename.isEmpty) {
    filename = _basename(path);
  }
  if (filename.isEmpty || !filename.contains('.')) {
    filename = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  final contentType = mediaTypeForImageFile(filename);
  final bytes = await file.readAsBytes();

  return http.MultipartFile.fromBytes(
    fieldName,
    bytes,
    filename: filename,
    contentType: contentType,
  );
}

/// Back-compat for call sites that still pass `dart:io` [File] on native.
Future<http.MultipartFile> multipartImageFromFile(
  dynamic file, {
  String fieldName = 'files',
}) {
  if (file is XFile) {
    return multipartImageFromXFile(file, fieldName: fieldName);
  }
  final path = file.path as String;
  return multipartImageFromXFile(XFile(path), fieldName: fieldName);
}
