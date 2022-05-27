import 'package:flutter/material.dart';
import 'package:magicstep/src/config/colors.dart';
import 'package:magicstep/src/services/global.dart';
import 'package:magicstep/src/services/locator.dart';
import 'package:magicstep/src/widgets/custom_button.dart';
import 'package:magicstep/src/widgets/custom_date_picker.dart';

enum ReportType { sale, purchase, expense }

class ReportsPage extends StatefulWidget {
  static const String routeName = '/reports_page';
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ReportInput _reportInput = ReportInput();
  final _formKey = GlobalKey<FormState>();

  void createPdf() async {}

  void _toggleReportType(ReportType type) {
    setState(() {
      _reportInput.type == type
          ? _reportInput.type = null
          : _reportInput.type = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: _reportInput.type == ReportType.sale,
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
                controlAffinity: ListTileControlAffinity.leading,
                value: _reportInput.type == ReportType.purchase,
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
                controlAffinity: ListTileControlAffinity.leading,
                value: _reportInput.type == ReportType.expense,
                checkboxShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (value) {
                  _toggleReportType(ReportType.expense);
                },
                title: const Text("Expense Report"),
              ),
              const SizedBox(height: 40),
              CustomDatePicker(
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
                  if (value == null) {
                    return 'Please select start date';
                  }
                  return null;
                },
                value: _reportInput.startDate,
              ),
              const Divider(color: Colors.transparent),
              CustomDatePicker(
                hintText: 'dd/mm/yyyy',
                label: 'End date',
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
                  if (value == null) {
                    return 'Please select end date';
                  }
                  return null;
                },
                value: _reportInput.endDate,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      title: "View",
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          ?.copyWith(color: Colors.white, fontSize: 18),
                      onTap: () {
                        createPdf();
                      },
                    ),
                  ),
                  const VerticalDivider(),
                  Expanded(
                    child: CustomButton(
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.white, fontSize: 18),
                      title: "Download",
                      onTap: () {
                        _onSubmit();
                      },
                    ),
                  ),
                ],
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
    }
  }
}

class ReportInput {
  ReportInput({
    this.startDate,
    this.endDate,
    this.type,
  });

  DateTime? startDate;
  DateTime? endDate;
  ReportType? type;

  Map<String, dynamic> toMap() => {
        "start_date": startDate.toString(),
        "end_date": endDate.toString(),
        "type": type.toString(),
      };
}
