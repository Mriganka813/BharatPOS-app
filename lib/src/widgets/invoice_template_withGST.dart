import 'package:shopos/src/models/input/order_input.dart';
import 'package:shopos/src/models/user.dart';

String invoiceTemplatewithGST({
  required String companyName,
  required OrderInput order,
  required User user,
  required List<String> headers,
  required String total,
  String? subtotal,
  String? gsttotal,
  required DateTime date,
  required String type,
  required String invoiceNum,
}) {
  ///
  String dateFormat() => '${date.day}/${date.month}/${date.year}';

  ///
  String? addressRows() => user.address
      ?.toString()
      .split(',')
      .map((e) => '<div>${e.replaceAll('{', '').replaceAll('}', '')}</div>')
      .toList()
      .join(" ");

  ///
  String headerRows() => List.generate(
        headers.length,
        (int index) => '<th class="left">${headers[index]}</th>',
      ).join(' ');

  ///
  String billedTo() {
    if ((order.reciverName != null && order.reciverName!.isNotEmpty) ||
        (order.businessName != null && order.businessName!.isNotEmpty) ||
        (order.businessAddress != null && order.businessAddress!.isNotEmpty) ||
        (order.gst != null && order.gst!.isNotEmpty)) {
      return '<strong>Billed to: </strong>';
    }
    return '';
  }

  String receiverName() {
    if (order.reciverName != null && order.reciverName!.isNotEmpty) {
      return '<div><strong>Receiver name: </strong>${order.reciverName}</div>';
    }
    return '';
  }

  String businessName() {
    if (order.businessName != null && order.businessName!.isNotEmpty) {
      return ' <div><strong>Business name: </strong>${order.businessName}</div>';
    }
    return '';
  }

  String businessAddress() {
    if (order.businessAddress != null && order.businessAddress!.isNotEmpty) {
      return '<div><strong>Address: </strong>${order.businessAddress}</div>';
    }
    return '';
  }

  String usergstin() {
    if (order.gst != null && order.gst!.isNotEmpty) {
      return '<div><strong>GSTIN: </strong>${order.gst!.toUpperCase()}</div>';
    }
    return '';
  }

  String shopkeepergstin() {
    if (user.GstIN != null && user.GstIN!.isNotEmpty) {
      return '<div> GSTIN ${user.GstIN!.toUpperCase()} </div>';
    }
    return '';
  }

  ///
  String itemRows() => List.generate(
        (order.orderItems ?? []).length,
        (index) {
          final orderItem = order.orderItems![index];
          double baseprice = 0;
          String gstrate = "";

          if (type == "OrderType.sale") {
            if (orderItem.product!.gstRate == "null") {
              baseprice = orderItem.product!.sellingPrice!.toDouble();
              gstrate = "NA";
            } else {
              baseprice = double.parse(orderItem.product!.baseSellingPriceGst!);
              gstrate = orderItem.product!.gstRate!;
            }
            if (gstrate != "NA")
              return '<tr>'
                  '<td class="left">${orderItem.product?.name}</td>'
                  '<td class="left">${orderItem.quantity}</td>'
                  '<td class="left">₹ ${baseprice}</td>'
                  '<td class="left">${orderItem.product?.saleigst}<p style="text-align:left"><small>${gstrate}%</small></p></td>'
                  '<td class="left">₹ ${(orderItem.quantity) * (orderItem.product?.sellingPrice ?? 0)}</td>'
                  '</tr>';
            else {
              return '<tr>'
                  '<td class="left">${orderItem.product?.name}</td>'
                  '<td class="left">${orderItem.quantity}</td>'
                  '<td class="left">₹ ${baseprice}</td>'
                  '<td class="left">NA<p style="text-align:left"><small>NA%</small></p></td>'
                  '<td class="left">₹ ${(orderItem.quantity) * (orderItem.product?.sellingPrice ?? 1)}</td>'
                  '</tr>';
            }
          } else {
            if (orderItem.product!.gstRate == "null" &&
                orderItem.product!.purchasePrice != 0) {
              baseprice = orderItem.product!.purchasePrice.toDouble();
              gstrate = "NA";
            } else if (orderItem.product!.gstRate == "null" &&
                orderItem.product!.purchasePrice == 0) {
              baseprice = 0;
              gstrate = "NA";
            } else if (orderItem.product!.gstRate != "null" &&
                orderItem.product!.purchasePrice != 0) {
              baseprice =
                  double.parse(orderItem.product!.basePurchasePriceGst!);
              gstrate = orderItem.product!.gstRate!;
            } else {
              baseprice = 0;
              gstrate = orderItem.product!.gstRate!;
            }
            if (gstrate != "NA" && baseprice != 0) {
              return '<tr>'
                  '<td class="left">${orderItem.product?.name}</td>'
                  '<td class="left">${orderItem.quantity}</td>'
                  '<td class="left">₹ ${baseprice}</td>'
                  '<td class="left">${orderItem.product?.purchaseigst}<p style="text-align:left"><small>${gstrate}%</small></p></td>'
                  '<td class="left">₹ ${(orderItem.quantity) * (orderItem.product?.purchasePrice ?? 0)}</td>'
                  '</tr>';
            } else if (gstrate != "NA" && baseprice == 0) {
              return '<tr>'
                  '<td class="left">${orderItem.product?.name}</td>'
                  '<td class="left">${orderItem.quantity}</td>'
                  '<td class="left">₹ ${baseprice}</td>'
                  '<td class="left">NA<p style="text-align:left"><small>NA%</small></p></td>'
                  '<td class="left">₹ 0</td>'
                  '</tr>';
            } else {
              return '<tr>'
                  '<td class="left">${orderItem.product?.name}</td>'
                  '<td class="left">${orderItem.quantity}</td>'
                  '<td class="left">₹ ${baseprice}</td>'
                  '<td class="left">NA<p style="text-align:left"><small>NA%</small></p></td>'
                  '<td class="left">₹ ${(orderItem.quantity) * (orderItem.product?.purchasePrice ?? 0)}</td>'
                  '</tr>';
            }
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
    <style>
    .receiver {
              width: 200px;
              height: 100px;
              position: absolute;
              top: 50px;
              right: 0;
              margin: 20px;
            }
    </style>
    <link
      rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.0.0-beta.2/css/bootstrap.css"
    />
  </head>
  <body>
    <div class="container">
      <div class="card">
        <div class="card-header">
          Invoice $invoiceNum
          <span class="float-right"> <strong>Date:</strong>${dateFormat()}</span>
        </div>
        <div class="card-body">
          <div class="mb-4 row">
            <div class="col-sm-6">
              <h6 class="mb-3">From:</h6>
              <div>
                <strong>$companyName</strong>
                ${shopkeepergstin()}
              </div>
              ${addressRows()}
              <div>Email: ${user.email ?? ""}</div>
              <div>Phone: ${user.phoneNumber}</div>
            </div>
            <div class="receiver">
             ${billedTo()}
              ${receiverName()}
              ${businessName()}
              ${businessAddress()}
              ${usergstin()}
              
             
              
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
                <td></td>
                <td></td>
                <td></td>
                  <td class="left">
                    <strong>Sub Total</strong>
                    <br>
                    <strong>GST Total</strong>
                    <br>
                    <strong>Net Total</strong>
                  </td>
                  <td class="right">
                    ₹ $subtotal
                    <br>
                    ₹ $gsttotal
                    <br>
                    ₹ $total
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
