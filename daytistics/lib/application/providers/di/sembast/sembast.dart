import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast_io.dart';

part 'sembast.g.dart';

@riverpod
Future<Database?> sembastDependency(Ref ref) async {
  final dir = await getApplicationDocumentsDirectory();
  final dbPath = '${dir.path}/daytistics.db';
  final db = await databaseFactoryIo.openDatabase(dbPath);
  return db;
}
