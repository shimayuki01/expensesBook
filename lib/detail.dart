import 'package:expenses_book_app/db_interface.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  @override
  Detail createState() => new Detail();
}

class Detail extends State<DetailPage> {
  List<Expense> items;

  void _getMap() async {
    List<Expense> maps = await dbInterface().expenses();
    items = maps;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future(() async {
      _getMap();
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
        child: FutureBuilder(
          future: _getMapLength(),
          builder: (context, snapshot) {
            return ListView.builder(
              itemCount: snapshot.data,
              itemBuilder: (context, index) {
                //収支のリスト表示
                if (items != null) {
                  return ListTile(
                    leading: items[index].money > 0 ? Text("収入") : Text("支出"),
                    title: Column(
                      children: [
                        Text(items[index].name),
                        Text(items[index].month.toString() +
                            "/" +
                            items[index].day.toString()),
                      ],
                    ),
                    trailing: Text(items[index].money.toString()),
                  );
                } else {
                  return Text("表示するものがありません");
                }
              },
            );
          },
        ),
      ),
    );
  }

  Future<int> _getMapLength() async {
    List<Expense> maps = await dbInterface().expenses();
    return maps.length;
  }
}




















