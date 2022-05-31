import 'package:shopos/src/models/specific_party.dart';

abstract class SpecificPartyState {}

class SpecificPartyInitial extends SpecificPartyState {}

class SpecificPartyListRender extends SpecificPartyState {
  final List<SpecificParty> specificparty;
  SpecificPartyListRender(this.specificparty);
}

class SpecificPartyLoading extends SpecificPartyState {}

class SpecificPartyError extends SpecificPartyState {
  late final String message;
  SpecificPartyError(this.message);
}

class DeletePartyState extends SpecificPartyState {}
