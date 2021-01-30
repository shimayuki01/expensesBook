import 'package:admob_flutter/admob_flutter.dart';
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
  }

  Future<MonthData> _getData() async {
    MonthData aa = await DbInterface().monthSum(_year, _month);
    return aa;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // AdmobBanner(
            //   adUnitId: AdMobService().getBannerAdUnitId(),
            //   adSize: AdmobBannerSize(
            //     width: MediaQuery.of(context).size.width.toInt(),
            //     height: AdMobService().getHeight(context).toInt(),
            //     name: 'SMART_BANNER',
            //   ),
            // ),

            Expanded(
              child: FutureBuilder(
                  future: _init(),
                  builder: (context, ddd) {
                    return FutureBuilder(
                        future: _getData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.data != null) {
                              _monthData = snapshot.data;
                              return Consumer(builder: (context, watch, child) {
                                if (watch(thisMonthProvider).monthData != null)
                                  _monthData =
                                      watch(thisMonthProvider).monthData;
                                return Container(
                                  child: ListView(
                                    children: <Widget>[
                                      ListTile(
                                        title: Text('今月の支出'),
                                        trailing:
                                            Text(_monthData.outgo.toString()),
                                      ),
                                      ListTile(
                                        title: Text('今月の収入'),
                                        trailing:
                                            Text(_monthData.income.toString()),
                                      ),
                                      ListTile(
                                        title: Text('計'),
                                        trailing:
                                            Text(_monthData.sum.toString()),
                                      ),
                                      ListTile(
                                        title: Container(
                                          width: 50,
                                          child: RaisedButton(
                                            child: const Text('詳細'),
                                            color: Colors.blue,
                                            shape: const StadiumBorder(),
                                            onPressed: () async {
                                              //画面遷移（詳細のペ－ジ）
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailPage(
                                                            year: _year,
                                                            month: _month)),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                            } else {
                              return Text("error");
                            }
                          } else {
                            return Center(child: CupertinoActivityIndicator());
                          }
                        });
                  }),
            )
          ],
        ),
      ),
    );
  }
}
