import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instaclone/bloc/signup/signup_event.dart';
import 'package:instaclone/bloc/signup/signup_state.dart';

import '../../model/member_model.dart';
import '../../services/auth_service.dart';
import '../../services/db_service.dart';
import '../../services/prefs_service.dart';
import '../../services/utils_service.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc() : super(SignUpInitialState()) {
    on<SignedUpEvent>(_onSignedUpEvent);
  }

  Future<void> _onSignedUpEvent(
      SignedUpEvent event, Emitter<SignUpState> emit) async {
    emit(SignUpLoadingState());

    User? firebaseUser = await AuthService.signUpUser(
        event.context, event.fullname, event.email, event.password);

    if (firebaseUser != null) {
      // await Prefs.saveUserId(firebaseUser.uid);
      _saveMemberToLocal(firebaseUser);
      _saveMemberToCloud(Member(event.fullname, event.email));
      emit(SignUpSuccessState());
    } else {
      emit(SignUpFailureState("Please, check your information"));
    }
  }

  _saveMemberToLocal(User? firebaseUser) async {
    await Prefs.saveUserId(firebaseUser!.uid);
  }

  _saveMemberToCloud(Member member) async {
    await DbService.storeMember(member);
  }
}
