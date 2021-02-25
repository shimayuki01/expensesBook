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
  int year;
  int month;
  int income;
  int outgo;
  int sum;

  MonthData(int _year, int _month, int come, int out) {
    this.year = _year;
    this.month = _month;
    this.income = come;
    this.outgo = -out;
    sum = this.income - this.outgo;
  }

  @override
  String toString() {
    return 'year: $year month: $month in: $income, out: $outgo, sum: $sum';
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
    int _max = await getMaxId();
    for(int i = 0; i <= _max;i++){
      deleteExpense(i);
    }
  }

  //データ挿入
  Future<void> insertExpense(Expense expense) async {
    await _database.insert(
      'expenses',
      expense.toMap(),
      //conflictAlgorithm: ConflictAlgorithm.,
    );
  }

  //全データ表示
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

  //月別データ表示
  Future<List<Expense>> monthExpenses(int year, int month) async {
    final List<Map<String, dynamic>> maps = await _database.query("expenses",
        where: "year = ? and month = ?",
        whereArgs: [year.toString(), month.toString()],
        orderBy: "day");
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

  //月の収支合計表示
  Future<MonthData> monthSum(int year, int month) async {
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

    MonthData _month = MonthData(year, month, come, out);

    return _month;
  }

  //過去の月別収支合計のリスト表示(一年)
  Future<List<MonthData>> monthSumList() async {
    List<MonthData> msl = []..length = 36;
    int _year = DateTime.now().year;
    int _month = DateTime.now().month;
    for (int i = 0; i < msl.length; i++) {
      msl[i] = await monthSum(_year, _month);
      if (_month == 1) {
        _year = _year - 1;
        _month = 12;
      } else
        _month = _month - 1;
    }
    return msl;
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

  //データ取得
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

  //データ削除
  Future<void> deleteExpense(int id) async {
    final db = _database;
    await db.delete(
      'expenses',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
