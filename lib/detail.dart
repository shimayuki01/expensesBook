import 'package:flutter/material.dart';

class Detail extends StatelessWidget {
  final items = List<String>.generate(10000, (i) => "Item $i");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("詳細"),
      ),
      body: Container(
        height: double.infinity,
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Text("支出"),
              title: Text('${items[index]}'),
              trailing: Text("money"),
            );
          },
        ),
      ),
    );
  }
}
