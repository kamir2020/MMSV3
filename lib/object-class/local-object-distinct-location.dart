class localDistinctLocation {

  final int id;
  final String stateID;
  final String categoryID;
  final String categoryName;

  localDistinctLocation({required this.id,
    required this.stateID,
    required this.categoryID,
    required this.categoryName,
  });

  factory localDistinctLocation.fromMap(Map<String, dynamic> map) {
    return localDistinctLocation(
        id: map['id'],
        stateID: map['stateID'],
        categoryID: map['categoryID'],
        categoryName: map['categoryName']);
  }


}