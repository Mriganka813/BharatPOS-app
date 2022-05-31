import 'package:shopos/src/models/order.dart';
import 'package:shopos/src/models/party.dart';

abstract class SpecificPartyState {}

class SpecificPartyInitial extends SpecificPartyState {}

class SpecificPartyListRender extends SpecificPartyState {
  final List<Order> specificparty;
  final Party partyDetails;
  SpecificPartyListRender({
    required this.specificparty,
    required this.partyDetails,
  });
}

class SpecificPartyLoading extends SpecificPartyState {}

class SpecificPartyError extends SpecificPartyState {
  late final String message;
  SpecificPartyError(this.message);
}

class SpecificPartySuccess extends SpecificPartyState {}

class DeletePartyState extends SpecificPartyState {}
