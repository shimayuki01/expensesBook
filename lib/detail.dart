import 'package:expenses_book_app/db_interface.dart';
import 'package:flutter/material.dart';

class Detail extends StatelessWidget {

  List<Expense> items;
  void _setList() async{
    final List<Expense> items = await dbInterface().expenses();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("詳細"),
      ),
      body: Container(
        height: double.infinity,
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {

            //収支のリスト表示
            return ListTile(
              leading: Text("支出"),
              title: Text('${items[index]}'),
              trailing: Text(""),
            );
          },
        ),
      ),
    );
  }
}
