class StationRiver {
  final String stationID;
  final String stateID;
  final String basinName;
  final String riverName;
  final String latitude;
  final String longitude;
  final String stateName;

  StationRiver({required this.stationID, required this.stateID, required this.basinName,
    required this.riverName,required this.latitude,required this.longitude,required this.stateName});

  factory StationRiver.fromJson(Map<String, dynamic> json) {
    return StationRiver(
      stationID: json['stationID'],
      stateID: json['stateID'],
      basinName: json['basinName'],
      riverName: json['riverName'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      stateName: json['stateName']
    );
  }

}