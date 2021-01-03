import 'package:expenses_book_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'db_interface.dart';

class del_upd_page extends StatefulWidget {
  @override
  //idの受け渡し
  final int id;

  const del_upd_page({Key key, this.id}) : super(key: key);

  delUpd createState() => new delUpd();
}

class delUpd extends State<del_upd_page> {
  Expense info = dbInterface().data(id);
  String _payment = info.payment;
  DateTime _Date = DateTime(info.year, info.month, info.day);
  String _name = info.name;
  int _money = info.money;

  int get id => null;

  //収支の切り替え
  void _onChanged(String payment) => setState(() {
        _payment = payment;
      });

  //名称の変更
  void _handleName(String name) {
    setState(() {
      _name = name;
    });
    print('$_name');
  }

//金額の変更
  void _handleMoney(String money) {
    setState(() {
      _money = int.parse(money);
    });
    print('$_money');
  }

  // void _handleDate(){
  //    _year = _Date.year;
  //    _monrh = _Date.month;
  //    _day = _Date.day;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("修正ページ"),
            //ゴミ箱アイコン作成
            actions: [
              IconButton(icon: Icon(Icons.delete), onPressed: dbInterface().deleteExpense(id);Navigator.pop();),
            ]),
        body: Column(
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
                    initialDate: _Date,
                    firstDate: DateTime(DateTime.now().year - 1),
                    lastDate: DateTime(DateTime.now().year + 1),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _Date = selectedDate;
                      //_handleDate();
                    });
                  }
                }),

            //日付の表示
            Text(
              DateFormat('yyyy年M月d日').format(_Date),
              style: TextStyle(fontSize: 25),
            ),

            //名称の入力
            new TextField(
              maxLength: 20,
              maxLengthEnforced: true,
              maxLines: 1,
              decoration:
                  const InputDecoration(hintText: '入力してください', labelText: '名称'),
              onChanged: _handleName,
            ),

            //金額の入力
            new TextField(
              maxLength: 7,
              maxLengthEnforced: true,
              maxLines: 1,
              inputFormatters: [
                WhitelistingTextInputFormatter(RegExp(r'[0-9]'))
              ],
              decoration:
                  const InputDecoration(hintText: '入力してください', labelText: '金額'),
              onChanged: _handleMoney,
            ),
            RaisedButton(
                child: const Text("追加"),
                color: Colors.blue,
                onPressed: () async {
                  //追加処理
                  var upd = Expense(
                      id: _id,
                      payment: _payment,
                      year: _Date.year,
                      month: _Date.month,
                      day: _Date.day,
                      name: _name,
                      money: _money);

                  await dbInterface().updateExpense(upd);
                }),
          ],
        ));
  }
}
