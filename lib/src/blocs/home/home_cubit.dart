import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shopos/src/services/user.dart';

import '../../models/user.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  Future<void> currentUser() async {
    final response = await UserService.me();
    print (" MEEEEEEEEEEEEEEEEE\n\n ${response.data}");
    if(response.data['subUser'] != null && response.data['subUser'] != ""){
      print("\n\nSUBUSER DETECTED\n\n");
      final user = User.fromMap(response.data['subUser']);
      print("Names of userrrrr \n ------------------------- \n ${user.name} ?? ${user.businessName}");
      emit(HomeRender(user));
    }
    else {
      final user = User.fromMap(response.data['user']);
      print("Names of userrrrr \n ------------------------- \n ${user.name} ?? ${user.businessName}");
      emit(HomeRender(user));
    }
  }


}
