// lib/core/services/upload_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/services/upload/image_multipart.dart';

class UploadService {
  final _storage = const FlutterSecureStorage();

  Future<List<String>> uploadFiles({
    required List<File> files,
    required String targetId,
    required String targetType,
    required Function(double) onProgress,
  }) async {
    final uri = Uri.parse("$apiUrl/upload/multiple");
    final request = http.MultipartRequest("POST", uri);

    for (final file in files) {
      request.files.add(await multipartImageFromFile(file));
    }
    request.fields["target[${targetType}Id]"] = targetId;

    final token = await _storage.read(key: "authToken");
    if (token != null) {
      request.headers["Authorization"] = "Bearer $token";
    }

    final totalBytes = await _calculateTotalBytes(files);
    int sentBytes = 0;

    final streamedResponse = await request.send();
    final bytesBuilder = BytesBuilder();

    streamedResponse.stream.listen(
      (chunk) {
        sentBytes += chunk.length;
        onProgress((sentBytes / totalBytes).clamp(0.0, 1.0));
        bytesBuilder.add(chunk);
      },
    );

    final resBody = utf8.decode(await streamedResponse.stream.toBytes());

    if (streamedResponse.statusCode != 201) {
      throw Exception(
          "Upload failed: ${streamedResponse.statusCode}, body: $resBody");
    }

    final data = jsonDecode(resBody);
    if (data is Map<String, dynamic> && data.containsKey("files")) {
      return (data["files"] as List).map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<int> _calculateTotalBytes(List<File> files) async {
    int total = 0;
    for (final file in files) {
      total += await file.length();
    }
    return total;
  }
}
