import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopos/src/blocs/specific%20party/specific_party_state.dart';

class SpecificPartyCubit extends Cubit<SpecificPartyState> {
  SpecificPartyCubit() : super(SpecificPartyInitial());

//crete credit
  void credit() {}

//create settle
  void settle() {}
}
