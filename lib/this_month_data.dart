import 'package:admob_flutter/admob_flutter.dart';
import 'package:expenses_book_app/make_chart.dart';
import 'package:expenses_book_app/services/admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'db_interface.dart';
import 'package:expenses_book_app/main.dart';
import 'detail.dart';

class ThisMonthPage extends StatefulWidget {
  @override
  ThisMonth createState() => new ThisMonth();
}

class ThisMonth extends State<ThisMonthPage> {
  MonthData _monthData;
  int _year = DateTime.now().year;
  int _month = DateTime.now().month;

  Future<void> _init() async {
    await DbInterface().init();
    await context.read(listProvider).getList(_year, _month);
    await context.read(pastMonthProvider).getList();
    await context
        .read(thisMonthProvider)
        .getMonthData(DateTime.now().year, DateTime.now().month);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AdmobBanner(
              adUnitId: AdMobService().getBannerAdUnitId(),
              adSize: AdmobBannerSize(
                width: MediaQuery.of(context).size.width.toInt(),
                height: AdMobService().getHeight(context).toInt(),
                name: 'SMART_BANNER',
              ),
            ),
            Expanded(
              child: FutureBuilder(
                  future: _init(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.done) {
                      return Consumer(builder: (context, watch, child) {
                        if (watch(thisMonthProvider).monthData != null) {
                          _monthData = watch(thisMonthProvider).monthData;
                          return Container(
                            child: ListView(
                              children: <Widget>[
                                ListTile(
                                  title: Text('今月の収入'),
                                  trailing: Text(_monthData.income.toString()),
                                ),
                                ListTile(
                                  title: Text('今月の支出'),
                                  trailing: Text(_monthData.outgo.toString()),
                                ),
                                ListTile(
                                    title: Text('計'),
                                    trailing: Text(
                                      _monthData.sum.toString(),
                                      style: TextStyle(
                                          color: _monthData.sum < 0
                                              ? Colors.red
                                              : Colors.black),
                                    )),
                                ListTile(
                                  title: Container(
                                    height: 150,
                                    child:
                                        MakeMonthChart().makeChart(_monthData),
                                  ),
                                ),
                                ListTile(
                                  title: CupertinoButton(
                                    child: const Text('詳細'),
                                    color: Colors.blue,
                                    onPressed: () async {
                                      //画面遷移（詳細のペ－ジ）
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => DetailPage(
                                                year: _year, month: _month)),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Center(
                            child: Text("データが取得できません\n"
                                "再起動をお試しください"),
                          );
                        }
                      });
                    } else {
                      return Center(child: CupertinoActivityIndicator());
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
