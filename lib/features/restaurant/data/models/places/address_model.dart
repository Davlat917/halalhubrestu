class AddressModel {
  const AddressModel({required this.predictions, required this.status});

  final List<PlaceAutocompletePrediction> predictions;
  final String status;

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    final raw = json['predictions'];
    final list = raw is List<dynamic>
        ? raw
            .map((e) => PlaceAutocompletePrediction.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList()
        : <PlaceAutocompletePrediction>[];
    return AddressModel(
      predictions: list,
      status: json['status'] as String? ?? 'UNKNOWN',
    );
  }
}

class PlaceAutocompletePrediction {
  const PlaceAutocompletePrediction({
    required this.description,
    required this.placeId,
  });

  final String description;
  final String placeId;

  factory PlaceAutocompletePrediction.fromJson(Map<String, dynamic> json) {
    return PlaceAutocompletePrediction(
      description: json['description'] as String? ?? '',
      placeId: json['place_id'] as String? ?? '',
    );
  }
}
