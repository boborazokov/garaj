import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_auto/core/services/graphql/graphql_links.dart';
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/core/services/upload/image_multipart.dart';

/// GraphQL multipart request (graphql-multipart-request-spec) for `Upload` scalars.
class GraphQLMultipart {
  static Future<Map<String, dynamic>?> mutate({
    required String operationName,
    required String query,
    required Map<String, dynamic> variables,
    Map<String, XFile> files = const {},
  }) async {
    final uri = Uri.parse('${apiUrl}/api');
    final request = http.MultipartRequest('POST', uri);

    final token = await GraphQLLinks.readBearer();
    if (token != null) {
      request.headers['Authorization'] = token;
    }
    // Apollo CSRF prevention for multipart GraphQL uploads.
    request.headers['apollo-require-preflight'] = 'true';
    request.headers['x-apollo-operation-name'] = operationName;

    final opsVariables = Map<String, dynamic>.from(variables);
    final map = <String, List<String>>{};
    var fileIndex = 0;

    for (final entry in files.entries) {
      opsVariables[entry.key] = null;
      map['$fileIndex'] = ['variables.${entry.key}'];
      final bytes = await entry.value.length();
      if (kDebugMode) {
        debugPrint(
          '[ProfileUpload] attach ${entry.key}: '
          '${entry.value.name.isNotEmpty ? entry.value.name : entry.value.path} '
          '(${(bytes / 1024).toStringAsFixed(1)} KB)',
        );
      }
      request.files.add(
        await multipartImageFromXFile(
          entry.value,
          fieldName: '$fileIndex',
        ),
      );
      fileIndex++;
    }

    request.fields['operations'] = jsonEncode({
      'query': query,
      'operationName': operationName,
      'variables': opsVariables,
    });
    request.fields['map'] = jsonEncode(map);

    if (kDebugMode) {
      debugPrint('[ProfileUpload] POST $uri operation=$operationName');
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (kDebugMode) {
      debugPrint(
        '[ProfileUpload] response ${response.statusCode} '
        '(${body.length} chars)',
      );
    }

    if (response.statusCode != 200) {
      if (kDebugMode) debugPrint('[ProfileUpload] error body: $body');
      throw Exception('GraphQL upload failed: ${response.statusCode} $body');
    }

    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final errors = decoded['errors'];
    if (errors is List && errors.isNotEmpty) {
      if (kDebugMode) debugPrint('[ProfileUpload] graphql errors: $errors');
      throw Exception(errors.first.toString());
    }

    if (kDebugMode) {
      final image = (decoded['data'] as Map?)?['updateProfile']?['image'];
      debugPrint('[ProfileUpload] success image=$image');
    }

    return decoded['data'] as Map<String, dynamic>?;
  }
}
