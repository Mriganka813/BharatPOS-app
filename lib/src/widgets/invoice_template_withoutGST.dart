import 'package:shopos/src/models/input/order_input.dart';
import 'package:shopos/src/models/user.dart';

String invoiceTemplatewithouGST(
    {required String companyName,
    required OrderInput order,
    required User user,
    required List<String> headers,
    required String total,
    required DateTime date,
    required String type}) {
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
  String headerRows() => List.generate(
        headers.length,
        (int index) => '<th class="left">${headers[index]}</th>',
      ).join(' ');

  ///
  String itemRows() => List.generate(
        (order.orderItems ?? []).length,
        (index) {
          final orderItem = order.orderItems![index];

          if (type == "OrderType.sale") {
            return '<tr>'
                '<td class="left">${orderItem.product?.name}</td>'
                '<td class="left">${orderItem.quantity}</td>'
                '<td class="left">₹ ${orderItem.product?.sellingPrice ?? 0}</td>'
                '<td class="left">₹ ${(orderItem.quantity) * (orderItem.product?.sellingPrice ?? 1)}</td>'
                '</tr>';
          } else {
            return '<tr>'
                '<td class="left">${orderItem.product?.name}</td>'
                '<td class="left">${orderItem.quantity}</td>'
                '<td class="left">₹ ${orderItem.product?.purchasePrice ?? 0}</td>'
                '<td class="left">₹ ${(orderItem.quantity) * (orderItem.product?.purchasePrice ?? 0)}</td>'
                '</tr>';
          }
        },
      ).join(' ');

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
          <span class="float-right"> <strong>Date:</strong>${dateFormat()}</span>
        </div>
        <div class="card-body">
          <div class="mb-4 row">
            <div class="col-sm-6">
              <h6 class="mb-3">From:</h6>
              <div>
                <strong>$companyName</strong>
              </div>
              ${addressRows()}
              <div>Email: ${user.email ?? ""}</div>
              <div>Phone: ${user.phoneNumber}</div>
            </div>
            <br />
            <br />
            <br />
          </div>

          <div class="table-responsive-sm">
            <table class="table table-striped">
              <thead>
                ${headerRows()}
              </thead>
              <tbody>
                ${itemRows()}
              </tbody>
              <tbody>
                <tr>
                  <td colspan="3" class="left">
                    <strong>Total</strong>
                  </td>
                  <td class="right">
                    <strong>₹ $total</strong>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        <div class="card-footer text-center">Thank you for your business!</div>
      </div>
    </div>
  </body>
</html>

''';
}
