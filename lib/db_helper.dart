import 'package:app_mms/object-class/local-object-category.dart';
import 'package:app_mms/object-class/local-object-distinct-location.dart';
import 'package:app_mms/object-class/local-object-location.dart';
import 'package:app_mms/object-class/local-object-state.dart';
import 'package:app_mms/object-class/local-object-user.dart';
import 'package:app_mms/object-class/object-local-air-install.dart';
import 'package:http/http.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> initDb() async {
    if (_db != null) return _db!;
    String path = join(await getDatabasesPath(), 'mms.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE tbl_users (
          id INTEGER PRIMARY KEY,
          fullName TEXT,
          email TEXT,
          password TEXT,
          userID TEXT,
          levelID TEXT,
          departID TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE tbl_sampler (
          id INTEGER PRIMARY KEY,
          fullname TEXT,
          email TEXT,
          userID TEXT
        )
      ''');

      // create table tbl_category
      await db.execute('''
        CREATE TABLE tbl_category (
          id INTEGER PRIMARY KEY,
          categoryID TEXT,
          categoryName TEXT
        )
      ''');

      // create table tbl_state
      await db.execute('''
        CREATE TABLE tbl_state (
          id INTEGER PRIMARY KEY,
          stateID TEXT,
          stateName TEXT
        )
      ''');

      // create table tbl_marine_station
      await db.execute('''
        CREATE TABLE tbl_marine_station (
          id INTEGER PRIMARY KEY,
          stationID TEXT,
          stateID TEXT,
          categoryID TEXT,
          locationName TEXT,
          latitude TEXT,
          longitude TEXT
        )
      ''');

      // create table tbl_marine_insitu_sampling
      await db.execute('''
        CREATE TABLE tbl_marine_insitu_sampling (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          reportID TEXT,
          firstSampler TEXT,
          secondSampler TEXT,
          dateController TEXT,
          timeController TEXT,
          type TEXT,
          stationName TEXT,
          sampleCode TEXT,
          latitude TEXT,
          longitude TEXT,
          distance TEXT,
          weather TEXT,
          tide TEXT,
          sea TEXT,
          eventRemarks TEXT DEFAULT NULL,
          labRemarks TEXT DEFAULT NULL,
          sondeID TEXT,
          dateCapture TEXT,
          timeCapture TEXT,
          oxygen1 TEXT,
          oxygen2 TEXT,
          pH TEXT,
          sanility TEXT,
          ec TEXT,
          temperature TEXT,
          tds TEXT,
          turbidity TEXT,
          tss TEXT,
          battery TEXT,
          stationID TEXT,
          timestamp TEXT
        )
      ''');

      // create table tbl_tarball_station
      await db.execute('''
        CREATE TABLE tbl_tarball_station (
          id INTEGER PRIMARY KEY,
          stationID TEXT,
          stateID TEXT,
          categoryID TEXT,
          locationName TEXT,
          longitude TEXT,
          latitude TEXT
        )
      ''');

      // create table tbl_marine_tarball
      // S1 - local, S2 - submitted to server
      await db.execute('''
        CREATE TABLE tbl_marine_tarball (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          reportID TEXT,
          firstSampler TEXT,
          secondSampler TEXT,
          dateSample TEXT,
          timeSample TEXT,
          stationID TEXT,
          classifyID TEXT,
          latitude TEXT,
          longitude TEXT,
          getLatitude TEXT,
          getLongitude TEXT,
          distance TEXT,
          optionalName1 TEXT DEFAULT NULL,
          optionalName2 TEXT DEFAULT NULL,
          optionalName3 TEXT DEFAULT NULL,
          optionalName4 TEXT DEFAULT NULL,
          timestamp TEXT
        )
      ''');

      // create table tbl_air_station
      await db.execute('''
        CREATE TABLE tbl_air_station (
          id INTEGER PRIMARY KEY,
          stationID TEXT,
          stateID TEXT,
          categoryID TEXT,
          locationName TEXT,
          longitude TEXT,
          latitude TEXT
        )
      ''');

      // create table tbl_air_install
      await db.execute('''
        CREATE TABLE tbl_air_install (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          refID TEXT,
          clientID TEXT,
          stationID TEXT,
          region TEXT,
          sampleDate TEXT,
          weather TEXT,
          temp TEXT,
          pm10 TEXT,
          pm2 TEXT,
          remark TEXT,
          statusID TEXT,
          timestamp TEXT
        )
      ''');

      // create table tbl_air_collection
      await db.execute('''
        CREATE TABLE tbl_air_collection (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          refID TEXT,
          clientID TEXT,
          stationID TEXT,
          weather TEXT,
          temp TEXT,
          actual1 TEXT,
          actualResult1 TEXT,
          time1 TEXT,
          timeResult1 TEXT,
          pressure1 TEXT,
          pressureResult1 TEXT,
          vstd1 TEXT,
          actual2 TEXT,
          actualResult2 TEXT,
          time2 TEXT,
          timeResult2 TEXT,
          pressure2 TEXT,
          pressureResult2 TEXT,
          vstd2 TEXT,
          remark TEXT,
          timestamp TEXT
        )
      ''');

    });
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await initDb();
    await db.insert('tbl_users', user,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertSampler(Map<String, dynamic> sampler) async {
    final db = await initDb();
    await db.insert('tbl_sampler', sampler,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertCategory(Map<String, dynamic> category) async {
    final db = await initDb();
    await db.insert('tbl_category', category,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertState(Map<String, dynamic> state) async {
    final db = await initDb();
    await db.insert('tbl_state', state,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertMarineStation(Map<String, dynamic> station) async {
    final db = await initDb();
    await db.insert('tbl_marine_station', station,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertTarballStation(Map<String, dynamic> station) async {
    final db = await initDb();
    await db.insert('tbl_tarball_station', station,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertAirStation(Map<String, dynamic> station) async {
    final db = await initDb();
    await db.insert('tbl_air_station', station,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await initDb();
    final result = await db.query('tbl_users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password]);

    return result.isNotEmpty ? result.first : null;
  }

  static Future<List<Map<String, dynamic>>> getData() async {
    final db = await initDb();
    return await db.query('tbl_sampler');
  }


  static Future<List<localUser>> getSampler() async {
    final db = await initDb();
    final List<Map<String, dynamic>> result = await db.query('tbl_sampler');
    return result.map((e) => localUser(id: e['id'],fullname: e['fullname'],
        email: e['email'],userID: e['userID'])).toList();
  }

  static Future<List<localState>> getState() async {
    final db = await initDb();
    final List<Map<String, dynamic>> result = await db.query('tbl_state');
    return result.map((e) => localState(id: e['id'],stateID: e['stateID'], stateName: e['stateName'])).toList();
  }

  static Future<List<localDistinctLocation>> getCategoryTarball(String? stateID) async {
    final db = await initDb(); // your DB init logic
    final result = await db.rawQuery('''
    SELECT DISTINCT tbl_tarball_station.categoryID,
    tbl_tarball_station.id,
    tbl_tarball_station.stateID,
    tbl_category.categoryName
    FROM tbl_tarball_station
      INNER JOIN tbl_category ON tbl_tarball_station.categoryID = tbl_category.categoryID
        WHERE tbl_tarball_station.stateID = ?
        GROUP BY tbl_tarball_station.categoryID
        ORDER BY tbl_category.categoryName ASC 
  ''',[stateID]);

    return result.map((e) => localDistinctLocation.fromMap(e)).toList();
  }

  static Future<List<localDistinctLocation>> getCategoryInSitu(String? stateID) async {
    final db = await initDb(); // your DB init logic
    final result = await db.rawQuery('''
    SELECT DISTINCT tbl_marine_station.categoryID,
    tbl_marine_station.id,
    tbl_marine_station.stateID,
    tbl_category.categoryName
    FROM tbl_marine_station
      INNER JOIN tbl_category ON tbl_marine_station.categoryID = tbl_category.categoryID
        WHERE tbl_marine_station.stateID = ?
        GROUP BY tbl_marine_station.categoryID
        ORDER BY tbl_category.categoryName ASC 
  ''',[stateID]);

    return result.map((e) => localDistinctLocation.fromMap(e)).toList();
  }

  static Future<List<localLocation>> getLocation(String? stateID, String? categoryID) async {
    final db = await initDb(); // your DB init logic
    final result = await db.rawQuery('''
    SELECT tbl_tarball_station.id,
    tbl_tarball_station.stationID,
    tbl_tarball_station.stateID,
    tbl_tarball_station.locationName,
    tbl_tarball_station.longitude,
    tbl_tarball_station.latitude,
    tbl_category.categoryName
    FROM tbl_tarball_station
    INNER JOIN tbl_category ON tbl_tarball_station.categoryID = tbl_category.categoryID
    WHERE tbl_tarball_station.stateID = ? AND tbl_tarball_station.categoryID = ?
  ''',[stateID,categoryID]);

    return result.map((e) => localLocation.fromMap(e)).toList();
  }

  static Future<List<localLocation>> getLocationMarine(String? stateID, String? categoryID) async {
    final db = await initDb(); // your DB init logic
    final result = await db.rawQuery('''
    SELECT tbl_marine_station.id,
    tbl_marine_station.stationID,
    tbl_marine_station.stateID,
    tbl_marine_station.locationName,
    tbl_marine_station.longitude,
    tbl_marine_station.latitude,
    tbl_category.categoryName
    FROM tbl_marine_station
    INNER JOIN tbl_category ON tbl_marine_station.categoryID = tbl_category.categoryID
    WHERE tbl_marine_station.stateID = ? AND tbl_marine_station.categoryID = ?
  ''',[stateID,categoryID]);

    return result.map((e) => localLocation.fromMap(e)).toList();
  }

  static Future<List<localLocation>> getLocationAir(String? stateID) async {
    final db = await initDb(); // your DB init logic
    final result = await db.rawQuery('''
    SELECT tbl_air_station.id,
    tbl_air_station.stationID,
    tbl_air_station.stateID,
    tbl_air_station.locationName,
    tbl_air_station.longitude,
    tbl_air_station.latitude,
    tbl_category.categoryName
    FROM tbl_air_station
    INNER JOIN tbl_category ON tbl_air_station.categoryID = tbl_category.categoryID
    WHERE tbl_air_station.stateID = ? 
  ''',[stateID]);

    return result.map((e) => localLocation.fromMap(e)).toList();
  }

  static Future<List<localAirInstall>> getInstallAir() async {
    final db = await initDb(); // your DB init logic
    final result = await db.rawQuery('''
    SELECT tbl_air_install.id,
    tbl_air_install.refID,
    tbl_air_install.clientID,
    tbl_air_install.stationID,
    tbl_air_install.region,
    tbl_air_install.sampleDate,
    tbl_air_install.weather,
    tbl_air_install.temp,
    tbl_air_install.pm10,
    tbl_air_install.pm2,
    tbl_air_install.remark,
    tbl_air_install.statusID,
    tbl_air_install.timestamp,
    tbl_air_station.locationName
    FROM tbl_air_install
    INNER JOIN tbl_air_station ON tbl_air_install.stationID = tbl_air_station.stationID
    WHERE tbl_air_install.statusID = ?
  ''',['L1']);

    return result.map((e) => localAirInstall.fromMap(e)).toList();
  }

  Future<bool> insertDataMarineInSitu({
    required String tableName,
    required Map<String, dynamic> values,
  }) async {
    try {
      final db = await initDb();
      int id = await db.insert(
        tableName,
        values,
        conflictAlgorithm: ConflictAlgorithm.replace, // or ignore, abort, etc.
      );
      return id > 0;
    } catch (e) {
      print('Insert failed: $e');
      return false;
    }
  }

  Future<bool> insertDataTarball({
    required String tableName,
    required Map<String, dynamic> values,
  }) async {
    try {
      final db = await initDb();
      int id = await db.insert(
        tableName,
        values,
        conflictAlgorithm: ConflictAlgorithm.replace, // or ignore, abort, etc.
      );
      return id > 0;
    } catch (e) {
      print('Insert failed: $e');
      return false;
    }
  }

  Future<bool> insertDataAir({
    required String tableName,
    required Map<String, dynamic> values,
  }) async {
    try {
      final db = await initDb();
      int id = await db.insert(
        tableName,
        values,
        conflictAlgorithm: ConflictAlgorithm.replace, // or ignore, abort, etc.
      );
      return id > 0;
    } catch (e) {
      print('Insert failed: $e');
      return false;
    }
  }

  Future<void> updateDataCollection(String refID , String statusID) async {
    final db = await initDb();
    await db.update(
      'tbl_air_install',
      {
        'statusID': statusID,
      },
      where: 'refID = ?',
      whereArgs: [refID],
    );
  }

  // to get data from table //
  /*
  static Future<List<Map<String, dynamic>>> getDataList() async {
    final db = await initDb();
    final List<Map<String, dynamic>> lists = await db.query('tbl_air_station');
    return lists;
  }*/

}
