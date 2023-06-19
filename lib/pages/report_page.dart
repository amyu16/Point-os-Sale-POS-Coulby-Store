import 'package:flutter/material.dart';
import 'package:end/models/report_model.dart';
import 'package:end/helpers/db_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<Report> reports = [];
  DateTime selectedDate = DateTime.now();
  String selectedMonth = DateFormat.MMMM().format(DateTime.now());

  final String boxesIco = 'assets/boxes.svg';
  final String creditIco = 'assets/credit.svg';

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    DBHelper dbHelper = DBHelper();
    List<Report> loadedReports = await dbHelper.getReport();
    setState(() {
      reports = loadedReports;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _onMonthChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        selectedMonth = newValue;
      });
    }
  }

  // Mendapatkan total item terjual pada bulan yang dipilih
  int getTotalItems() {
    int totalItems = 0;
    for (Report report in reports) {
      DateTime reportDate = DateFormat.yMd().parse(report.timestamp);
      int reportMonth = reportDate.month;
      String reportMonthName = DateFormat.MMMM().format(reportDate);
      if (reportMonth == selectedDate.month &&
          reportMonthName == selectedMonth) {
        totalItems += report.totalItems;
      }
    }
    return totalItems;
  }

  // Mendapatkan total pendapatan pada bulan yang dipilih
  double getTotalIncome() {
    double totalIncome = 0;
    for (Report report in reports) {
      DateTime reportDate = DateFormat.yMd().parse(report.timestamp);
      int reportMonth = reportDate.month;
      String reportMonthName = DateFormat.MMMM().format(reportDate);
      if (reportMonth == selectedDate.month &&
          reportMonthName == selectedMonth) {
        totalIncome += report.totalPrice;
      }
    }
    return totalIncome;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 246, 252, 1),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 15, bottom: 15),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(132, 181, 255, 0.2),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 3), // atur posisi shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: DropdownButton<String>(
                        value: selectedMonth,
                        onChanged: _onMonthChanged,
                        items: <String>[
                          'January',
                          'February',
                          'March',
                          'April',
                          'May',
                          'June',
                          'July',
                          'August',
                          'September',
                          'October',
                          'November',
                          'December'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        borderRadius: BorderRadius.circular(7),
                        style: TextStyle(
                            fontSize: 12, color: Color.fromRGBO(0, 42, 110, 1)),
                        underline: Container(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 80,
                    width: 160,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(132, 181, 255, 0.2),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 3), // atur posisi shadow
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Color.fromRGBO(199, 255, 185, 1)),
                            height: 40,
                            width: 40,
                            child: Transform.scale(
                                scale: 0.7,
                                child: SvgPicture.asset(
                                  creditIco,
                                  color: Color.fromRGBO(15, 185, 0, 1),
                                ))),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Incomes',
                              style: TextStyle(
                                  color: Color.fromRGBO(0, 42, 110, 1)),
                            ),
                            Text(
                              '${getTotalIncome()} K',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color.fromRGBO(0, 42, 110, 1)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Container(
                    height: 80,
                    width: 160,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(132, 181, 255, 0.2),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 3), // atur posisi shadow
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Color.fromRGBO(255, 205, 217, 1)),
                          height: 40,
                          width: 40,
                          child: Transform.scale(
                              scale: 0.7,
                              child: SvgPicture.asset(boxesIco,
                                  color: Color.fromRGBO(255, 111, 145, 1))),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Items',
                              style: TextStyle(
                                  color: Color.fromRGBO(0, 42, 110, 1)),
                            ),
                            Text(
                              '${getTotalItems()}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color.fromRGBO(0, 42, 110, 1)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(132, 181, 255, 0.2),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 3), // atur posisi shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        DataTable(columns: [DataColumn(label: Text('Transactions'))], rows: []),
                        DataTable(
                          columnSpacing: 20,
                          columns: [
                            DataColumn(
                              label: Text(
                                'No',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(0, 42, 110, 1)),
                                textAlign: TextAlign.center,
                              ),
                              numeric: true,
                            ),
                            DataColumn(
                              label: Text(
                                'Total Items',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(0, 42, 110, 1)),
                                textAlign: TextAlign.center,
                              ),
                              numeric: true,
                            ),
                            DataColumn(
                              label: Text(
                                'Total Price',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(0, 42, 110, 1)),
                                textAlign: TextAlign.center,
                              ),
                              numeric: true,
                            ),
                            DataColumn(
                              label: Text(
                                '       Date',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(0, 42, 110, 1)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                          rows: reports
                              .where((report) {
                                DateTime reportDate =
                                    DateFormat.yMd().parse(report.timestamp);
                                int reportMonth = reportDate.month;
                                String reportMonthName =
                                    DateFormat.MMMM().format(reportDate);
                                return reportMonth == selectedDate.month &&
                                    reportMonthName == selectedMonth;
                              })
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                                int index = entry.key + 1;
                                Report report = entry.value;

                                return DataRow(cells: [
                                  DataCell(
                                    Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        index.toString(),
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(0, 42, 110, 1)),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        report.totalItems.toString(),
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(0, 42, 110, 1)),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${report.totalPrice}K',
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(0, 42, 110, 1)),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${report.timestamp}',
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(0, 42, 110, 1)),
                                      ),
                                    ),
                                  ),
                                ]);
                              })
                              .toList(),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
