// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:eClassify/data/model/user_model.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserDetailsCubit extends Cubit<UserDetailsState> {
  UserDetailsCubit()
      : super(UserDetailsState(
            user: HiveUtils.isUserAuthenticated()
                ? HiveUtils.getUserDetails()
                : null));

  void fill(UserModel model) {
    emit(UserDetailsState(user: model));
  }

  void copy(UserModel model) {
    emit(state.copyWith(user: model));
  }

  void clear() {
    emit(UserDetailsState(user: null));
  }
}

class UserDetailsState {
  final UserModel? user;

  UserDetailsState({
    required this.user,
  });

  UserDetailsState copyWith({
    UserModel? user,
  }) {
    return UserDetailsState(
      user: user ?? this.user,
    );
  }
}
