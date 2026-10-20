import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/services/upload/image_multipart.dart';
import 'package:my_auto/core/utils/resolve_media_url.dart';

class UploadService {
  final _storage = const FlutterSecureStorage();
  StreamSubscription<List<int>>? _uploadSubscription;

  static const _timeout = Duration(minutes: 3);

  Map<String, String> _headers(String? token) {
    return <String, String>{
      ...mediaRequestHeaders(apiUrl),
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Never _rethrowFriendly(Object e) {
    final msg = e.toString();
    if (e is TimeoutException || msg.contains('TimeoutException')) {
      throw Exception(
        'Photo upload timed out. Check your connection and try again.',
      );
    }
    if (e is SocketException ||
        e is http.ClientException ||
        msg.contains('ClientException') ||
        msg.contains('connection abort') ||
        msg.contains('Connection closed') ||
        msg.contains('Connection reset')) {
      throw Exception(
        'Photo upload failed: connection interrupted. Try again with a stable network.',
      );
    }
    throw e is Exception ? e : Exception(msg);
  }

  Future<List<String>> uploadFilesWithProgress({
    required List<File> files,
    required String targetId,
    required String targetType,
    required void Function(double progress) onProgress,
  }) async {
    final uri = Uri.parse('$apiUrl/upload/multiple');
    final request = http.MultipartRequest('POST', uri);

    for (final file in files) {
      request.files.add(await multipartImageFromFile(file));
    }

    request.fields['target[${targetType}Id]'] = targetId;

    final token = await _storage.read(key: 'authToken');
    request.headers.addAll(_headers(token));

    final totalBytes = await _calculateTotalBytes(files);
    var sentBytes = 0;

    late final http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await request.send().timeout(_timeout);
    } catch (e) {
      _rethrowFriendly(e);
    }

    final bytesBuilder = BytesBuilder();

    _uploadSubscription = streamedResponse.stream.listen(
      (chunk) {
        sentBytes += chunk.length;
        final progress =
            totalBytes > 0 ? (sentBytes / totalBytes).clamp(0.0, 1.0) : 1.0;
        onProgress(progress);
        bytesBuilder.add(chunk);
      },
      onError: (Object e) {
        throw e;
      },
      cancelOnError: true,
    );

    try {
      await _uploadSubscription!.asFuture().timeout(_timeout);
    } catch (e) {
      await cancelUpload();
      _rethrowFriendly(e);
    }
    _uploadSubscription = null;

    final resBody = utf8.decode(bytesBuilder.takeBytes());

    if (streamedResponse.statusCode == 401 ||
        streamedResponse.statusCode == 403) {
      throw Exception(
        'Photo upload failed: session expired. Please sign in again.',
      );
    }

    if (streamedResponse.statusCode != 200 &&
        streamedResponse.statusCode != 201) {
      throw Exception(
        'Upload failed: ${streamedResponse.statusCode}, body: $resBody',
      );
    }

    final data = jsonDecode(resBody);

    if (data is Map<String, dynamic> && data.containsKey('files')) {
      return (data['files'] as List).map((e) => e.toString()).toList();
    }

    return [];
  }

  Future<int> _calculateTotalBytes(List<File> files) async {
    var total = 0;
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
