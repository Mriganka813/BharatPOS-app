import 'package:intl/intl.dart';
import 'package:shopos/src/models/input/order.dart';
import 'package:shopos/src/models/user.dart';

String invoiceTemplatewithGST({
  required String companyName,
  required Order order,
  required User user,
  required List<String> headers,
  required String total,
  bool? convertToSale,
  String? dlNum,
  String? subtotal,
  String? gsttotal,
  required String date,
  required String type,
  String? invoiceNum,
}) {
  ///
  // String dateFormat() => '${date.day}/${date.month}/${date.year}';
  String dateFormat(){
    if(date != "null" && date!= ""&& convertToSale==false){
      date = date.substring(0, 10);
      DateTime dateTime = DateTime.parse(date);
      String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
      return formattedDate;
    }else{
      DateTime dateTime = DateTime.now();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
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
  String userdlNum() {
    if ( dlNum != null && dlNum!="") {
      return '<div><strong>DL Number: </strong>${dlNum}</div>';
    }
    return '';
  }

  String shopkeepergstin() {


         bool atleastOneItemhaveGST = false;
      print("Value OF GST");
      order.orderItems!.forEach((element) {
        print(element.product!.gstRate);
        if (element.product!.gstRate != "null") {
          atleastOneItemhaveGST = true;
        }
      });
    if (user.GstIN != null && user.GstIN!.isNotEmpty&&atleastOneItemhaveGST) {
      return '<div> GSTIN ${user.GstIN!.toUpperCase()} </div>';
    }
    return '';
  }

  bool expirydateAvailableFlag = false;
  bool hsnAvailableFlag = false;
  bool mrpAvailableFlag=false;
  order.orderItems!.forEach((element) {
    if (element.product!.expiryDate != null &&
        element.product!.expiryDate != "null" &&
        element.product!.expiryDate != "") {
      expirydateAvailableFlag = true;
    }
    if (element.product!.hsn != null &&
        element.product!.hsn != "null" &&
        element.product!.hsn != "") {
      hsnAvailableFlag = true;
    }
    if (element.product!.mrp != null &&
        element.product!.mrp != "null" &&
        element.product!.mrp != "") {
      mrpAvailableFlag = true;
    }
  });

  ///
  String itemRows() => List.generate(
        (order.orderItems ?? []).length,
        (index) {
          final orderItem = order.orderItems![index];
          double baseprice = 0;
          String gstrate = "";

          if (type == "OrderType.sale" || type == "OrderType.estimate" || type == "OrderType.saleReturn") {
            if (orderItem.product!.gstRate == "null") {
              baseprice = orderItem.product!.sellingPrice!.toDouble();
              gstrate = "NA";
            } else {
              baseprice = double.parse(orderItem.product!.baseSellingPriceGst!);
              gstrate = orderItem.product!.gstRate!;
            }
            if (gstrate != "NA")
              return '<tr>'
                      '<td class="left product-name">${orderItem.product?.name}</td>'
                      '<td class="left">${orderItem.quantity}</td>' +
                  (expirydateAvailableFlag
                      ? orderItem.product!.expiryDate != null
                          ? '<td class="left">${orderItem.product!.expiryDate!.day}/${orderItem.product!.expiryDate!.month}/${orderItem.product!.expiryDate!.year}</td>'
                          : '<td class="left"> </td>'
                      : '') +
                  (hsnAvailableFlag
                      ? orderItem.product!.hsn != null
                          ? '<td class="left"> ${orderItem.product!.hsn}</td>'
                          : '<td class="left"></td>'
                      : '') +
                  (mrpAvailableFlag
                      ? orderItem.product!.mrp != null
                        ? '<td class="left"> ${orderItem.product!.mrp!="null"?orderItem.product!.mrp :''}</td>'
                        : '<td class="left"></td>'
                      : '') +
                  '<td class="left">₹ ${baseprice.toStringAsFixed(2)}</td>'
                      '<td class="left">${orderItem.product?.saleigst}<p style="text-align:left"><small>(${gstrate}%)</small></p></td>'
                      '<td class="left">₹ ${((orderItem.quantity) * (orderItem.product?.sellingPrice ?? 0)).toStringAsFixed(2)}</td>'
                      '</tr>';
            else {
              print("llll");
              print(hsnAvailableFlag);
              return '<tr>'
                      '<td class="left product-name">${orderItem.product?.name}</td>'
                      '<td class="left">${orderItem.quantity}</td>'+
                     
                  (expirydateAvailableFlag
                      ? orderItem.product!.expiryDate != null
                          ? '<td class="left">${orderItem.product!.expiryDate!.day}/${orderItem.product!.expiryDate!.month}/${orderItem.product!.expiryDate!.year}</td>'
                          : '<td class="left"></td>'
                      : '') +
                  (hsnAvailableFlag
                      ? orderItem.product!.hsn != null
                          ? '<td class="left"> ${orderItem.product!.hsn}</td>'
                          : '<td class="left"></td>'
                      : '') +
                  (mrpAvailableFlag
                      ? orderItem.product!.mrp != null
                      ? '<td class="left"> ${orderItem.product!.mrp!="null"?orderItem.product!.mrp :''}</td>'
                      : '<td class="left"></td>'
                      : '') +
                       '<td class="left">₹ ${baseprice.toStringAsFixed(2)}</td>' +
                  '<td class="left">NA<p style="text-align:left"><small>(NA%)</small></p></td>'
                      '<td class="left">₹ ${((orderItem.quantity) * (orderItem.product?.sellingPrice ?? 1)).toStringAsFixed(2)}</td>'
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
                  '<td class="left product-name">${orderItem.product?.name}</td>'
                  '<td class="left">${orderItem.quantity}</td>'
                  '<td class="left">${mrpAvailableFlag? orderItem.product?.mrp : ''}</td>'
                  '<td class="left">₹ ${baseprice.toStringAsFixed(2)}</td>'
                  '<td class="left">${orderItem.product?.purchaseigst}<p style="text-align:left"><small>(${gstrate}%)</small></p></td>'
                  '<td class="left">₹ ${((orderItem.quantity) * (orderItem.product?.purchasePrice ?? 0)).toStringAsFixed(2)}</td>'
                  '</tr>';
            } else if (gstrate != "NA" && baseprice == 0) {
              return '<tr>'
                  '<td class="left product-name">${orderItem.product?.name}</td>'
                  '<td class="left">${orderItem.quantity}</td>'
                  '<td class="left">${mrpAvailableFlag?orderItem.product?.mrp : ''}</td>'
                  '<td class="left">₹ ${baseprice.toStringAsFixed(2)}</td>'
                  '<td class="left">NA<p style="text-align:left"><small>(NA%)</small></p></td>'
                  '<td class="left">₹ 0</td>'
                  '</tr>';
            } else {
              return '<tr>'
                  '<td class="left product-name">${orderItem.product?.name}</td>'
                  '<td class="left">${orderItem.quantity}</td>'
                  '<td class="left">${mrpAvailableFlag? orderItem.product?.mrp:''}</td>'
                  '<td class="left">₹ ${baseprice.toStringAsFixed(2)}</td>'
                  '<td class="left">NA<p style="text-align:left"><small>(NA%)</small></p></td>'
                  '<td class="left">₹ ${((orderItem.quantity) * (orderItem.product?.purchasePrice ?? 0)).toStringAsFixed(2)}</td>'
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
      
      .table td.product-name {
        white-space: normal;
      }
      .table {
        width: 100%;
      }
      .table th, .table td {
        white-space: nowrap;
      }
      tbody {
        font-size: 13px;
      }
      .receiver {
              width: 250px;
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
          $invoiceNum
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
              <div>DL Number: ${user.dlNum}</div>
            </div>
            <div class="receiver">
             ${billedTo()}
              ${receiverName()}
              ${businessName()}
              ${businessAddress()}
              ${usergstin()}
              ${userdlNum()}
              
             
              
              
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
                ${headers.contains("HSN")?"<td></td>":""}
                ${headers.contains("Expiry")?"<td></td>":""}
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
