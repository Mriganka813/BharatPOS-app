import 'package:intl/intl.dart';
import 'package:shopos/src/models/order.dart';
import 'package:shopos/src/models/order_item.dart';

String reportsOrderTemplate({
  required List<Order> orders,
}) {
  ///
  String headerRows() {
    // final headers = ['Date', 'Time', 'Party', 'Product', 'Amount', 'Total'];
    final headers = [
      'Date',
      'Time',
      'Party',
      'Product',
      'Amount/Unit',
      'GST Rate/Unit',
      'CGST/Unit',
      'SGST/Unit',
      'GST/Unit',
      'Total',
      'Mode of Payment',
    ];
    return List.generate(
      headers.length,
      (int index) => '<th class="left">${headers[index]}</th>',
    ).join(' ');
  }

  ///
  String itemRows() {
    return orders
        .map((Order e) {
          return (e.orderItems ?? [])
              .map((OrderItem item) {
                final date = DateFormat('dd MMM, yyyy')
                    .format(DateTime.tryParse(e.createdAt)!);
                final time = DateFormat('hh:mm a')
                    .format(DateTime.tryParse(e.createdAt)!);
                return '<tr>'
                    '<td class="left">$date</td>'
                    '<td class="left">$time</td>'
                    '<td class="left">${e.party?.name ?? "N/A"}</td>'
                    '<td class="left">${item.quantity} x ${item.product?.name ?? ""}</td>'
                    '<td class="left">${item.product?.baseSellingPriceGst == "null" ? "N/A" : item.product?.baseSellingPriceGst}</td>'
                    '<td class="left">${item.product?.gstRate == "null" ? "N/A" : item.product?.gstRate}%</td>'
                    '<td class="left">${item.product?.salecgst == "null" ? "N/A" : item.product?.salecgst}</td>'
                    '<td class="left">${item.product?.salesgst == "null" ? "N/A" : item.product?.salesgst}</td>'
                    '<td class="left">${item.product?.saleigst == "null" ? "N/A" : item.product?.saleigst}</td>'
                    '<td class="left">${(item.quantity) * (item.product?.sellingPrice ?? 0)}</td>'
                    '<td class="left">${e.modeOfPayment ?? "N/A"}</td>'
                    '</tr>';
              })
              .toList()
              .join('');
        })
        .toList()
        .join('');
  }

  ///
  String total() {
    return orders.fold<int>(0, (acc, e) => acc += e.total ?? 0).toString();
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
