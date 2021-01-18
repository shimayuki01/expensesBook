import 'package:flutter/foundation.dart';
import 'package:expenses_book_app/db_interface.dart';

//月の詳細データ
class DbListReload extends ChangeNotifier {
  List<Expense> monthExpense;

  List<Expense> get listExpense => monthExpense;

  Future<void> getList(int year, int month) async {
    monthExpense = await DbInterface().monthExpenses(year, month);
    notifyListeners();
  }
}

//今月の収支合計
class ThisMonthReload extends ChangeNotifier {
  MonthData _monthData;

  MonthData get monthData => _monthData;

  Future<void> getMonthData(int year, int month) async {
    _monthData = await DbInterface().monthSum(year, month);
    notifyListeners();
  }
}

//過去一年間の収支合計
class PastSumData extends ChangeNotifier {
  List<MonthData> _pastMonthSum;

  List<MonthData> get pastMonthSum => _pastMonthSum;

  Future<void> getList() async {
    _pastMonthSum = await DbInterface().monthSumList();
    notifyListeners();
  }
}

