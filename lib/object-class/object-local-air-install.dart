class localAirInstall {
  final int id;
  final String refID;
  final String clientID;
  final String stationID;
  final String locationName;
  final String region;
  final String sampleDate;
  final String weather;
  final String temp;
  final String pm10;
  final String pm2;
  final String remark;
  final String statusID;
  final String timestamp;

  localAirInstall({required this.id, required this.refID, required this.clientID, required this.stationID,
    required this.locationName,
    required this.region,required this.sampleDate,required this.weather,
    required this.temp,required this.pm10,required this.pm2,required this.remark,
    required this.statusID,required this.timestamp});

  factory localAirInstall.fromMap(Map<String, dynamic> map) {
    return localAirInstall(
        id: map['id'],
        refID: map['refID'],
        clientID: map['clientID'],
        stationID: map['stationID'],
        locationName: map['locationName'],
        temp: map['temp'],
        pm10: map['pm10'],
        pm2: map['pm2'],
        remark: map['remark'],
        region: map['region'],
        sampleDate: map['sampleDate'],
        weather: map['weather'],
        statusID: map['statusID'],
        timestamp: map['timestamp']);
  }

}