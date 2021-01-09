import 'package:expenses_book_app/db_interface.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  @override
  Detail createState() => new Detail();
}

class Detail extends State<DetailPage> {
  List<Expense> items;

  void _getMap() async {
    List<Expense> maps = await dbInterface().expenses();
    items = maps;
    print(items[0]);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future(() async {
      _getMap();
    });
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("詳細"),
      ),
      body: Container(
        height: double.infinity,
        child: FutureBuilder(
          future: _getMapLength(),
          builder: (context,snapshot){
            return ListView.builder(
              itemCount: snapshot.data,
              itemBuilder: (context, index) {
                //収支のリスト表示
                return ListTile(
                  leading: Text("支出"),
                  title: items != null ? Text("${items[index]}") : Text(""),
                  trailing: Text("maps.length is " + snapshot.data.toString()),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<int> _getMapLength() async {
    List<Expense> maps = await dbInterface().expenses();
    return maps.length;
  }
}
