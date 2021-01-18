import 'package:flutter/foundation.dart';
import 'package:expenses_book_app/db_interface.dart';

class DbListReload extends ChangeNotifier {
  List<Expense> monthExpense;

  List<Expense> get listExpense => monthExpense;

  Future<void> getList(int year, int month) async {
    monthExpense = await DbInterface().monthExpenses(year, month);
    notifyListeners();
  }
}

class ThisMonthReload extends ChangeNotifier {
  MonthData _monthData;

  MonthData get monthData => _monthData;

  Future<void> getMonthData(int year, int month) async {
    print("getmonth $_monthData");
    _monthData = await DbInterface().monthSum(year, month);
    notifyListeners();
  }
}

class PastData extends ChangeNotifier {
  List<Expense> _pastExpense;

  List<Expense> get pastExpense => _pastExpense;

  Future<void> getList() async {
    _pastExpense = await DbInterface().expenses();
    notifyListeners();
  }
}

