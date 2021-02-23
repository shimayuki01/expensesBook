import 'package:admob_flutter/admob_flutter.dart';
import 'package:expenses_book_app/services/admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'db_interface.dart';
import 'main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddPage extends StatefulWidget {
  @override
  Add createState() => new Add();
}

class Add extends State<AddPage> {
  String _payment = 'out';
  DateTime _date = DateTime.now();
  DateTime _selectDate = DateTime.now();
  String _name = '';
  int _money = 0;
  int _id;
  final _formKey = GlobalKey<FormState>();

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

  // //idのインクリメント
  // void _handleId() {
  //   setState(() {
  //     _id++;
  //   });
  // }

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
                    AdmobBanner(
                      adUnitId: AdMobService().getBannerAdUnitId(),
                      adSize: AdmobBannerSize(
                        width: MediaQuery.of(context).size.width.toInt(),
                        height: AdMobService().getHeight(context).toInt(),
                        name: 'SMART_BANNER',
                      ),
                    ),
                    //収支のラジオボタン
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          color: _payment == "in" ? Colors.green : null,
                          child: RadioListTile(
                              title: Text('収入'),
                              value: 'in',
                              activeColor: Colors.green,
                              groupValue: _payment,
                              onChanged: _onChanged),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          color: _payment == "out" ? Colors.red : null,
                          child: RadioListTile(
                              title: Text('支出'),
                              value: 'out',
                              activeColor: Colors.red,
                              groupValue: _payment,
                              onChanged: _onChanged),
                        ),
                      ],
                    ),

                    //日付の入力
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 10,
                      child: FlatButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('日付'),
                              Text(
                                _date.year.toString() +
                                    '/' +
                                    _date.month.toString() +
                                    '/' +
                                    _date.day.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 30,
                                ),
                              ),
                            ],
                          ),
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
                                            setState(() =>
                                                _selectDate = newDateTime);
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                });
                          }),
                    ),

                    //名称の入力
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            maxLength: 20,
                            maxLengthEnforced: true,
                            maxLines: 1,
                            validator: (value) {
                              if (value.isEmpty) {
                                return '入力してください';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                                hintText: 'リンゴ、給与', labelText: '名称'),
                            onChanged: _handleName,
                          ),
                          //金額の入力
                          TextFormField(
                            maxLength: 10,
                            maxLengthEnforced: true,
                            maxLines: 1,
                            validator: (value) {
                              if (value.isEmpty) {
                                return '入力してください';
                              }
                              return null;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]'))
                            ],
                            decoration: const InputDecoration(
                                hintText: '1000', labelText: '金額'),
                            onSaved: (String value) {
                              _money = int.parse(value);
                            },
                          ),
                          CupertinoButton(
                              child: const Text("追加"),
                              color: Colors.blue,
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();
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
                                  await context
                                      .read(thisMonthProvider)
                                      .getMonthData(DateTime.now().year,
                                          DateTime.now().month);
                                  await context
                                      .read(pastMonthProvider)
                                      .getList();
                                  Navigator.pop(context);
                                }
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              );
              // } else {
              //   return Center(child: CupertinoActivityIndicator());
              // }
            }));
  }
}
