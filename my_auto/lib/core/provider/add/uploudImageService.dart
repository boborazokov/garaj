import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/services/upload/image_multipart.dart';
import 'package:my_auto/features/add/api/index.dart';

class UploadService {
  final _storage = const FlutterSecureStorage();
  StreamSubscription<List<int>>? _uploadSubscription;

  Future<List<String>> uploadFilesWithProgress({
    required List<File> files,
    required String targetId,
    required String targetType,
    required void Function(double progress) onProgress,
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

    _uploadSubscription = streamedResponse.stream.listen(
      (chunk) {
        sentBytes += chunk.length;
        double progress = (sentBytes / totalBytes).clamp(0.0, 1.0);
        onProgress(progress);
        bytesBuilder.add(chunk);
      },
      onError: (e) => throw e,
      cancelOnError: true,
    );

    await _uploadSubscription!.asFuture();
    _uploadSubscription = null;

    final resBody = utf8.decode(bytesBuilder.takeBytes());

    if (streamedResponse.statusCode != 200 &&
        streamedResponse.statusCode != 201) {
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

  Future<void> cancelUpload() async {
    await _uploadSubscription?.cancel();
    _uploadSubscription = null;
  }
}
