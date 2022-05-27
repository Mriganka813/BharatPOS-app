import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:magicstep/src/models/expense.dart';
import 'package:magicstep/src/widgets/custom_button.dart';
import 'package:magicstep/src/widgets/custom_datePicker.dart';
import 'package:magicstep/src/widgets/custom_text_field.dart';
import 'package:path_provider/path_provider.dart';

class ReportsPage extends StatefulWidget {
  static const String routeName = '/reports_page';
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  void createPdf() async {
    // final Directory? dir = await getTemporaryDirectory();
    // final file = File("${dir?.path}/example.pdf");
    // final output = await file.writeAsBytes(await pdf.save()); //
    // await Permission.storage.request();
    // Navigator.pushNamed(context, PdfPreviewPage.routeName,
    //     arguments: output.path);
    // launchUrlString("file://${output.path}");
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
    final targetPath = await getTemporaryDirectory();
    const targetFileName = "example_pdf_file";
    // final htmlContent = invoiceTemplate(
    //   companyName: "Sharma city mart",
    //   products: expenses,
    //   headers: ["ID", "Name", "Description", "Mode of payment", "Amt"],
    //   total: "2000",
    // );
    // final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
    //   htmlContent,
    //   targetPath.path,
    //   targetFileName,
    // );
    // OpenFile.open(generatedPdfFile.path);

    // launchUrlString('file://${generatedPdfFile.path}');
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
            // CustomTextField(
            //   label: "Start Date",
            //   onChanged: (value) {},
            //   hintText: "dd/mm/yyyy",
            // ),
            // const Divider(color: Colors.transparent),
            // CustomTextField(
            //   label: "End Date",
            //   hintText: "dd/mm/yyyy",
            //   onChanged: (value) {},
            // ),
            CustomDatePicker(
              "Start Date",
              (e) {
                print(e);
              },
              (e) {},
              (e) {
                return e.toString();
              },
            ),
            const Divider(color: Colors.transparent),
            CustomDatePicker(
              "End Date",
              (e) {
                print(e);
              },
              (e) {},
              (e) {
                return e.toString();
              },
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
    );
  }
}
