import 'package:expenses_book_app/db_interface.dart';
import 'package:expenses_book_app/del_upd_page.dart';
import 'package:expenses_book_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';

class DetailPage extends StatefulWidget {
  final int year;
  final int month;

  DetailPage({this.year, this.month});

  @override
  Detail createState() => new Detail();
}

class Detail extends State<DetailPage> {
  List<Expense> items;
  int _money;

  Future<void> _getMap() async {
    await context.read(listProvider).getList(widget.year, widget.month);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("詳細"),
      ),
      body: Container(
        height: double.infinity,
        child: FutureBuilder(
            future: _getMap(),
            builder: (context, snap) {
              return Consumer(
                builder: (context, watch, child) {
                  items = watch(listProvider).listExpense;
                  if (items != null) {
                    return ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (BuildContext context, index) =>
                            Divider(
                              color: Colors.black,
                            ),
                        itemBuilder: (context, index) {
                          items[index].money > 0
                              ? _money = items[index].money
                              : _money = -items[index].money;
                          //収支のリスト表示
                          return ListTile(
                            leading: Column(
                              children: [
                                items[index].money > 0
                                    ? Text("収入")
                                    : Text(
                                        "支出",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                Text(items[index].day.toString()),
                              ],
                            ),
                            title: Column(
                              children: [
                                Text(items[index].name),
                              ],
                            ),
                            trailing: Text(_money.toString()),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DelUpdPage(data: items[index]))),
                          );
                        });
                  } else {
                    return Center(
                      child: Text("表示するものがありません"),
                    );
                  }
                },
              );
            }),
      ),
    );
  }
}
