import 'package:intl/intl.dart';
import 'package:shopos/src/models/input/order.dart';
import 'package:shopos/src/models/user.dart';

String smallKotTemplate({
  required User user,
  required Order order,
  required List<String> headers,
  required DateTime date,
  required String invoiceNum,
  required String totalPrice,
  required String subtotal,
  required String gstTotal,
}) {
  ///
  String dateFormat() => DateFormat('dd/MM/yy').format(date);

  List<String>? addressRows() => user.address
      ?.toString()
      .split(',')
      .map((e) =>
          '${e.replaceAll('{', '').replaceAll('}', '').replaceAll('[', '').replaceAll(']', '').replaceAll(',', '').replaceAll('locality:', '').replaceAll('city:', '').replaceAll('state:', '').replaceAll('country:', '')}')
      .toList();

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

          return '<tbody>'
              '<td>${orderItem.quantity}</td>'
              '<td>${orderItem.product!.name}</td>'
              '<td>${orderItem.product!.sellingPrice}</td>'
              '</tbody>';
        },
      ).join(' ');

  ///
  return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
<div class = "kot">
    <center><p><h2>${user.businessName}</h2> ${addressRows()!.elementAt(0)}<br> ${addressRows()!.elementAt(1)} <br> ${addressRows()!.elementAt(2)} <br> ${addressRows()!.elementAt(3)} <br> ${user.phoneNumber}</p></center>
    <center><div class="bill">
        <table>
            <tbody>
                <td>Invoice&nbsp;&nbsp;</td>
                <td>$invoiceNum</td>
                <td>${dateFormat()}</td>
            </tbody>
            <tbody>
                <td></td>
                <td></td>
                <td>${invoiceNum.substring(8, 10)}:${invoiceNum.substring(10, 12)}</td>
            </tbody>
            ${itemRows()}
            
        </table>
        <hr>
        <table>
            <tbody>
                <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                <td>Subtotal&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                <td>$subtotal</td>
            </tbody>
            <tbody>
                <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                <td>GST&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                <td>$gstTotal</td>
            </tbody>
        </table>
        <hr>
        <table>
            <tbody>
                <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                <td>Grand Total&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                <td>$totalPrice</td>
            </tbody>
        </table>
        <hr>
        <table>
            <tbody>
                <td>Thank You and see you again. &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                
            </tbody>
            
            
        </table>
        
       
    </div></center></div>
</body>
</html>

''';
}
