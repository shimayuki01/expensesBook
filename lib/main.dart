import 'package:expenses_book_app/add_page.dart';
import 'package:expenses_book_app/db_interface.dart';
import 'package:expenses_book_app/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/all.dart';
import 'dart:async';
import 'detail.dart';
import 'package:flutter/widgets.dart';

final listProvider = ChangeNotifierProvider(
  (ref) => DbListReload(),
);

void main() {
  runApp(ProviderScope(child:MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
  @override
  Expense test1 =
      Expense(id: 1, year: 2021, month: 1, day: 7, name: "fafdaf", money: -300);

  void initState() {
    super.initState();
    Future(() async {
      await DbInterface().delDb();
      DbInterface().init();
      await Future.delayed((Duration(seconds: 1)));
      await DbInterface().insertExpense(test1);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 150),
        child: Container(
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text('今月の支出'),
                trailing: Text('sumout'),
              ),
              ListTile(
                title: Text('今月の収入'),
                trailing: Text('sumin'),
              ),
              ListTile(
                title: Container(
                  width: 50,
                  child: RaisedButton(
                    child: const Text('詳細'),
                    color: Colors.lightBlue,
                    shape: const StadiumBorder(),
                    onPressed: () async {
                      //画面遷移（詳細のペ－ジ）
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DetailPage()),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //画面遷移（追加のページ）
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Add_page()),
          );
        },
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
