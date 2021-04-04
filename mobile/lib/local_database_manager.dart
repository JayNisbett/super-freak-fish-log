import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/utils/utils.dart';

import 'app_manager.dart';
import 'database/sqlite_open_helper.dart';
import 'log.dart';
import 'model/gen/anglerslog.pb.dart';
import 'utils/protobuf_utils.dart';
import 'wrappers/io_wrapper.dart';

class LocalDatabaseManager {
  static LocalDatabaseManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).localDatabaseManager;

  final _log = Log("DataManager");
  final AppManager _appManager;

  late DatabaseExecutor _database;
  late Future<DatabaseExecutor> Function() _openDatabase;

  LocalDatabaseManager(this._appManager);

  IoWrapper get _ioWrapper => _appManager.ioWrapper;

  Future<void> initialize({
    DatabaseExecutor? database,
    Future<DatabaseExecutor> Function()? openDatabase,
  }) async {
    _openDatabase = openDatabase ?? openDb;
    _database = database ?? (await _openDatabase());
  }

  /// Commits a batch of SQL statements. See [Batch].
  Future<List<dynamic>> commitBatch(void Function(Batch) execute) async {
    var batch = _database.batch();
    execute(batch);
    return await batch.commit();
  }

  /// Returns `true` if values were successfully added.
  Future<bool> insert(String tableName, Map<String, dynamic> values) async {
    return await _database.insert(tableName, values) > 0;
  }

  /// Returns `true` if values were successfully added or replaced.
  Future<bool> insertOrReplace(
      String tableName, Map<String, dynamic> values) async {
    return await _database.insert(tableName, values,
            conflictAlgorithm: ConflictAlgorithm.replace) >
        0;
  }

  /// Returns `true` if at least one row was removed.
  Future<bool> delete(String table,
      {String? where, List<dynamic>? whereArgs}) async {
    return await _database.delete(table, where: where, whereArgs: whereArgs) >
        0;
  }

  /// Allows a raw query to be sent to the database.
  Future<List<Map<String, dynamic>>> query(String sql, [List<dynamic>? args]) {
    return _database.rawQuery(sql, args);
  }

  Future<bool> rawExists(String query, [List<dynamic>? args]) async {
    return Sqflite.firstIntValue(await _database.rawQuery(query, args))
            as FutureOr<bool>? ??
        0 > 0;
  }

  Future<bool> rawUpdate(String query, [List<dynamic>? args]) async {
    return await _database.rawUpdate(query, args) > 0;
  }

  /// Deletes a given [Entity] from the given [tableName].
  Future<bool> deleteEntity(Id entityId, String tableName) async {
    // For details on the hex requirement, see
    // https://github.com/tekartik/sqflite/issues/608.
    var id = entityId.uint8List;
    if (await delete(
      tableName,
      where: _ioWrapper.isAndroid ? "hex(id) = ?" : "id = ?",
      whereArgs: [_ioWrapper.isAndroid ? hex(id) : id],
    )) {
      return true;
    } else {
      _log.e("Failed to delete $tableName(${entityId.uuid.toString()})"
          " from database");
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> fetchAll(String tableName) async {
    return await query("SELECT * FROM $tableName");
  }

  /// Completely replaces the contents of [tableName] with [newRows].
  Future<void> replaceRows(
      String tableName, List<Map<String, dynamic>> newRows) async {
    await commitBatch((batch) {
      batch.rawQuery("DELETE FROM $tableName");
      for (var row in newRows) {
        batch.insert(tableName, row);
      }
    });
  }
}
