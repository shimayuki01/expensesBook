import 'package:expenses_book_app/db_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'main.dart';

class PastListPage extends StatefulWidget {
  @override
  PastList createState() => new PastList();
}
class PastList extends State<PastListPage>{
  List<MonthData> items;

  Future<List<MonthData>> _getMap() async{
    List<MonthData> map = await DbInterface().monthSumList();
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("月別詳細"),
      ),
      body: Container(
        height: double.infinity,
        child: FutureBuilder(
          future: _getMap(),
          builder:( context, snap) {
            print(snap.data);
            items = snap.data;
            return Consumer(builder: (context, watch, child) {
              if (watch(pastMonthProvider).pastMonthSum != null)
                items = watch(pastMonthProvider).pastMonthSum;
              return ListView.builder(
                itemCount: 12,
                itemBuilder: (context, index) {
                  //収支のリスト表示
                  return ListTile(
                    leading: Text('${items[index].year}年　${items[index]
                        .month}月'),
                    title: Column(
                      children: [
                        Text('収入　${items[index].income}'),
                        Text('支出　${items[index].outgo}'),
                      ],
                    ),
                    trailing: Text(items[index].sum.toString()),
                  );
                },
              );
            });
          }
        ),
      ),
    );
  }
}
