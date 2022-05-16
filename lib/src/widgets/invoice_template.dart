import 'package:magicstep/src/models/input/order_input.dart';

String invoiceTemplate({
  required String companyName,
  required OrderInput order,
  required List<String> headers,
  required String total,
}) {
  return '''
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>DotNetTec - Invoice html template bootstrap</title>
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
          <strong>01/01/2020</strong>
          <span class="float-right"> <strong>Status:</strong> Pending</span>
        </div>
        <div class="card-body">
          <div class="mb-4 row">
            <div class="col-sm-6">
              <h6 class="mb-3">From:</h6>
              <div>
                <strong>$companyName</strong>
              </div>
              <div>Madalinskiego 8</div>
              <div>71-101 Szczecin, Poland</div>
              <div>Email: info@dotnettec.com</div>
              <div>Phone: +91 9800000000</div>
            </div>
            <br/>
            <br/>
            <br/>
          </div>

          <div class="table-responsive-sm">
            <table class="table table-striped">
              <thead>
                ${List.generate(headers.length, (int index) {
    return '<th class="left">${headers[index]}</th>';
  })}
              </thead>
              <tbody>
                
                ${List.generate((order.orderItems ?? []).length, (index) {
    final orderItem = order.orderItems![index];
    return '<tr>'
        '<td class="left">$index</td>'
        '<td class="left">${orderItem.product?.name}</td>'
        '<td class="left">${orderItem.quantity}</td>'
        '<td class="left">${orderItem.product?.sellingPrice}</td>'
        '<td class="right">${(orderItem.quantity) * (orderItem.product?.sellingPrice ?? 1)}</td>'
        '</tr>';
  })}
                <!-- Add rows from here on -->
              </tbody>
            </table>
          </div>
          <div class="row">
            <div class="col-lg-4 col-sm-5"></div>

            <div class="ml-auto col-lg-4 col-sm-5">
              <table class="table table-clear">
                <tbody>
                  <tr>
                    <td class="left">
                      <strong>Total</strong>
                    </td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td class="right">
                      <strong>$total</strong>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  </body>
</html>
''';
}
