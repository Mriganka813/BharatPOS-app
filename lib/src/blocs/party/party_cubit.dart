import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:magicstep/src/models/input/party_input.dart';
import 'package:magicstep/src/models/party.dart';
import 'package:magicstep/src/services/auth.dart';
import 'package:magicstep/src/services/party.dart';
import 'package:meta/meta.dart';

part 'party_state.dart';

class PartyCubit extends Cubit<PartyState> {
  PartyCubit() : super(PartyInitial());
  final PartyService _partyService = const PartyService();

  void createParty(PartyInput p) async {
    emit(PartyLoading());
    try {
      final response = await _partyService.createParty(p);
      if ((response.statusCode ?? 400) > 300) {
        emit(PartyError());
        return;
      }
      const AuthService().saveCookie(response);
    } on DioError {
      emit(PartyError());
    }
    emit(PartySuccess());
    return;
  }

  void getMyParties() async {
    emit(PartyLoading());
    final response = await _partyService.getParties();
    if ((response.statusCode ?? 400) > 300) {
      emit(PartyError());
      return;
    }
    final parties = List.generate(
      response.data['allParty'].length,
      (i) => Party.fromMap(response.data['allParty'][i]),
    );
    return emit(PartyListRender(parties));
  }

  void deleteParty(Party p) async {
    final response = await _partyService.deleteParty(p);
    if ((response.statusCode ?? 400) > 300) {
      emit(PartyError());
      return;
    }

    return emit(PartySuccess());
  }

  void updateParty(PartyInput p) async {
    final response = await _partyService.updateParty(p);
    if ((response.statusCode ?? 400) > 300) {
      emit(PartyError());
      return;
    }
    return emit(PartySuccess());
  }
}
