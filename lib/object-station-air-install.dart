class StationAirInstall {
  final String id;
  final String refID;
  final String stationID;
  final String locationName;
  final String temp;
  final String timestamp;

  StationAirInstall({required this.id,required this.refID, required this.stationID,
    required this.locationName,required this.temp,required this.timestamp});

  factory StationAirInstall.fromJson(Map<String, dynamic> json) {
    return StationAirInstall(
      id: json['id'],
      refID: json['refID'],
      stationID: json['stationID'],
      locationName: json['locationName'],
      temp: json['temp'],
      timestamp: json['timestamp'],
    );
  }

}