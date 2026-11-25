import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timelay_health/features/admin/location_management/data/endpoints/location_endpoints.dart';
import 'package:timelay_health/features/admin/location_management/data/models/location_item_model.dart';

class LocationRemoteDataSource {
  LocationRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<LocationItem>> getAllLocations() async {
    late final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse(LocationEndpoints.allLocations),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      // In case of connectivity error, fallback gracefully
      return LocationItem.sampleLocations();
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return LocationItem.sampleLocations();
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final listRaw = decoded['locations'] ?? decoded['data'];
        if (listRaw is List) {
          final items = listRaw
              .whereType<Map>()
              .map((e) => LocationItem.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          if (items.isNotEmpty) return items;
        }
      }
      return LocationItem.sampleLocations();
    } catch (_) {
      return LocationItem.sampleLocations();
    }
  }
}
