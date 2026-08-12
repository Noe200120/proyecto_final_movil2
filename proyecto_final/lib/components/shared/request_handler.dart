import 'dart:convert';

import 'package:http/http.dart' as http;

import '../games/models/modelo.dart';
import '../utils/constants.dart';

class RequestHandler {
  final Map<int, String> _genresCache = {};

  bool _genresLoaded = false;

  Future<RequestGamesModel> requestGetGames({
    int page = 1,
    int pageSize = 20,
    String search = '',
    int? parentPlatformId,
    String genre = '',
    String tag = '',
    String ordering = '-added',
  }) async {
    try {
      await _loadGenres();

      final Map<String, dynamic> decodedResponse;

      if (search.trim().isNotEmpty) {
        decodedResponse = await _searchGamesByName(
          search: search.trim(),
          page: page,
          parentPlatformId: parentPlatformId,
        );
      } else {
        decodedResponse = await _loadGamesByPlatform(
          page: page,
          parentPlatformId: parentPlatformId,
        );
      }

      final Map<String, dynamic> adaptedResponse = _adaptGamesResponse(
        decodedResponse,
        pageSize: pageSize,
      );

      return RequestGamesModel.fromJson(adaptedResponse);
    } catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _loadGenres() async {
    if (_genresLoaded && _genresCache.isNotEmpty) {
      return;
    }

    try {
      final Uri url = Uri.https(hostApi, endpointGenres, {'apikey': apiKey});

      final Map<String, dynamic> response = await _executeRequest(url);

      final dynamic data = response['data'];

      if (data is! Map) {
        return;
      }

      final dynamic genres = data['genres'];

      _genresCache.clear();
      if (genres is Map) {
        genres.forEach((dynamic key, dynamic value) {
          if (value is Map) {
            final Map<String, dynamic> genre = Map<String, dynamic>.from(value);

            final int id = _intValue(genre['id']);

            final String name = _stringValue(genre['name']);

            if (id > 0 && name.isNotEmpty) {
              _genresCache[id] = name;
            }
          }
        });
      } else if (genres is List) {
        for (final dynamic item in genres) {
          if (item is! Map) {
            continue;
          }

          final Map<String, dynamic> genre = Map<String, dynamic>.from(item);

          final int id = _intValue(genre['id']);

          final String name = _stringValue(genre['name']);

          if (id > 0 && name.isNotEmpty) {
            _genresCache[id] = name;
          }
        }
      }

      if (_genresCache.isNotEmpty) {
        _genresLoaded = true;
      }
    } catch (_) {
      _genresLoaded = false;
    }
  }

  Future<Map<String, dynamic>> _searchGamesByName({
    required String search,
    required int page,
    int? parentPlatformId,
  }) async {
    final Map<String, String> queryParameters = {
      'apikey': apiKey,
      'name': search,
      'page': page.toString(),
      'fields':
          'players,publishers,developers,genres,overview,last_updated,rating,platform,coop,youtube',
      'include': 'boxart,platform',
    };

    final String? platformId = _getTheGamesDbPlatformId(parentPlatformId);

    if (platformId != null) {
      queryParameters['filter[platform]'] = platformId;
    }

    final Uri url = Uri.https(hostApi, endpointGamesByName, queryParameters);

    return _executeRequest(url);
  }

  Future<Map<String, dynamic>> _loadGamesByPlatform({
    required int page,
    int? parentPlatformId,
  }) async {
    final String platformId =
        _getTheGamesDbPlatformId(parentPlatformId) ?? _defaultPlatform;

    final Map<String, String> queryParameters = {
      'apikey': apiKey,
      'id': platformId,
      'page': page.toString(),
      'fields':
          'players,publishers,developers,genres,overview,last_updated,rating,platform,coop,youtube',
      'include': 'boxart,platform',
    };

    final Uri url = Uri.https(
      hostApi,
      endpointGamesByPlatform,
      queryParameters,
    );

    return _executeRequest(url);
  }

  Future<Map<String, dynamic>> requestGetGameDetail(int gameId) async {
    try {
      await _loadGenres();

      final Uri url = Uri.https(hostApi, endpointGamesById, {
        'apikey': apiKey,
        'id': gameId.toString(),
        'fields':
            'players,publishers,developers,genres,overview,last_updated,rating,platform,coop,youtube',
        'include': 'boxart,platform',
      });

      final Map<String, dynamic> response = await _executeRequest(url);

      final List<dynamic> games = _extractGames(response);

      if (games.isEmpty) {
        throw Exception('Juego no encontrado.');
      }

      final Map<String, dynamic> game = Map<String, dynamic>.from(
        games.first as Map,
      );

      return _adaptSingleGame(game, response);
    } catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> _executeRequest(Uri url) async {
    try {
      final http.Response response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is! Map<String, dynamic>) {
          throw Exception('TheGamesDB devolvio una respuesta incorrecta.');
        }

        final int apiCode = _intValue(decoded['code']);

        if (apiCode != 0 && apiCode != 200) {
          throw Exception(
            _stringValue(decoded['status']).isNotEmpty
                ? _stringValue(decoded['status'])
                : 'TheGamesDB devolvio un error.',
          );
        }

        return decoded;
      }

      if (response.statusCode == 403) {
        throw Exception('API Key invalida o limite mensual alcanzado.');
      }

      if (response.statusCode == 406) {
        throw Exception('TheGamesDB recibio parametros incorrectos.');
      }

      if (response.statusCode == 404) {
        throw Exception('Recurso no encontrado.');
      }

      throw Exception('Error ${response.statusCode} al consultar TheGamesDB.');
    } on FormatException {
      throw Exception('TheGamesDB devolvio datos con formato incorrecto.');
    } on http.ClientException {
      throw Exception('No se pudo conectar con TheGamesDB.');
    }
  }

