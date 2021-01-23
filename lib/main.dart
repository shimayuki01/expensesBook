import 'package:expenses_book_app/add_page.dart';
import 'package:expenses_book_app/db_interface.dart';
import 'package:expenses_book_app/month_sum_list.dart';
import 'package:expenses_book_app/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/all.dart';
import 'dart:async';
import 'detail.dart';
import 'package:flutter/widgets.dart';

final listProvider = ChangeNotifierProvider(
  (ref) => DbListReload(),
);
final thisMonthProvider = ChangeNotifierProvider(
  (ref) => ThisMonthReload(),
);
final pastMonthProvider = ChangeNotifierProvider(
  (ref) => PastSumData(),
);

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: CupertinoPageTransitionsBuilder(), // iOS風
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: MyHomePage(title: '家計簿アプリ'),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale("en"),
        const Locale("ja"),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
      bottomNavigationBar: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.trending_up), title: Text('今月')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.format_list_bulleted), title: Text('過去の履歴')),
            ],
          ),
          tabBuilder: (context, index) {
            if (index == 0) {
              return FutureBuilder(
                  future: _init(),
                  builder: (context, ddd) {
                    return FutureBuilder(
                        future: _getData(),
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            _monthData = snapshot.data;
                            return Consumer(builder: (context, watch, child) {
                              if (watch(thisMonthProvider).monthData != null)
                                _monthData = watch(thisMonthProvider).monthData;
                              return Padding(
                                padding: const EdgeInsets.only(top: 150),
                                child: Container(
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
                                ),
                              );
                            });
                          } else {
                            return Text("era");
                          }
                        });
                  });
            } else {
              return PastListPage();
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //画面遷移（追加のページ）
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPage()),
          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
