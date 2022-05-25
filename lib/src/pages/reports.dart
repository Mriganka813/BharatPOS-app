import 'dart:io';

import 'package:flutter/material.dart';
import 'package:magicstep/src/models/expense.dart';
import 'package:magicstep/src/widgets/custom_button.dart';
import 'package:magicstep/src/widgets/custom_text_field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class ReportsPage extends StatefulWidget {
  static const String routeName = '/reports_page';
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  void createPdf() async {
    final pdf = pw.Document();
    final header = ['Header', "Description", "Mode of payment", "Amount"];
    final List<Expense> expenses = [
      Expense(
        header: "This company",
        description: "Company phone",
        amount: 2000,
        modeOfPayment: "Cash",
      ),
      Expense(
        header: "This company",
        description: "Company phone",
        amount: 2000,
        modeOfPayment: "Cash",
      ),
      Expense(
        header: "This company",
        description: "Company phone",
        amount: 2000,
        modeOfPayment: "Cash",
      ),
      Expense(
        header: "This company",
        description: "Company phone",
        amount: 2000,
        modeOfPayment: "Cash",
      ),
      Expense(
        header: "This company",
        description: "Company phone",
        amount: 2000,
        modeOfPayment: "Cash",
      ),
    ];
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a6,
        build: (pw.Context context) {
          return pw.Container(
            color: PdfColor.fromHex("#ffffff"),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Row(
                  children: [
                    pw.Text(""),
                  ],
                ),
                pw.Table(
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Container(
                          color: PdfColor.fromHex("#F0AD3C"),
                          child: pw.Text("ID"),
                        ),
                        ...List.generate(
                          header.length,
                          (index) => pw.Container(
                            color: PdfColor.fromHex("#F0AD3C"),
                            child: pw.Text(header[index]),
                          ),
                        ),
                      ],
                    ),
                    ...List.generate(
                      expenses.length,
                      (index) {
                        final expense = expenses[index];
                        return pw.TableRow(
                          children: [
                            pw.Container(
                              color: PdfColor.fromHex("#F0AD3C"),
                              child: pw.Text("$index"),
                            ),
                            pw.Container(
                              color: PdfColor.fromHex("#F0AD3C"),
                              child: pw.Text(expense.header ?? ""),
                            ),
                            pw.Container(
                              color: PdfColor.fromHex("#F0AD3C"),
                              child: pw.Text(expense.description ?? ""),
                            ),
                            pw.Container(
                              color: PdfColor.fromHex("#F0AD3C"),
                              child: pw.Text(expense.modeOfPayment ?? ""),
                            ),
                            pw.Container(
                              color: PdfColor.fromHex("#F0AD3C"),
                              child: pw.Text("${expense.amount ?? 0}"),
                            ),
                          ],
                        );
                      },
                    ),

                    // [
                    //   ...[
                    //     'Description',
                    //     'Qty',
                    //     'Unit Price',
                    //     'Amount',
                    //   ].map(
                    //     (e) {
                    //       return pw.Container(
                    //         color: PdfColor.fromHex("#F0AD3C"),
                    //         child: pw.Text(e),
                    //       );
                    //     },
                    //   ),
                    // ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    final Directory? dir = await getTemporaryDirectory();
    final file = File("${dir?.path}/example.pdf");
    final output = await file.writeAsBytes(await pdf.save()); //
    await Permission.storage.request();
    // Navigator.pushNamed(context, PdfPreviewPage.routeName,
    // arguments: output.path);
    // launchUrlString("file://${output.path}");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('Reports')),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.all(0),
                onChanged: (value) {},
                title: const Text("Sale Report"),
              ),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onChanged: (value) {},
                contentPadding: const EdgeInsets.all(0),
                title: const Text("Purchase Report"),
              ),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.all(0),
                onChanged: (value) {},
                title: const Text("Income Report"),
              ),
              CheckboxListTile(
                contentPadding: const EdgeInsets.all(0),
                controlAffinity: ListTileControlAffinity.leading,
                value: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onChanged: (value) {},
                title: const Text("Expense Report"),
              ),
              const SizedBox(height: 40),
              CustomTextField(
                label: "Start Date",
                onChanged: (value) {},
                hintText: "dd/mm/yyyy",
              ),
              const Divider(color: Colors.transparent),
              CustomTextField(
                label: "End Date",
                hintText: "dd/mm/yyyy",
                onChanged: (value) {},
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
                      onTap: () {},
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
}
