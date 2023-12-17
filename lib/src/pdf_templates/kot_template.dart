import 'package:intl/intl.dart';
import 'package:shopos/src/models/input/order.dart';
import 'package:shopos/src/models/user.dart';

String kotTemplate({
  required Order order,
  required List<String> headers,
  required DateTime date,
}) {
  ///
  String dateFormat() => DateFormat('MMM d, y hh:mm:ss a').format(date);

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

          return '<tr>'
              '<td class="textContainer">${orderItem.product?.name}</td>'
              '<td class="left">${orderItem.quantity}</td>'
              '</tr>';
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
            .container {
                width: 80mm;
            }

            .dashes {
                position: relative;
            }

            .dashes::before {
                content: '';
                position: absolute;
            }

            .dateformat {
              
                font-size: 35px;
            }

            td.textContainer {
                white-space: normal;
           text-overflow: ellipsis;
           word-wrap: break-word;
            overflow: hidden;
            text-wrap: wrap;
                max-width: 70mm;
               

            }
        </style>
    
        <link
          rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.0.0-beta.2/css/bootstrap.css"
        />
      </head>
      <body>
        <div class="container">
          <div class = "dateformat">
            <div >
              <center>KOT</center>
              <center>${dateFormat()}</center>
            </div>
            <div class="card-body">
              <div class="mb-4 row">
                <div class="col-sm-6">
                  <div><center>Table</center></div>
                  
                </div>
              </div>
    
              <div class="table-responsive-sm">
                <table class="table table-striped">
                  <thead>
                    <center aria-expanded="true">${headerRows()}</center>
                  </thead>
              
                  <tbody>
                    ${itemRows()}
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
