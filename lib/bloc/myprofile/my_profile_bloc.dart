import 'package:bloc/bloc.dart';
import 'package:instaclone/bloc/myprofile/my_profile_event.dart';
import 'package:instaclone/bloc/myprofile/my_profile_state.dart';
import 'package:instaclone/services/db_service.dart';

class MyProfileBloc extends Bloc<MyProfileEvent, MyProfileState>{
  MyProfileBloc(): super(MyProfileInitialState()){
    on<LoadProfileMemberEvent>(_onLoadProfileMemberEvent);
  }

  Future<void> _onLoadProfileMemberEvent(LoadProfileMemberEvent event, Emitter<MyProfileState> emit)async{
    emit(MyProfileLoadingState());
    var member = await DbService.loadMember();
    emit(MyProfileLoadMemberState(member: member));
  }
}