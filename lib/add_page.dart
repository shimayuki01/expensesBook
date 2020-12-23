import 'package:flutter/material.dart';

class Add_page extends StatefulWidget {
  @override
  Add createState() => new Add();
}

class Add extends State<Add_page> {
  String _payment = 'out';

  void _onChanged(String payment) => setState(() {
        _payment = payment;
      });

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
        ],
      ),
    );
  }
}
