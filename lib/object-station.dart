class Station {
  final String stationID;
  final String stateID;
  final String locationName;
  final String latitude;
  final String longitude;
  final String stateName;
  final String categoryName;

  Station({required this.stationID, required this.stateID, required this.locationName,
    required this.latitude, required this.longitude, required this.stateName, required this.categoryName});

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      stationID: json['stationID'],
      stateID: json['stateID'],
      locationName: json['locationName'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      stateName: json['stateName'],
      categoryName: json['categoryName'],
    );
  }

}