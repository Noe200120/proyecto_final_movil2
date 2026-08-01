class GameModel {
  final int id;
  final String name;
  final String backgroundImage;
  final double rating;
  final String released;
  final List<String> platforms;
  final List<String> genres;

  GameModel({
    required this.id,
    required this.name,
    required this.backgroundImage,
    required this.rating,
    required this.released,
    required this.platforms,
    required this.genres,
  });

  /// Maneja tanto la API de RAWG como documentos guardados en Firestore
  factory GameModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawPlatforms = json['platforms'] ?? [];
    final List<dynamic> rawGenres = json['genres'] ?? [];

    // Parseo inteligente de plataformas (RAWG API vs Firestore)
    final List<String> parsedPlatforms = rawPlatforms.map((item) {
      if (item is Map && item.containsKey('platform')) {
        return item['platform']['name'].toString(); // Estructura RAWG API
      }
      return item.toString(); // Lista simple de Firestore
    }).toList();

    // Parseo inteligente de géneros (RAWG API vs Firestore)
    final List<String> parsedGenres = rawGenres.map((item) {
      if (item is Map && item.containsKey('name')) {
        return item['name'].toString(); // Estructura RAWG API
      }
      return item.toString(); // Lista simple de Firestore
    }).toList();

    return GameModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Sin nombre',
      // Mapea 'backgroundImage' (Firestore) o 'background_image' (RAWG)
      backgroundImage: json['backgroundImage'] ?? json['background_image'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      released: json['released'] ?? 'Sin fecha',
      platforms: parsedPlatforms,
      genres: parsedGenres,
    );
  }

  /// Convierte la instancia a un Map para guardarlo en Cloud Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'backgroundImage': backgroundImage,
      'rating': rating,
      'released': released,
      'platforms': platforms,
      'genres': genres,
    };
  }
}

class RequestGamesModel {
  final int count;
  final List<GameModel> results;

  RequestGamesModel({
    required this.count,
    required this.results,
  });

  factory RequestGamesModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> resultsJson = json['results'] ?? [];

    return RequestGamesModel(
      count: json['count'] ?? 0,
      results: resultsJson
          .map(
            (game) => GameModel.fromJson(
              Map<String, dynamic>.from(game),
            ),
          )
          .toList(),
    );
  }
}