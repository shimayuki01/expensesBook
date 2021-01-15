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
