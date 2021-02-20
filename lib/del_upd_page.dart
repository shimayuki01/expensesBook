import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'db_interface.dart';
import 'package:intl/intl.dart';
import 'package:expenses_book_app/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DelUpdPage extends StatefulWidget {
  //Expenseの受け渡し
  final Expense data;

  DelUpdPage({this.data});

  @override
  DelUpd createState() => new DelUpd();
}

class DelUpd extends State<DelUpdPage> {
  Expense _info;
  int _id;
  String _payment;
  DateTime _date;
  DateTime _selectDate = DateTime.now();
  String _name;
  int _money;
  final _formKey = GlobalKey<FormState>();

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

  //初期値を代入
  @override
  void initState() {
    super.initState();
    _info = widget.data;
    _id = _info.id;
    _date = DateTime(_info.year, _info.month, _info.day);
    _name = _info.name;
    if (_info.money > 0) {
      _payment = 'in';
      _money = _info.money;
    } else {
      _payment = 'out';
      _money = -_info.money;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text("データ修正"),
        //ゴミ箱アイコン作成
        trailing: GestureDetector(
            child: Icon(CupertinoIcons.delete),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: Text("削除しますか？"),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: Text("いいえ"),
                        isDestructiveAction: true,
                        onPressed: () => Navigator.pop(context),
                      ),
                      CupertinoDialogAction(
                          child: Text("はい"),
                          isDefaultAction: true,
                          onPressed: () async {
                            await DbInterface().deleteExpense(_id);
                            await context
                                .read(listProvider)
                                .getList(_info.year, _info.month);
                            await context
                                .read(thisMonthProvider)
                                .getMonthData(_date.year, _date.month);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          })
                    ],
                  );
                },
              );
            }),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
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
                              height: MediaQuery.of(context).size.height / 3,
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
                                onDateTimeChanged: (DateTime newDateTime) {
                                  setState(() => _selectDate = newDateTime);
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
            child: Column(children: [
              TextFormField(
                maxLength: 20,
                maxLengthEnforced: true,
                maxLines: 1,
                initialValue: _name,
                validator: (value) {
                  if (value.isEmpty) {
                    return '入力してくだい';
                  }
                  print(value);
                  return null;
                },
                decoration:
                    const InputDecoration(hintText: 'リンゴ、給与', labelText: '名称'),
                onChanged: _handleName,
              ),
              //金額の入力
              TextFormField(
                maxLength: 10,
                maxLengthEnforced: true,
                maxLines: 1,
                initialValue: _money.toString(),
                validator: (value) {
                  if (value.isEmpty) {
                    return '入してください';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                ],
                decoration:
                    const InputDecoration(hintText: '1000', labelText: '金額'),
                onSaved: (String value) {
                  _money = int.parse(value);
                },
              ),
              RaisedButton(
                  child: const Text("更新"),
                  color: Colors.blue,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      showDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: Text("更新しますか？"),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: Text("いいえ"),
                                isDestructiveAction: true,
                                onPressed: () => Navigator.pop(context),
                              ),
                              CupertinoDialogAction(
                                  child: Text("はい"),
                                  isDefaultAction: true,
                                  onPressed: () async {
                                    //更新処理
                                    if (_payment == 'out') {
                                      _money = -_money;
                                    }
                                    var upd = Expense(
                                        id: _id,
                                        year: _date.year,
                                        month: _date.month,
                                        day: _date.day,
                                        name: _name,
                                        money: _money);

                                    await DbInterface().updateExpense(upd);
                                    await context
                                        .read(listProvider)
                                        .getList(_info.year, _info.month);
                                    await context
                                        .read(thisMonthProvider)
                                        .getMonthData(DateTime.now().year,
                                            DateTime.now().month);
                                    await context
                                        .read(pastMonthProvider)
                                        .getList();
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  }),
                            ],
                          );
                        },
                      );
                    } else {
                      print("よくわかんない");
                    }
                  }),
            ]),
          ),
        ]),
      ),
    );
  }
}
