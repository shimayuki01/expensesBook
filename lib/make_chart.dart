import 'package:charts_flutter/flutter.dart' as charts;
import 'db_interface.dart';

class MakeMonthChart {
  List<charts.Series> list;

  makeChart(MonthData _data) {
    print(_data);
    list = getData(_data);
    print(list);
    return barChart();
  }

  static List<charts.Series<MonthChartData, String>> getData(MonthData _data) {
    final monthIncomeData = [MonthChartData('収入', _data.income)];


    final monthOutgoData = [MonthChartData('支出', _data.outgo)];
    return [
      charts.Series<MonthChartData, String>(
        id: 'MonthChartData',
        domainFn: (MonthChartData incomeData, _) => incomeData.expense,
        measureFn: (MonthChartData incomeData, _) => incomeData.money,
        data: monthIncomeData,
        fillColorFn: (MonthChartData incomeData, _) {
          return charts.MaterialPalette.green.shadeDefault;
        },
      ),
      charts.Series<MonthChartData, String>(
        id: 'MonthChartData',
        domainFn: (MonthChartData outgoData, _) => outgoData.expense,
        measureFn: (MonthChartData outgoData, _) => outgoData.money,
        data: monthOutgoData,
        fillColorFn: (MonthChartData outgoData, _) {
          return charts.MaterialPalette.red.shadeDefault;
        },
      )
    ];
  }

  barChart() {
    return charts.BarChart(
      list,
      animate: true,
      vertical: false,
    );
  }
}

class Sales {
  final String year;
  final int sales;

  Sales(this.year, this.sales);
}

class MonthChartData {
  final String expense;
  final int money;

  MonthChartData(this.expense, this.money);
}
