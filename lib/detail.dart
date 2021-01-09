import 'package:expenses_book_app/db_interface.dart';
import 'package:flutter/material.dart';

class Detail_page extends StatefulWidget {
  @override
  Detail createState() => new Detail();
}

class Detail extends State<Detail_page> {
  List<Expense> items;

  void _setList() async {
    List<Expense> maps = await dbInterface().expenses();
    print(maps.length);
    items = maps;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future(() async {
      _setList();
      await Future.delayed((Duration(seconds: 1)));
    });
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
