import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants_precios.dart';

/// Maneja las peticiones a la API de precios de CheapShark.
/// Es publica y gratuita (sin API key), pero solo cubre tiendas de PC.
class PriceRequestHandler {
  /// Busca un juego por titulo en CheapShark y devuelve su precio actual
  /// mas bajo entre tiendas de PC (Steam, GOG, Epic, etc.).
  /// Retorna null si no se encuentra o si ocurre un error de red.
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
      // Sin internet, timeout, o respuesta inesperada: se usa el
      // precio de mercado simulado como respaldo.
      return null;
    }
  }
}
