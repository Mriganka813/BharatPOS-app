import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopos/src/blocs/report/report_cubit.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/models/input/report_input.dart';
import 'package:shopos/src/pages/pdf_preview.dart';
import 'package:shopos/src/pages/report_table.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/services/pdf.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/custom_date_picker.dart';

import '../widgets/custom_icons.dart';

enum ReportType { sale, purchase, expense, stock }

class ReportsPage extends StatefulWidget {
  static const String routeName = '/reports_page';
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ReportInput _reportInput = ReportInput();
  final _formKey = GlobalKey<FormState>();
  late final PdfService _pdfService;
  late final ReportCubit _reportCubit;
  bool _showLoader = false;

  ///
  @override
  void initState() {
    super.initState();
    _reportCubit = ReportCubit();
    _pdfService = PdfService();
  }

  ///
  @override
  void dispose() {
    _reportCubit.close();
    super.dispose();
  }

  ///
  void _toggleReportType(ReportType type) {
    setState(() {
      _reportInput.type == type
          ? _reportInput.type = null
          : _reportInput.type = type;
    });
  }

  void _handleReportsView(ReportsView state) async {
    if (state.expenses != null) {
      Navigator.pushNamed(context, ReportTable.routeName,
          arguments: tableArg(
              expenses: state.expenses, type: _reportInput.type.toString()));
    }
    if (state.orders != null) {
      Navigator.pushNamed(context, ReportTable.routeName,
          arguments: tableArg(
              orders: state.orders!, type: _reportInput.type.toString()));
    }
    if (state.product != null) {
      Navigator.pushNamed(context, ReportTable.routeName,
          arguments: tableArg(
              products: state.product, type: _reportInput.type.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Shopos'),
      ),
      body: BlocListener<ReportCubit, ReportState>(
        bloc: _reportCubit,
        listener: (context, state) async {
          if (_showLoader) {
            Navigator.pop(context);
          }
          setState(() {
            _showLoader = false;
          });

          /// View
          if (state is ReportsView) {
            _handleReportsView(state);
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: 220,
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Color.fromARGB(255, 232, 232, 232)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 25),
                        child: const Icon(
                          CustomIcons.report_svg,
                          size: 25,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          "Report",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 25),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: 700,
                  height: 400,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    // color: Color.fromARGB(255, 236, 236, 236),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            new Flexible(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CheckboxListTile(
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      value:
                                          _reportInput.type == ReportType.sale,
                                      activeColor: ColorsConst.primaryColor,
                                      checkboxShape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      contentPadding: const EdgeInsets.all(0),
                                      onChanged: (value) {
                                        _toggleReportType(ReportType.sale);
                                      },
                                      title: const Text("Sale Report"),
                                    ),
                                    CheckboxListTile(
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      value: _reportInput.type ==
                                          ReportType.purchase,
                                      activeColor: ColorsConst.primaryColor,
                                      checkboxShape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (value) {
                                        _toggleReportType(ReportType.purchase);
                                      },
                                      contentPadding: const EdgeInsets.all(0),
                                      title: const Text("Purchase Report"),
                                    ),
                                    CheckboxListTile(
                                      contentPadding: const EdgeInsets.all(0),
                                      activeColor: ColorsConst.primaryColor,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      value: _reportInput.type ==
                                          ReportType.expense,
                                      checkboxShape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (value) {
                                        _toggleReportType(ReportType.expense);
                                      },
                                      title: const Text("Expense Report"),
                                    ),
                                    CheckboxListTile(
                                      contentPadding: const EdgeInsets.all(0),
                                      activeColor: ColorsConst.primaryColor,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      value:
                                          _reportInput.type == ReportType.stock,
                                      checkboxShape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (value) {
                                        _toggleReportType(ReportType.stock);
                                      },
                                      title: const Text("Stock Report"),
                                    ),
                                  ]),
                            ),
                            VerticalDivider(endIndent: 40, indent: 40),
                            new Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    height: 60,
                                  ),
                                  new Flexible(
                                    child: CustomDatePicker(
                                      label: 'Start date',
                                      hintText: 'dd/mm/yyyy',
                                      onChanged: (DateTime value) {
                                        setState(() {
                                          _reportInput.startDate = value;
                                        });
                                      },
                                      onSave: (DateTime? value) {
                                        setState(() {
                                          _reportInput.startDate = value;
                                        });
                                      },
                                      validator: (DateTime? value) {
                                        if (value == null &&
                                            _reportInput.type !=
                                                ReportType.stock) {
                                          return 'Please select start date';
                                        }
                                        return null;
                                      },
                                      value: _reportInput.startDate,
                                    ),
                                  ),
                                  new Flexible(
                                    child: CustomDatePicker(
                                      hintText: 'dd/mm/yyyy',
                                      label: 'End date',
                                      onChanged: (DateTime value) {
                                        setState(() {
                                          _reportInput.endDate = value;
                                        });
                                      },
                                      onSave: (DateTime? value) {
                                        setState(() {
                                          _reportInput.endDate = value;
                                        });
                                      },
                                      validator: (DateTime? value) {
                                        if (value == null &&
                                            _reportInput.type !=
                                                ReportType.stock) {
                                          return 'Please select end date';
                                        }
                                        return null;
                                      },
                                      value: _reportInput.endDate,
                                    ),
                                  ),
                                  const Divider(color: Colors.transparent),
                                  //const Spacer(),
                                  CustomButton(
                                    title: "View",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        ?.copyWith(
                                            color: Colors.white, fontSize: 18),
                                    onTap: () {
                                      _onSubmit();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_reportInput.type == null) {
        locator<GlobalServices>().errorSnackBar("Please select a report type");
        return;
      }
      setState(() {
        _showLoader = true;
      });
      locator<GlobalServices>().showBottomSheetLoader();
      _reportCubit.getReport(_reportInput);
    }
  }
}
