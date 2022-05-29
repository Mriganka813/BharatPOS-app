import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:magicstep/src/models/expense.dart';
import 'package:magicstep/src/models/user.dart';
import 'package:magicstep/src/services/user.dart';

Future<String> reportsExpenseTemplate({
  required List<Expense> expenses,
}) async {
  final Response res = await UserService.me();
  final user = User.fromMap(res.data['user']);
  final DateTime date = DateTime.now();

  ///
  String dateFormat() => '${date.day}/${date.month}/${date.year}';

  ///
  String? addressRows() => user.address
      ?.toString()
      .split(',')
      .map((e) => '<div>$e</div>')
      .toList()
      .join(" ");

  ///
  String headerRows() {
    final headers = [
      'Date',
      'Time',
      'Header',
      'Description',
      'M.O.P',
      'Amount'
    ];
    return List.generate(
      headers.length,
      (int index) => '<th class="left">${headers[index]}</th>',
    ).join(' ');
  }

  ///
  String itemRows() {
    return List.generate(
      expenses.length,
      (index) {
        final expense = expenses[index];
        final date = DateFormat('dd MMM, yyyy').format(expense.createdAt!);
        final time = DateFormat('hh:mm a').format(expense.createdAt!);
        return '<tr>'
            '<td class="left">$date</td>'
            '<td class="left">$time</td>'
            '<td class="left">${expense.header}</td>'
            '<td class="left">${expense.description}</td>'
            '<td class="left">${expense.modeOfPayment}</td>'
            '<td class="left">${expense.amount}</td>'
            '</tr>';
      },
    ).join(' ');
  }

  ///
  String total() {
    return expenses
        .fold<int>(0, (acc, ele) => acc + (ele.amount ?? 0))
        .toString();
  }

  ///
  return '''
  <!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Shopos - Invoice</title>
    <link
      rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.0.0-beta.2/css/bootstrap.css"
    />
  </head>
  <body>
    <div class="container">
      <div class="card">
        <div class="card-header">
          Invoice
          <span class="float-right">
            <strong>Date:</strong>&nbsp;${dateFormat()}</span
          >
        </div>
        <div class="card-body">
          <div class="mb-4 row">
            <div class="col-sm-6">
              <h6 class="mb-3">From:</h6>
              <div>
                <strong>${user.businessName ?? ""}</strong>
              </div>
              ${addressRows()}
              <div>Email: ${user.email ?? ""}</div>
              <div>Phone: ${user.phoneNumber ?? ""}</div>
            </div>
            <br />
            <br />
            <br />
          </div>

          <div class="table-responsive-sm">
            <table class="table table-striped">
              <thead>
                <tr>
                  ${headerRows()}
                </tr>
              </thead>
              <tbody>
                ${itemRows()}
              </tbody>
              <tbody>
                <tr>
                  <td colspan="5" class="left">
                    <strong>Total</strong>
                  </td>
                  <td class="right">
                    <strong>${total()}</strong>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        <div class="text-center card-footer">Thank you for your business!</div>
      </div>
    </div>
  </body>
</html>
  ''';
}
