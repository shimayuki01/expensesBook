import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

//データベースに格納するクラス作成
class Expense {
  final int id;
  final int year;
  final int month;
  final int day;
  final String name;
  final int money;

  Expense({this.id, this.year, this.month, this.day, this.name, this.money});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'month': month,
      'day': day,
      'name': name,
      'money': money,
    };
  }

  @override
  String toString() {
    return 'Expense{id: $id, year: $year, month: $month, day: $day, name: $name, money: $money}';
  }
}

class MonthData {
  int income;
  int outgo;
  int sum;

  MonthData(int come, int out) {
    this.income = come;
    this.outgo = -out;
    sum = this.income - this.outgo;
  }

  @override
  String toString() {
    return 'in: $income, out: $outgo, sum: $sum';
  }
}

//データベースインタフェース
class DbInterface {
  static Database _database;

  //データベース作成（初期化）
  Future<void> init() async {
    _database = await database;
  }

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, "expenses_database.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE expenses(id INTEGER PRIMARY KEY, year Integer, month Integer, day Integer, name Text, money Integer)",
        );
      },
      onDowngrade: onDatabaseDowngradeDelete,
    );
  }

  //データベース削除
  Future<void> delDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, "expenses_database.db");
    await deleteDatabase(path);
  }

  //データ挿入
  Future<void> insertExpense(Expense expense) async {
    await _database.insert(
      'expenses',
      expense.toMap(),
      //conflictAlgorithm: ConflictAlgorithm.,
    );
  }

  //データ表示
  Future<List<Expense>> expenses() async {
    final List<Map<String, dynamic>> maps = await _database.query("expenses");
    if (maps.length != 0) {
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
    } else {
      return null;
    }
  }

  Future<MonthData> monthExpense(int year, int month) async {
    final List<Map<String, dynamic>> income = await _database.rawQuery(
        'select sum(money) from expenses where year = ? and month = ? and money > 0',
        [year.toString(), month.toString()]);
    final List<Map<String, dynamic>> outgo = await _database.rawQuery(
        'select sum(money) from expenses where year = ? and month = ? and money < 0',
        [year.toString(), month.toString()]);
    int come = 0;
    int out = 0;


    if (income[0]['sum(money)'] != null) come = income[0]['sum(money)'];

    if (outgo[0]['sum(money)'] != null) out = outgo[0]['sum(money)'];

    MonthData _month = MonthData(come, out);

    return _month;
  }

  //id最大値取得
  Future<int> getMaxId() async {
    final List<Map<String, dynamic>> maps =
        await _database.rawQuery('select max(id) from expenses');
    List<int> map = List.generate(1, (i) => maps[i]['max(id)']);
    if (map[0] != null)
      return map[0] + 1;
    else
      return 1;
  }

  Future<Expense> getData(int id) async {
    List<Map<String, dynamic>> maps = await _database.query(
      'expenses',
      where: "id = ?",
      whereArgs: [id],
    );

    Expense _data = Expense(
      id: maps[0]['id'],
      year: maps[0]['year'],
      month: maps[0]['month'],
      day: maps[0]['day'],
      name: maps[0]['name'],
      money: maps[0]['money'],
    );
    return _data;
  }

  //データ更新
  Future<void> updateExpense(Expense expense) async {
    final db = _database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: "id = ?",
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteExpense(int id) async {
    final db = _database;
    await db.delete(
      'expenses',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
