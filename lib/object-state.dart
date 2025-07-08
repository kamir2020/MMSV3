class States {
  final String stateID;
  final String stateName;

  States({required this.stateID, required this.stateName});

  factory States.fromJson(Map<String, dynamic> json) {
    return States(
      stateID: json['stateID'],
      stateName: json['stateName'],
    );
  }

}