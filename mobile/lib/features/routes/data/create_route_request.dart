import 'route_photo.dart';

class CreateRouteRequest {
  const CreateRouteRequest({
    required this.title,
    required this.description,
    required this.estimatedBudget,
    required this.stops,
    this.coverPhoto,
  });

  final String title;
  final String description;
  final double estimatedBudget;
  final List<CreateRouteStopRequest> stops;
  final RoutePhoto? coverPhoto;

  String? get coverImageSource => coverPhoto?.source;

  Map<String, dynamic> toJson() {
    return {
      'title': title.trim(),
      'description': description.trim(),
      'estimatedBudget': estimatedBudget,
      'coverImageUrl': coverPhoto == null ? '' : 'pending-local-cover',
      'stops': stops.map((stop) => stop.toJson()).toList(),
    };
  }
}

class CreateRouteStopRequest {
  const CreateRouteStopRequest({
    required this.cityName,
    required this.stopName,
    required this.dayNumber,
    required this.notes,
    this.photos = const [],
  });

  final String cityName;
  final String stopName;
  final int dayNumber;
  final String notes;
  final List<RoutePhoto> photos;

  List<String> get photoSources => [
        for (final photo in photos) photo.source,
      ];

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName.trim(),
      'stopName': stopName.trim(),
      'dayNumber': dayNumber,
      'notes': notes.trim(),
      'photoUrls': [
        for (var index = 0; index < photos.length; index++)
          'pending-local-stop-photo-$index',
      ],
    };
  }
}
