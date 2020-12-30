import 'dart:math';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';

//データベースに格納するクラス作成
class Expense {
  final int id;
  final int year;
  final int month;
  final int day;
  final String payment; //収支判別
  final String name;
  final int money;

  Expense(
      {this.id,
      this.payment,
      this.year,
      this.month,
      this.day,
      this.name,
      this.money});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
     // 'payment': payment,
      'year': year,
      'month': month,
      'day': day,
      'name': name,
      'money': money,
    };
  }

  @override
  String toString() {
    //return 'Expense{id: $id, /*payment: $payment, year: $year, month: $month, day: $day, name: $name, money: $money}';
    return 'Expense{id: $id, year: $year, month: $month, day: $day, name: $name, money: $money}';
  }
}

//データベースインタフェース
class dbInterface {

  Database database;
  //データベース作成（初期化）
  void init() async {
    //WidgetsFlutterBinding.ensureInitialized();
     database = await openDatabase(
      join(await getDatabasesPath(), 'expenses_database.db'),
      onCreate: (db, version) {
        return db.execute(
          //"CREATE TABLE expenses(id INTEGER PRIMARY KEY, payment TEXT,  year Integer, month Integer, day Integer, name Text, money Integer)",
          "CREATE TABLE expenses(id INTEGER PRIMARY KEY, year Integer, month Integer, day Integer, name Text, money Integer)",
        );
      },
      version: 1,
    );
  }

  //データ挿入
  Future<void> insertExpense(Expense expense) async {
     final Database db = database;

    await db.insert(
      'expsenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //データ表示
  Future<List<Expense>> expenses() async {
    final Database db = database;
    final List<Map<String, dynamic>> maps = await db.query('expenses');
    return List.generate(maps.length, (i) {
      return Expense(
        id: maps[i]['id'],
        year: maps[i]['year'],
        month: maps[i]['month'],
        day: maps[i]['day'],
        name: maps[i]['name'],
        money: maps[i]['money'],
      );
    });
  }

  //データ更新
  Future<void> updateExpense(Expense expense) async {
    final db = database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: "id = ?",
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteExpense(int id) async {
    final db = database;
    await db.delete(
      'expenses',
      where: "id = ?",
      whereArgs: [id],
    );
  }


}
