import 'package:expenses_book_app/add_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'detail.dart';
import 'package:flutter/widgets.dart';

//データベースに格納するクラス作成
class Expense {
  final int id;
  final int year;
  final int month;
  final int day;
  final String payment; //収支判別
  final String name;
  final String money;

  Expense({this.id,
      this.payment,
      this.year,
      this.month,
      this.day,
      this.name,
      this.money});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'payment': payment,
      'year': year,
      'month': month,
      'day': day,
      'name': name,
      'money': money,
    };
  }

  @override
  String toString() {
    return 'Expense{id: $id, payment: $payment, year: $year, month: $month, day: $day, name: $name, money: $money}';
  }
}

void main() async {
  //データベース作成（初期化）
  WidgetsFlutterBinding.ensureInitialized();
  final Future<Database> database = openDatabase(
    join(await getDatabasesPath(), 'expenses_database.db'),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE expenses(id INTEGER PRIMARY KEY, payment TEXT,  year Integer, month Integer, day Integer, name Text, money Integer)",
      );
    },
    version: 1,
  );

    runApp(MyApp());
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
                    onPressed: () {
                      //画面遷移（詳細のペ－ジ）
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Detail()),
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
