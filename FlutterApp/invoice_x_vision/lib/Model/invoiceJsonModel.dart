
class InvoiceJSON {

  String date;
  String time;
  String total;
  String CompanyName;
  String GSTNumber;
  String email;
  String PhoneNumber;
  String InvoiceNumber;
  String currency;

InvoiceJSON({this.date, this.time, this.total, this.CompanyName, this.GSTNumber, this.email, this.PhoneNumber, this.InvoiceNumber, this.currency});

  factory InvoiceJSON.fromJSON(dynamic json){

    InvoiceJSON invJson = new InvoiceJSON(
      date: "${json['date']}",
      time: "${json['time']}",
      total: "${json['total']}",
      CompanyName: "${json['CompanyName']}",
      GSTNumber: "${json['GSTNumber']}",
      email: "${json['email']}",
      // PhoneNumber: "${json['PhoneNumber']}",
      PhoneNumber: json['PhoneNumber'],
      InvoiceNumber: "${json['InvoiceNumber']}",
      currency: "${json['currency']}",
    );
    print("Inside Model");
    return invJson;
  }

  Map toJson() => {
    "date": date,
    "time": time,
    "total": total,
    "CompanyName": CompanyName,
    "GSTNumber" : GSTNumber,
    "email": email,
    "PhoneNumber" : PhoneNumber,
    "InvoiceNumber": InvoiceNumber,
    "currency" : currency,

  };

}

class Phone{
  String phone;
  Phone(this.phone);
}