  Map<String, dynamic> _adaptGamesResponse(
    Map<String, dynamic> response, {
    required int pageSize,
  }) {
    final List<dynamic> games = _extractGames(response);

    final List<Map<String, dynamic>> adaptedGames = games
        .take(pageSize)
        .map(
          (dynamic game) => _adaptSingleGame(
            Map<String, dynamic>.from(game as Map),
            response,
          ),
        )
        .toList();

    return {
      'count': adaptedGames.length,
      'next': null,
      'previous': null,
      'results': adaptedGames,
    };
  }

  List<dynamic> _extractGames(Map<String, dynamic> response) {
    final dynamic data = response['data'];

    if (data is! Map) {
      return [];
    }

    final dynamic games = data['games'];

    if (games is List) {
      return games;
    }

    return [];
  }

  Map<String, dynamic> _adaptSingleGame(
    Map<String, dynamic> game,
    Map<String, dynamic> completeResponse,
  ) {
    final int gameId = _intValue(game['id']);

    final int platformId = _intValue(game['platform']);

    final String image = _getGameImage(gameId, completeResponse);

    final String platformName = _getPlatformName(platformId, completeResponse);

    final List<String> genreNames = _getGenreNames(game['genres']);

    final String overview = _stringValue(game['overview']);

    return {
      'id': gameId,

      'name': _stringValue(game['game_title']),

      'background_image': image,

      'released': _stringValue(game['release_date']),

      'rating': 0.0,

      'genres': genreNames.map((String genre) => {'name': genre}).toList(),

      'platforms': [
        if (platformName.isNotEmpty)
          {
            'platform': {'id': platformId, 'name': platformName},
          },
      ],

      'description': overview,

      'description_raw': overview,

      'developers': [],

      'publishers': [],

      'playtime': 0,

      'website': '',

      'metacritic': null,

      'esrb_rating': {'name': _stringValue(game['rating'])},

      'youtube': _stringValue(game['youtube']),

      'players': game['players'] ?? 0,

      'coop': _stringValue(game['coop']),
    };
  }

