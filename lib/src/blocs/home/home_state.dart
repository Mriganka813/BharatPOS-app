part of 'home_cubit.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeRender extends HomeState {
  final User user;
  HomeRender(this.user);
}
