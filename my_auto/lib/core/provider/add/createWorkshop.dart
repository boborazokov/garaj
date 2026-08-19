import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:my_auto/core/services/graphql/index.dart';
import 'package:my_auto/features/add/api/index.dart';
import 'package:my_auto/features/add/controllers/Services/index.dart';

class CreateWorkshopProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final controller = ServicesController();
  bool isLoading = false;
  double uploadProgress = 0.0;

  StreamSubscription<List<int>>? _uploadSubscription;

  /// ----------------------------
  /// CREATE
  /// ----------------------------
  Future<String?> createWorkshop({
    required String name,
    required String location,
    required String timeRange, // "08:00-23:00"
    List<File> images = const [],
  }) async {
    _setLoading(true);

    try {
      final timeData = _parseTimeRange(timeRange);

      final data = {
        "name": name,
        "location": location,
        "openFrom": timeData["openFrom"],
        "openUntil": timeData["openUntil"],
      };

      final result = await GraphQLConfig.client().mutate(
        MutationOptions(
          document: gql(CREATE_WORKSHOP),
          variables: {"data": data, "images": []},
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      final id = result.data?['createWorkshop']?['_id'];

      return id;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateWorkshop({
    required String workshopId,
    String? name,
    String? location,
    String? timeRange,
    List<File> images = const [],
  }) async {
    _setLoading(true);

    try {
      final data = <String, dynamic>{};

      if (name != null) data["name"] = name;
      if (location != null) data["location"] = location;

      if (timeRange != null) {
        final timeData = _parseTimeRange(timeRange);
        data["openFrom"] = timeData["openFrom"];
        data["openUntil"] = timeData["openUntil"];
      }

      List<String> uploadedUrls = [];

      final result = await GraphQLConfig.client().mutate(
        MutationOptions(
          document: gql(UPDATE_WORKSHOP),
          variables: {
            "workshopId": workshopId,
            "data": data,
            "images": uploadedUrls,
          },
        ),
      );

      return result.data?['updateWorkshopById'] != null;
    } finally {
      _setLoading(false);
    }
  }

  /// ----------------------------
  /// GET
  /// ----------------------------
  Future<Map<String, dynamic>?> getWorkshopById(String id) async {
    _setLoading(true);

    try {
      final result = await GraphQLConfig.client().query(
        QueryOptions(
          document: gql(GET_WORKSHOP_BY_ID),
          variables: {"id": id},
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      if (result.hasException) {
        debugPrint("GraphQL error: ${result.exception.toString()}");
        return null;
      }

      return result.data?['getWorkshopById'] as Map<String, dynamic>?;
    } finally {
      _setLoading(false);
    }
  }

  /// ----------------------------
  /// HELPERS
  /// ----------------------------
  Map<String, String?> _parseTimeRange(String range) {
    if (!range.contains('-')) return {"openFrom": null, "openUntil": null};

    final parts = range.split('-');
    final now = DateTime.now();

    DateTime parseTime(String str) {
      final p = str.trim().split(':');
      return DateTime(
          now.year, now.month, now.day, int.parse(p[0]), int.parse(p[1]));
    }

    final openFrom = parseTime(parts[0]);
    final openUntil = parseTime(parts[1]);

    return {
      "openFrom": openFrom.toIso8601String(),
      "openUntil": openUntil.toIso8601String(),
    };
  }

  Future<void> cancelUpload() async {
    await _uploadSubscription?.cancel();
    _uploadSubscription = null;
    uploadProgress = 0.0;
    isLoading = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    if (!value) uploadProgress = 0.0;
    notifyListeners();
  }
}
