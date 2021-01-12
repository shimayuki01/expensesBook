import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'db_interface.dart';
import 'package:intl/intl.dart';

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
  String _name;
  int _money;

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
    // TODO: implement initState
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
      appBar: AppBar(title: Text("修正ページ"),
          //ゴミ箱アイコン作成
          actions: [
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await DbInterface().deleteExpense(_id);
                  Navigator.pop(context);
                }),
          ]),

      body: SingleChildScrollView(
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

            //名称の入力
            TextFormField(
              maxLength: 20,
              maxLengthEnforced: true,
              maxLines: 1,
              initialValue: _name,
              decoration:
                  const InputDecoration(hintText: '入力してください', labelText: '名称'),
              onChanged: _handleName,
            ),

            //金額の入力
            TextFormField(
              maxLength: 7,
              maxLengthEnforced: true,
              maxLines: 1,
              initialValue: _money.toString(),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
              ],
              decoration:
                  const InputDecoration(hintText: '入力してください', labelText: '金額'),
              onChanged: _handleMoney,
            ),
            RaisedButton(
                child: const Text("更新"),
                color: Colors.blue,
                onPressed: () async {
                  //更新処理
                  var upd = Expense(
                      id: _id,
                      year: _date.year,
                      month: _date.month,
                      day: _date.day,
                      name: _name,
                      money: _money);

                  await DbInterface().updateExpense(upd);
                }),
          ],
        ),
      ),
    );
  }
}
