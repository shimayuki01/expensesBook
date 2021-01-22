import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
        appBar: AppBar(
          title: Text("追加ページ"),
        ),
        body: FutureBuilder(
            future: _setMaxId(),
            builder: (context, snapshot) {
              _id = snapshot.data;
              return SingleChildScrollView(
                child: Column(
                  children: [
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
                    IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            locale: const Locale('ja'),
                            initialDate: _date,
                            firstDate: DateTime(DateTime.now().year - 1),
                            lastDate: DateTime(DateTime.now().year + 1),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              _date = selectedDate;
                              //_handleDate();
                            });
                          }
                        }),

                    //日付の表示
                    Text(
                      DateFormat('yyyy年M月d日').format(_date),
                      style: TextStyle(fontSize: 25),
                    ),
                    Text('$_id'),

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
            }));
  }
}
