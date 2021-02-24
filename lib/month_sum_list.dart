import 'package:expenses_book_app/db_interface.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'detail.dart';
import 'main.dart';

class PastListPage extends StatefulWidget {
  @override
  PastList createState() => new PastList();
}

class PastList extends State<PastListPage> {
  List<MonthData> items;

  Future<void> _getMap() async {
    await context.read(pastMonthProvider).getList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        child: FutureBuilder(
            future: _getMap(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.done) {
                return Consumer(builder: (context, watch, child) {
                  if (watch(pastMonthProvider).pastMonthSum != null)
                    items = watch(pastMonthProvider).pastMonthSum;
                  return ListView.separated(
                    itemCount: items.length + 1,
                    separatorBuilder: (BuildContext context, index) => Divider(
                      color: Colors.black,
                    ),
                    itemBuilder: (context, index) {
                      if (index < items.length) {
                        //収支のリスト表示
                        return ListTile(
                          leading: Text(
                              '${items[index].year}年　${items[index].month}月'),
                          title: Column(
                            children: [
                              Text('収入　${items[index].income}'),
                              Text('支出　${items[index].outgo}'),
                            ],
                          ),
                          trailing: Text(items[index].sum.toString()),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailPage(
                                      year: items[index].year,
                                      month: items[index].month)),
                            );
                          },
                        );
                      } else {
                        return Container(height: 70, child: Text(""));
                      }
                    },
                  );
                });
              } else {
                return Center(child: CupertinoActivityIndicator());
              }
            }),
      ),
    );
  }
}
