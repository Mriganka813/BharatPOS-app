import 'package:magicstep/src/models/product.dart';

String invoiceTemplate({
  required String companyName,
  required List<Product> products,
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
          <div class="row mb-4">
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
            <div class="col-sm-6">
              <h6 class="mb-3">To:</h6>
              <div>
                <strong>Robert Maxwel</strong>
              </div>
              <div>Attn: Daniel Marek</div>
              <div>43-190 Mikolow, Poland</div>
              <div>Email: robert@daniel.com</div>
              <div>Phone: +48 123 456 349</div>
            </div>
          </div>

          <div class="table-responsive-sm">
            <table class="table table-striped">
              <tr>
                ${headers.map((e) => '''
                  <th class="left">$e</th>
                ''')}
              </tr>
              <tbody>
                
                ${List.generate(products.length, (index) => '''<tr>
                  <td class="left">$index</td>
                  <td class="left">${products[index].name}</td>
                  <td class="left">${products[index].purchaseQuantity}</td>
                  <td class="left">${products[index].sellingPrice}</td>
                  <td class="right">${products[index].purchaseQuantity * (products[index].sellingPrice ?? 1)}</td>
                </tr>''')}
                <!-- Add rows from here on -->
              </tbody>
            </table>
          </div>
          <div class="row">
            <div class="col-lg-4 col-sm-5"></div>

            <div class="col-lg-4 col-sm-5 ml-auto">
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
