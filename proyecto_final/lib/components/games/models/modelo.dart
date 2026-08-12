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

  factory GameModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawPlatforms = json['platforms'] ?? [];
    final List<dynamic> rawGenres = json['genres'] ?? [];

    final List<String> parsedPlatforms = rawPlatforms.map((item) {
      if (item is Map && item.containsKey('platform')) {
        return item['platform']['name'].toString();
      }
      return item.toString();
    }).toList();

    final List<String> parsedGenres = rawGenres.map((item) {
      if (item is Map && item.containsKey('name')) {
        return item['name'].toString();
      }
      return item.toString();
    }).toList();

    return GameModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Sin nombre',
      backgroundImage:
          json['backgroundImage'] ?? json['background_image'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      released: json['released'] ?? 'Sin fecha',
      platforms: parsedPlatforms,
      genres: parsedGenres,
    );
  }

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

  RequestGamesModel({required this.count, required this.results});

  factory RequestGamesModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> resultsJson = json['results'] ?? [];

    return RequestGamesModel(
      count: json['count'] ?? 0,
      results: resultsJson
          .map((game) => GameModel.fromJson(Map<String, dynamic>.from(game)))
          .toList(),
    );
  }
}
