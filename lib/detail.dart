import 'package:expenses_book_app/db_interface.dart';
import 'package:expenses_book_app/del_upd_page.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  @override
  Detail createState() => new Detail();
}

class Detail extends State<DetailPage> {
  List<Expense> items;


  Future<List<Expense>> _getMap() async {
    List<Expense> maps = await DbInterface().expenses();
    return maps;
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
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              items = snapshot.data;
              return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    //収支のリスト表示
                    return ListTile(
                      leading: Column(
                        children: [
                          items[index].money > 0 ? Text("収入") : Text("支出"),
                          Text(items[index].year.toString() +
                              "/" +
                              items[index].month.toString() +
                              "/" +
                              items[index].day.toString()),
                        ],
                      ),
                      title: Column(
                        children: [
                          Text(items[index].name),
                        ],
                      ),
                      trailing: Text(items[index].money.toString()),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DelUpdPage(data: items[index]))),
                    );
                  });
            } else {
              return Column(
                children: [
                  Text("表示するものがありません"),
                ],
              );
            }
          },
        ),
      ),
    );
  }

}