  List<String> _getGenreNames(dynamic genres) {
    if (genres == null) {
      return [];
    }

    final List<String> names = [];

    if (genres is List) {
      for (final dynamic genre in genres) {
        int genreId = 0;

        if (genre is int || genre is num || genre is String) {
          genreId = _intValue(genre);
        } else if (genre is Map) {
          genreId = _intValue(genre['id']);
        }

        final String? name = _genresCache[genreId];

        if (name != null && name.isNotEmpty && !names.contains(name)) {
          names.add(name);
        }
      }
    }

    return names;
  }

  String _getGameImage(int gameId, Map<String, dynamic> response) {
    try {
      final dynamic include = response['include'];

      if (include is! Map) {
        return '';
      }

      final dynamic boxart = include['boxart'];

      if (boxart is! Map) {
        return '';
      }

      final dynamic baseUrl = boxart['base_url'];

      final dynamic data = boxart['data'];

      if (baseUrl is! Map || data is! Map) {
        return '';
      }

      String base = _stringValue(baseUrl['medium']);

      if (base.isEmpty) {
        base = _stringValue(baseUrl['original']);
      }

      final dynamic images = data[gameId.toString()];

      if (images is! List || images.isEmpty) {
        return '';
      }

      Map<String, dynamic>? selectedImage;

      // Intentamos utilizar primero
      // la portada frontal.
      for (final dynamic item in images) {
        if (item is! Map) {
          continue;
        }

        final Map<String, dynamic> image = Map<String, dynamic>.from(item);

        final String type = _stringValue(image['type']);

        final String side = _stringValue(image['side']);

        if (type.toLowerCase() == 'boxart' && side.toLowerCase() == 'front') {
          selectedImage = image;
          break;
        }
      }

      if (selectedImage == null) {
        final dynamic first = images.first;

        if (first is Map) {
          selectedImage = Map<String, dynamic>.from(first);
        }
      }

      if (selectedImage == null) {
        return '';
      }

      final String filename = _stringValue(selectedImage['filename']);

      if (base.isEmpty || filename.isEmpty) {
        return '';
      }

      if (base.endsWith('/') || filename.startsWith('/')) {
        return '$base$filename';
      }

      return '$base/$filename';
    } catch (_) {
      return '';
    }
  }

  String _getPlatformName(int platformId, Map<String, dynamic> response) {
    try {
      final dynamic include = response['include'];

      if (include is! Map) {
        return _fallbackPlatformName(platformId);
      }

      final dynamic platform = include['platform'];

      if (platform is! Map) {
        return _fallbackPlatformName(platformId);
      }

      dynamic platformData = platform['data'];

      platformData ??= platform;

      if (platformData is! Map) {
        return _fallbackPlatformName(platformId);
      }

      final dynamic selected = platformData[platformId.toString()];

      if (selected is Map) {
        final String name = _stringValue(selected['name']);

        if (name.isNotEmpty) {
          return name;
        }
      }

      return _fallbackPlatformName(platformId);
    } catch (_) {
      return _fallbackPlatformName(platformId);
    }
  }

  String _fallbackPlatformName(int platformId) {
    switch (platformId) {
      case 1:
        return 'PC';

      case 4980:
        return 'PlayStation 5';

      case 4981:
        return 'Xbox Series X/S';

      case 4971:
        return 'Nintendo Switch';

      default:
        return '';
    }
  }

  String? _getTheGamesDbPlatformId(int? parentPlatformId) {
    switch (parentPlatformId) {
      // PC
      case 1:
        return '1';

      case 2:
        return '4980';

      case 3:
        return '4981';

      case 7:
        return '4971';

      default:
        return null;
    }
  }

  int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _stringValue(dynamic value) {
    if (value == null) {
      return '';
    }

    final String text = value.toString().trim();

    if (text.toLowerCase() == 'null') {
      return '';
    }

    return text;
  }

  static const String _defaultPlatform = '1';
}
