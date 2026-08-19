import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:my_auto/core/map/geo_location.dart';

class GeocodeService {
  static Future<String?> getAddressFromGeo(GeoLocation point) async {
    final baseUrl = dotenv.env['API_GEOCODE_URL']!;
    final url = Uri.parse(
      '$baseUrl?lat=${point.latitude}&lon=${point.longitude}&format=json',
    );

    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'my_auto_app/1.0 boborazokovfozil01@gmail.com',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['display_name'] as String?;
    }
    return null;
  }
}
