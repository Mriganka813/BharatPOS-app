import 'package:intl/intl.dart';
import 'package:shopos/src/models/expense.dart';

String reportsExpenseTemplate({
  required List<Expense> expenses,
}) {
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
        .fold<double>(0, (acc, ele) => acc + (ele.amount ?? 0))
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
        <div class="card-body">
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
      </div>
    </div>
  </body>
</html>
  ''';
}
