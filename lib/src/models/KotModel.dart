

class KotModel
{

 int orderId;
 String name;
 int qty;
 String isPrinted;

 KotModel(this.orderId,this.name,this.qty,this.isPrinted);


 Map<String,dynamic> toMap()
 {
  return {
    'orderId':this.orderId,
    'name':this.name,
    'qty':this.qty,
    'isPrinted':this.isPrinted
  };
 }
 

}