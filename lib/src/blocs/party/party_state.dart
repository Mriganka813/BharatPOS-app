part of 'party_cubit.dart';

@immutable
abstract class PartyState {}

class PartyInitial extends PartyState {}

class PartyLoading extends PartyState {}

class PartyError extends PartyState {}

class PartyListRender extends PartyState {
  final List<Party> parties;
  PartyListRender(this.parties);
}

class PartyUpdate extends PartyState {}

class PartySuccess extends PartyState {}
