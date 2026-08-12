import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants_precios.dart';

class PriceRequestHandler {
  Future<double?> cheapestPcPrice(String gameTitle) async {
    if (gameTitle.trim().isEmpty) {
      return null;
    }

    try {
      final Uri uri = Uri.https(hostApiPrecios, endpointBuscarJuegos, {
        'title': gameTitle,
        'limit': '1',
      });

      final http.Response response = await http.get(uri);

      if (response.statusCode != 200) {
        return null;
      }

      final dynamic body = json.decode(response.body);

      if (body is! List || body.isEmpty) {
        return null;
      }

      final dynamic first = body.first;

      if (first is! Map) {
        return null;
      }

      final dynamic cheapest = first['cheapest'];

      if (cheapest == null) {
        return null;
      }

      return double.tryParse(cheapest.toString());
    } catch (_) {
      return null;
    }
  }
}
