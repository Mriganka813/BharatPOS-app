class PartyInput {
  PartyInput({
    this.id,
    this.name,
    this.phoneNumber,
    this.address,
  });
  String? id;
  String? name;
  String? phoneNumber;
  String? address;

  factory PartyInput.fromMap(Map<String, dynamic> json) => PartyInput(
        name: json["name"],
        phoneNumber: json["phoneNumber"],
        address: json["address"],
        id: json["_id"],
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "id": id,
        "phoneNumber": phoneNumber,
        "address": address,
      };
}
