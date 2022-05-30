import 'package:shopos/src/models/specific_party.dart';

abstract class SpecificPartyState {}

class SpecificPartyInitial extends SpecificPartyState {}

class SpecificPartyListRender extends SpecificPartyState {
  final List<SpecificParty> specificparty;
  SpecificPartyListRender(this.specificparty);
}

class DeletePartyState extends SpecificPartyState {}
