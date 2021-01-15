import 'package:flutter/foundation.dart';
import 'package:expenses_book_app/db_interface.dart';

class DbListReload extends ChangeNotifier {

  List<Expense> _monthExpense = [];

  List<Expense> get listExpense => _monthExpense;

  DbListReload() {
    getList();
  }

  Future<void> getList() async {
    _monthExpense = await DbInterface().expenses();
    notifyListeners();
  }
}
