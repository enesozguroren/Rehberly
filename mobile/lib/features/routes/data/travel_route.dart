class TravelRoute {
  const TravelRoute({
    required this.id,
    required this.ownerUsername,
    required this.title,
    required this.description,
    required this.estimatedBudget,
    required this.createdAt,
    required this.stops,
    required this.likesCount,
    required this.commentsCount,
    required this.savesCount,
    required this.isLiked,
    required this.isSaved,
  });

  final String id;
  final String ownerUsername;
  final String title;
  final String description;
  final double estimatedBudget;
  final DateTime createdAt;
  final List<RouteStop> stops;
  final int likesCount;
  final int commentsCount;
  final int savesCount;
  final bool isLiked;
  final bool isSaved;

  String get budgetLabel => '\$${estimatedBudget.toStringAsFixed(0)}';

  String get imageAsset {
    const images = [
      'assets/images/aegean-wonders.jpg',
      'assets/images/japan-spring.jpg',
      'assets/images/norway-fjords.jpg',
      'assets/images/morocco-desert.jpg',
      'assets/images/bali-terraces.jpg',
    ];
    final seed = stops.isNotEmpty ? stops.first.cityName : title;
    final hash = seed.codeUnits.fold<int>(0, (value, unit) => value + unit);
    return images[hash.abs() % images.length];
  }

  bool matches(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;

    return title.toLowerCase().contains(normalized) ||
        description.toLowerCase().contains(normalized) ||
        ownerUsername.toLowerCase().contains(normalized) ||
        stops.any((stop) =>
            stop.cityName.toLowerCase().contains(normalized) ||
            stop.stopName.toLowerCase().contains(normalized),);
  }

  TravelRoute copyWith({
    int? likesCount,
    int? commentsCount,
    int? savesCount,
    bool? isLiked,
    bool? isSaved,
  }) {
    return TravelRoute(
      id: id,
      ownerUsername: ownerUsername,
      title: title,
      description: description,
      estimatedBudget: estimatedBudget,
      createdAt: createdAt,
      stops: stops,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      savesCount: savesCount ?? this.savesCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  factory TravelRoute.fromJson(Map<String, dynamic> json) {
    return TravelRoute(
      id: json['id'] as String,
      ownerUsername: json['ownerUsername'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      estimatedBudget: (json['estimatedBudget'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      stops: (json['stops'] as List<dynamic>? ?? [])
          .map((item) => RouteStop.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      savesCount: (json['savesCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
    );
  }
}

class RouteStop {
  const RouteStop({
    required this.id,
    required this.cityName,
    required this.stopName,
    required this.dayNumber,
    required this.notes,
  });

  final String id;
  final String cityName;
  final String stopName;
  final int dayNumber;
  final String notes;

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      id: json['id'] as String? ?? '',
      cityName: json['cityName'] as String? ?? '',
      stopName: json['stopName'] as String? ?? '',
      dayNumber: (json['dayNumber'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String? ?? '',
    );
  }
}
