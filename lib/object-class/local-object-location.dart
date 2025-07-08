class localLocation {

  final int id;
  final String stationID;
  final String stateID;
  final String categoryName;
  final String locationName;
  final String longitude;
  final String latitude;

  localLocation({required this.id,
    required this.stationID,
    required this.stateID,
    required this.categoryName,
    required this.locationName,
    required this.longitude,
    required this.latitude,
  });

  factory localLocation.fromMap(Map<String, dynamic> map) {
    return localLocation(
      id: map['id'],
      stationID: map['stationID'],
      stateID: map['stateID'],
      categoryName: map['categoryName'],
      locationName: map['locationName'],
      longitude: map['longitude'],
      latitude: map['latitude']);
  }


}