import 'package:expenses_book_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Add_page extends StatefulWidget {
  @override
  Add createState() => new Add();
}

class Add extends State<Add_page> {
  String _payment = 'out';

  //var selectedDate = DateTime.now();
  String _Date = (DateFormat.yMd()).format(DateTime.now());
  String _name = '';
  String _money = '';

  void _onChanged(String payment) => setState(() {
        _payment = payment;
      });

  void _handleName(String name) {
    setState(() {
      _name = name;
    });
    print('$_name');
  }

  void _handleMoney(String money) {
    setState(() {
      _money = money;
    });
    print('$_money');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("追加ページ"),
        ),
        body: Column(
          children: [
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
            IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    locale: const Locale('ja'),
                    initialDate: DateTime.now(),
                    firstDate: DateTime(DateTime.now().year - 1),
                    lastDate: DateTime(DateTime.now().year + 1),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _Date = DateFormat.yMd().format(selectedDate);
                    });
                  }
                }),
            Text(
              "$_Date",
              style: TextStyle(fontSize: 25),
            ),
            new TextField(
              maxLength: 20,
              maxLengthEnforced: true,
              maxLines: 1,
              decoration:
                  const InputDecoration(hintText: '入力してください', labelText: '名称'),
              onChanged: _handleName,
            ),
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
          ],
        ));
  }
}
