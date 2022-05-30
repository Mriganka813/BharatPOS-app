import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shopos/src/services/user.dart';

import '../../models/user.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  Future<void> currentUser() async {
    final response = await UserService.me();
    final user = User.fromMap(response.data['user']);
    emit(HomeRender(user));
  }
}
