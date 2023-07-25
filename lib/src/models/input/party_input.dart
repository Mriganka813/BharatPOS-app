class PartyInput {
  PartyInput({
    this.id,
    this.name,
    this.phoneNumber,
    this.address,
    required this.type,
  });
  String? id;
  String? name;
  String? phoneNumber;
  String? address;
  String type;

  factory PartyInput.fromMap(Map<String, dynamic> json) => PartyInput(
      name: json["name"],
      phoneNumber: json["phoneNumber"],
      address: json["address"],
      id: json["_id"],
      type: json['type']);

  Map<String, dynamic> toMap() => {
        "name": name,
        "id": id,
        "type": type,
        "phoneNumber": phoneNumber,
        "address": address,
      };
}
