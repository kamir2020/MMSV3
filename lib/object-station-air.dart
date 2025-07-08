class StationAir {
  final String id;
  final String stationID;
  final String stateID;
  final String locationName;
  final String temp;
  final String timestamp;

  StationAir({required this.id,required this.stationID, required this.stateID, required this.locationName,
    required this.temp,required this.timestamp});

  factory StationAir.fromJson(Map<String, dynamic> json) {
    return StationAir(
      id: json['id'],
      stationID: json['stationID'],
      stateID: json['stateID'],
      locationName: json['locationName'],
      temp: json['temp'],
      timestamp: json['timestamp'],
    );
  }

}