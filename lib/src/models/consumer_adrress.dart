// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ConsumerAddress {
  String? name;
  String? state;
  String? city;
  String? country;
  int? phoneNumber;
  String? pinCode;
  String? streetAddress;
  String? additionalInfo;
  String? landmark;
  String? latitude;
  String? longitude;

  ConsumerAddress(
      {this.name,
      this.state,
      this.city,
      this.country,
      this.phoneNumber,
      this.pinCode,
      this.streetAddress,
      this.additionalInfo,
      this.landmark,
      this.latitude,
      this.longitude});

  ConsumerAddress.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    state = json['state'];
    city = json['city'];
    phoneNumber = json['phoneNumber'];
    pinCode = json['pinCode'];
    streetAddress = json['streetAddress'];
    additionalInfo = json['additionalInfo'];
    landmark = json['landmark'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['state'] = this.state;
    data['city'] = this.city;
    data['phoneNumber'] = this.phoneNumber;
    data['pinCode'] = this.pinCode;
    data['streetAddress'] = this.streetAddress;
    data['additionalInfo'] = this.additionalInfo;
    data['landmark'] = this.landmark;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}
