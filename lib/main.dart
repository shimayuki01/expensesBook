import 'package:expenses_book_app/add_page.dart';
import 'package:expenses_book_app/month_sum_list.dart';
import 'package:expenses_book_app/provider.dart';
import 'package:expenses_book_app/this_month_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/all.dart';
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

  int _index = 0;

  Widget build(BuildContext context) {
    return Scaffold(

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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _index,
        onTap: (newIndex) {
          setState(() {
            _index = newIndex;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.trending_up), title: Text('今月')),
          BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted), title: Text('過去の履歴')),
        ],
      ),
      body: _index == 0
          ? ThisMonthPage()
          : PastListPage(),
    );
  }
}
