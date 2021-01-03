import 'package:expenses_book_app/db_interface.dart';
import 'package:flutter/material.dart';

class Detail extends StatelessWidget {
  final List<Expense> items = dbInterface().expenses() as List<Expense>;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("月別詳細"),
      ),
      body: Container(
        height: double.infinity,
        child: ListView.builder(
          itemCount: 12,
          itemBuilder: (context, Expense) {

            //収支のリスト表示
            return ListTile(
              leading: Text("支出"),
              title: Text('${items[Expense]}'),
              trailing: Text("money"),
            );
          },
        ),
      ),
    );
  }
}
