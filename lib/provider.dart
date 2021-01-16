import 'package:flutter/foundation.dart';
import 'package:expenses_book_app/db_interface.dart';

class DbListReload extends ChangeNotifier {
  List<Expense> monthExpense;

  List<Expense> get listExpense => monthExpense;

  Future<void> getList() async {
    monthExpense = await DbInterface().expenses();
    notifyListeners();
  }
}

class MonthDataReload extends ChangeNotifier {
  MonthData _monthData;

  MonthData get monthData => _monthData;

  Future<void> getMonthData(int year, int month) async {
    print("getmonth $_monthData");
    _monthData = await DbInterface().monthExpense(year, month);
    notifyListeners();
  }
}
