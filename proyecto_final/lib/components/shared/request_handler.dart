import 'dart:convert';

import 'package:http/http.dart' as http;

import '../games/models/modelo.dart';
import '../utils/constants.dart';

class RequestHandler {
  Future<RequestGamesModel> requestGetGames({
    int page = 1,
    int pageSize = 20,
    String search = '',
    int? parentPlatformId,
    String genre = '',
    String tag = '',
    String ordering = '-added',
  }) async {
    final Map<String, String> queryParameters = {
      'key': apiKey,
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'ordering': ordering,
    };

    if (search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
      queryParameters['search_precise'] = 'true';
    }

    if (parentPlatformId != null) {
      queryParameters['parent_platforms'] =
          parentPlatformId.toString();
    }

    if (genre.trim().isNotEmpty) {
      queryParameters['genres'] = genre.trim();
    }

    if (tag.trim().isNotEmpty) {
      queryParameters['tags'] = tag.trim();
    }

    final Uri url = Uri.https(
      hostApi,
      endpointGames,
      queryParameters,
    );

    try {
      final http.Response response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 20),
          );

      if (response.statusCode == 200) {
        final dynamic decodedResponse =
            jsonDecode(response.body);

        if (decodedResponse is! Map<String, dynamic>) {
          throw Exception(
            'RAWG devolvio una respuesta incorrecta.',
          );
        }

        return RequestGamesModel.fromJson(
          decodedResponse,
        );
      }

      if (response.statusCode == 401) {
        throw Exception(
          'La API Key de RAWG no es valida.',
        );
      }

      if (response.statusCode == 403) {
        throw Exception(
          'RAWG rechazo la solicitud.',
        );
      }

      throw Exception(
        'Error ${response.statusCode} al consultar RAWG.',
      );
    } on FormatException {
      throw Exception(
        'RAWG devolvio datos con formato incorrecto.',
      );
    } on http.ClientException {
      throw Exception(
        'No se pudo conectar con RAWG.',
      );
    } catch (error) {
      throw Exception(
        error
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }

  Future<Map<String, dynamic>> requestGetGameDetail(
    int gameId,
  ) async {
    final Uri url = Uri.https(
      hostApi,
      '$endpointGames/$gameId',
      {
        'key': apiKey,
      },
    );

    try {
      final http.Response response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 20),
          );

      if (response.statusCode == 200) {
        final dynamic decodedResponse =
            jsonDecode(response.body);

        if (decodedResponse is Map<String, dynamic>) {
          return decodedResponse;
        }

        throw Exception(
          'Respuesta incorrecta de RAWG.',
        );
      }

      if (response.statusCode == 401) {
        throw Exception(
          'API Key no valida.',
        );
      }

      if (response.statusCode == 404) {
        throw Exception(
          'Juego no encontrado.',
        );
      }

      throw Exception(
        'Error ${response.statusCode} al cargar el detalle.',
      );
    } on FormatException {
      throw Exception(
        'RAWG devolvio datos incorrectos.',
      );
    } on http.ClientException {
      throw Exception(
        'No se pudo conectar con RAWG.',
      );
    } catch (error) {
      throw Exception(
        error
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            ),
      );
    }
  }
}