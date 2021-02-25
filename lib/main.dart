import 'package:admob_flutter/admob_flutter.dart';
import 'package:expenses_book_app/add_page.dart';
import 'package:expenses_book_app/db_interface.dart';
import 'package:expenses_book_app/month_sum_list.dart';
import 'package:expenses_book_app/provider.dart';
import 'package:expenses_book_app/this_month_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:expenses_book_app/services/JapaneseCupertinoLocalizations.dart'
    as jcl;

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
  WidgetsFlutterBinding.ensureInitialized();
  Admob.initialize();
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
        DefaultCupertinoLocalizations.delegate,
        jcl.JapaneseCupertinoLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('ja', 'JP'),
      ],
      locale: Locale('ja', 'JP'),
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
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  Future<void> _deletingDB() async {
    await DbInterface().delDb();
    await context
        .read(thisMonthProvider)
        .getMonthData(DateTime.now().year, DateTime.now().month);
    await context.read(pastMonthProvider).getList();
  }

  Future<void> _deleteAlert() async {
    return await showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
              title: Text("全てのデータを削除しますか？"),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text("いいえ"),
                  isDefaultAction: true,
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoDialogAction(
                  child: Text("はい"),
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                              title: Text("本当によろしいですか？"),
                              content: Text("データを削除すると復元することができません"),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                    child: Text("いいえ"),
                                    isDefaultAction: true,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                                CupertinoDialogAction(
                                  child: Text("はい"),
                                  isDestructiveAction: true,
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return FutureBuilder(
                                            future: _deletingDB(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.done) {
                                                return CupertinoAlertDialog(
                                                  title: Text("データを削除しました"),
                                                  actions: [
                                                    CupertinoDialogAction(
                                                        child: Text("OK"),
                                                        isDefaultAction: true,
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        })
                                                  ],
                                                );
                                              } else {
                                                return CupertinoAlertDialog(
                                                    title: Container(
                                                        height: 100,
                                                        width: 50,
                                                        child:
                                                            CupertinoActivityIndicator()));
                                              }
                                            },
                                          );
                                        });
                                  },
                                )
                              ]);
                        });
                  },
                )
              ]);
        });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: CupertinoNavigationBar(
          middle: _index == 0 ? Text("今月の収支") : Text("過去の履歴"),
          trailing: GestureDetector(
              child: Icon(CupertinoIcons.settings),
              onTap: () {
                _key.currentState.openEndDrawer();
              })),
      endDrawer: Container(
        width: MediaQuery.of(context).size.width / 2,
        child: Drawer(
          child: ListView(
            children: [
              Container(
                color: Colors.blue,
                child: ListTile(
                  title: Text('オプション'),
                ),
              ),
              ListTile(
                title: Text(
                  'データの全削除',
                  style: TextStyle(color: Colors.red),
                ),
                trailing: Icon(
                  CupertinoIcons.delete,
                  color: Colors.red,
                ),
                onTap: _deleteAlert,
              ),
              // ListTile(
              //   title: Text(
              //     'お問い合わせ',
              //   ),
              //   trailing: Icon(
              //     CupertinoIcons.mail,
              //   ),
              //)
            ],
          ),
        ),
      ),
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
      body: _index == 0 ? ThisMonthPage() : PastListPage(),
    );
  }
}
