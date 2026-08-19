import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:my_auto/core/services/graphql/graphql_links.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/services/upload/image_multipart.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

/// Upload helper for chat-related media (photos, voice).
///
/// Talks directly to the REST `/upload/chat-image` and `/upload/chat-voice`
/// endpoints because GraphQL multipart adds avoidable complexity for
/// what is just a binary blob. Returns the public URL the message
/// resolver expects in `images[]` / `voiceUrl`.
class ChatUploadDataSource {
  ChatUploadDataSource();

  Future<String> uploadImage(File file) async {
    return _post(
      file: file,
      endpoint: 'upload/chat-image',
      multipart: (f) => multipartImageFromFile(f, fieldName: 'file'),
    );
  }

  Future<String> uploadVoice(File file) async {
    return _post(
      file: file,
      endpoint: 'upload/chat-voice',
      multipart: (f) async {
        final mime = lookupMimeType(f.path) ?? 'audio/mp4';
        final type = mime.contains('/')
            ? MediaType(mime.split('/').first, mime.split('/').last)
            : MediaType('audio', 'mp4');
        final filename = f.path.split(RegExp(r'[\\/]')).last;
        return http.MultipartFile.fromBytes(
          'file',
          await f.readAsBytes(),
          filename: filename,
          contentType: type,
        );
      },
    );
  }

  Future<String> _post({
    required File file,
    required String endpoint,
    required Future<http.MultipartFile> Function(File) multipart,
  }) async {
    final token = await GraphQLLinks.readBearer();
    final uri = Uri.parse('$apiUrl/$endpoint');
    final request = http.MultipartRequest('POST', uri);
    if (token != null) request.headers['Authorization'] = token;
    request.files.add(await multipart(file));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Chat upload failed (${response.statusCode}): $body',
      );
    }
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final url = decoded['url']?.toString();
      if (url == null || url.isEmpty) {
        throw Exception('Empty URL returned for chat upload');
      }
      return url;
    } catch (e) {
      throw Exception('Invalid upload response body: $body');
    }
  }
}
