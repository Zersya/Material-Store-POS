import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/material.dart';
import 'package:harco_app/models/transaction.dart';
import 'package:harco_app/screens/transactionReport/transactionReport_bloc.dart';
import 'package:harco_app/utils/commonFunc.dart';
import 'package:harco_app/utils/enum.dart';
import 'package:harco_app/widgets/curTransaction.dart';

class TransactionReportScreen extends StatefulWidget {
  TransactionReportScreen({Key key}) : super(key: key);

  @override
  _TransactionReportScreenState createState() =>
      _TransactionReportScreenState();
}

class _TransactionReportScreenState extends State<TransactionReportScreen> {
  ScrollController _scrollController = ScrollController();
  TransactionReportBloc _reportBloc = TransactionReportBloc();

  @override
  void initState() {
    super.initState();
    _reportBloc.fetchTransactionAll();
    _reportBloc.fetchExpenseAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                children: <Widget>[
                  Card(
                    margin:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 32),
                    elevation: 2,
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      width: double.infinity,
                      child: Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 100.0,
                        children: <Widget>[
                          StreamBuilder<String>(
                            stream: _reportBloc.timeSelectStream,
                            initialData: 'semua',
                            builder: (context, snapshot) {
                              return DropdownButton(
                                value: snapshot.data,
                                isExpanded: true,
                                hint: Text('Pilih Waktu'),
                                onChanged: (val) {
                                  _reportBloc.subjectTimeSelect.sink.add(val);
                                  _reportBloc.getDateTime();
                                },
                                items: [
                                  DropdownMenuItem(
                                    value: '1 minggu',
                                    child: Text('Minggu ini'),
                                  ),
                                  DropdownMenuItem(
                                    value: '1 bulan',
                                    child: Text('1 Bulan Terakhir'),
                                  ),
                                  DropdownMenuItem(
                                    value: '3 bulan',
                                    child: Text('3 Bulan Terakhir'),
                                  ),
                                  DropdownMenuItem(
                                    value: '1 tahun',
                                    child: Text('1 Tahun Terakhir'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'semua',
                                    child: Text('Seluruh Data'),
                                  ),
                                ],
                              );
                            },
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          InformationTime(reportBloc: _reportBloc)
                        ],
                      ),
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 2,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary),
                      child: StreamBuilder<Map<String, dynamic>>(
                          stream: _reportBloc.subjectTimeMap,
                          initialData: {
                            'start': DateTime(2019),
                            'end': DateTime.now()
                          },
                          builder: (context, snapshot) {
                            DateTime start = snapshot.data['start'];

                            return StreamBuilder<List<Transaction>>(
                                stream: _reportBloc.transStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data.length > 0) {
                                    List<Map<String, dynamic>> list = List();
                                    _reportBloc.transStream.value
                                        .forEach((val) {
                                      Map<String, dynamic> map = {
                                        'value': val.profit.toDouble(),
                                        'date':
                                            DateTime.fromMillisecondsSinceEpoch(
                                                val.createdAt)
                                      };
                                      list.add(map);
                                    });
                                    return lineChart(context, start, list);
                                  }
                                  return Container();
                                });
                          }),
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Container(
                    width: double.infinity,
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          StreamBuilder<String>(
                              stream: _reportBloc.subjectTimeSelect,
                              builder: (context, snapshot) {
                                return Text(
                                  'Total Profit ${_reportBloc.subjectTimeSelect.value}',
                                  style: Theme.of(context).textTheme.title,
                                );
                              }),
                          Divider(
                            height: 32.0,
                            color: Colors.black,
                          ),
                          StreamBuilder<String>(
                              stream: _reportBloc.subjectIncome,
                              initialData: '0',
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    fmf
                                        .copyWith(
                                            amount: double.parse(snapshot.data))
                                        .output
                                        .symbolOnLeft,
                                    style: Theme.of(context).textTheme.title,
                                  );
                                }
                                return Container();
                              }),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Container(
                    width: double.infinity,
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          StreamBuilder<String>(
                              stream: _reportBloc.subjectTimeSelect,
                              builder: (context, snapshot) {
                                return Text(
                                  'Total Pengeluaran ${_reportBloc.subjectTimeSelect.value}',
                                  style: Theme.of(context).textTheme.title,
                                );
                              }),
                          Divider(
                            height: 32.0,
                            color: Colors.black,
                          ),
                          StreamBuilder<String>(
                              stream: _reportBloc.subjectExpense,
                              initialData: '0',
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    fmf
                                        .copyWith(
                                            amount: double.parse(snapshot.data))
                                        .output
                                        .symbolOnLeft,
                                    style: Theme.of(context).textTheme.title,
                                  );
                                }
                                return Container();
                              }),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  CurTransaction(
                    title: 'Transaksi',
                    scrollController: _scrollController,
                    bloc: _reportBloc,
                  )
                ],
              ),
            ),
            StreamBuilder<ViewState>(
                stream: _reportBloc.stateStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data == ViewState.LOADING)
                      return Center(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.black54,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                  }
                  return Container();
                })
          ],
        ),
      ),
    );
  }

  Widget lineChart(BuildContext context, DateTime start, List data) {
    final fromDate = start;
    final toDate = DateTime.now();

    return BezierChart(
      fromDate: fromDate,
      bezierChartScale: BezierChartScale.WEEKLY,
      toDate: toDate,
      selectedDate: toDate,
      series: [
        BezierLine(
          label: "Profit",
          data: data
              .map((val) =>
                  DataPoint<DateTime>(value: val['value'], xAxis: val['date']))
              .toList(),
        ),
      ],
      config: BezierChartConfig(
        verticalIndicatorStrokeWidth: 3.0,
        verticalIndicatorColor: Colors.black26,
        showVerticalIndicator: true,
        verticalIndicatorFixedPosition: false,
        pinchZoom: true,
        displayLinesXAxis: false,
        showDataPoints: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        footerHeight: 50.0,
      ),
    );
  }
}

class InformationTime extends StatelessWidget {
  const InformationTime({
    Key key,
    @required TransactionReportBloc reportBloc,
  })  : _reportBloc = reportBloc,
        super(key: key);

  final TransactionReportBloc _reportBloc;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: _reportBloc.timeStartStream,
        initialData: '',
        builder: (context, snapshot) {
          if (snapshot.data.isEmpty) return Container();

          DateTime dt = DateTime.now();
          String custTime =
              '${dt.day} ${numberToStrMonth(dt.month)} ${dt.year}';
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Tanggal Mulai',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle
                        .copyWith(color: Colors.grey[500]),
                  ),
                  Divider(
                    height: 16,
                    color: Colors.transparent,
                  ),
                  Text(
                    snapshot.data,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle
                        .copyWith(color: Colors.grey[500]),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Tanggal Selesai',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle
                        .copyWith(color: Colors.grey[500]),
                  ),
                  Divider(
                    height: 16,
                    color: Colors.transparent,
                  ),
                  Text(
                    custTime,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle
                        .copyWith(color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          );
        });
  }
}
