import 'package:admob_flutter/admob_flutter.dart';
import 'package:expenses_book_app/services/admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'db_interface.dart';
import 'main.dart';
import 'package:flutter_riverpod/all.dart';

class AddPage extends StatefulWidget {
  @override
  Add createState() => new Add();
}

class Add extends State<AddPage> {
  String _payment = 'out';
  DateTime _date = DateTime.now();
  DateTime _selectDate;
  String _name = '';
  int _money = 0;
  int _id;

  Future<int> _setMaxId() async {
    return await DbInterface().getMaxId();
  }

  //収支の切り替え
  void _onChanged(String payment) => setState(() {
        _payment = payment;
      });

  //名称の変更
  void _handleName(String name) {
    setState(() {
      _name = name;
    });
  }

//金額の変更
  void _handleMoney(String money) {
    setState(() {
      _money = int.parse(money);
    });
  }

  //idのインクリメント
  void _handleId() {
    setState(() {
      _id++;
    });
  }

  void initState() {
    super.initState();
    Future(() async {
      await _setMaxId();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CupertinoNavigationBar(
          middle: Text("データ追加"),
        ),
        body: FutureBuilder(
            future: _setMaxId(),
            builder: (context, snapshot) {
              //if (snapshot.connectionState == ConnectionState.done) {
              _id = snapshot.data;
              return SingleChildScrollView(
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
                    //収支のラジオボタン
                    RadioListTile(
                        title: Text('収入'),
                        value: 'in',
                        groupValue: _payment,
                        onChanged: _onChanged),
                    RadioListTile(
                        title: Text('支出'),
                        value: 'out',
                        groupValue: _payment,
                        onChanged: _onChanged),

                    //日付の入力
                    FlatButton(
                        child: Text(_date.year.toString() +
                            '/' +
                            _date.month.toString() +
                            '/' +
                            _date.day.toString()),
                        textColor: Colors.black,
                        onPressed: () {
                          showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext context) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xffffffff),
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Color(0xff999999),
                                            width: 0.0,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CupertinoButton(
                                              child: Text('キャンセル'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                            CupertinoButton(
                                              child: Text('完了'),
                                              onPressed: () {
                                                setState(() {
                                                  _date = _selectDate;
                                                });
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ]),
                                    ),
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              3,
                                      decoration: BoxDecoration(
                                        color: Color(0xffffffff),
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Color(0xff999999),
                                            width: 0.0,
                                          ),
                                        ),
                                      ),
                                      child: CupertinoDatePicker(
                                        mode: CupertinoDatePickerMode.date,
                                        initialDateTime: _date,
                                        onDateTimeChanged:
                                            (DateTime newDateTime) {
                                          setState(
                                              () => _selectDate = newDateTime);
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              });
                        }),

                    //名称の入力
                    TextField(
                      maxLength: 20,
                      maxLengthEnforced: true,
                      maxLines: 1,
                      decoration: const InputDecoration(
                          hintText: '入力してください', labelText: '名称'),
                      onChanged: _handleName,
                    ),

                    //金額の入力
                    TextField(
                      maxLength: 7,
                      maxLengthEnforced: true,
                      maxLines: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                      ],
                      decoration: const InputDecoration(
                          hintText: '1000', labelText: '金額'),
                      onChanged: _handleMoney,
                    ),
                    RaisedButton(
                        child: const Text("追加"),
                        color: Colors.blue,
                        onPressed: () async {
                          //追加処理
                          if (_payment == 'out') {
                            _money = -_money;
                          }
                          Expense add = Expense(
                              id: _id,
                              year: _date.year,
                              month: _date.month,
                              day: _date.day,
                              name: _name,
                              money: _money);
                          await DbInterface().insertExpense(add);
                          _handleId();
                          await context.read(thisMonthProvider).getMonthData(
                              DateTime.now().year, DateTime.now().month);
                          Navigator.pop(context);
                        }),
                  ],
                ),
              );
              // } else {
              //   return Center(child: CupertinoActivityIndicator());
              // }
            }));
  }
}
