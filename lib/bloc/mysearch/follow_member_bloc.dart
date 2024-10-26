import 'package:bloc/bloc.dart';
import 'package:instaclone/bloc/mysearch/follow_member_event.dart';
import 'package:instaclone/bloc/mysearch/follow_member_state.dart';
import 'package:instaclone/services/db_service.dart';

class FollowMemberBloc extends Bloc<FollowEvent, FollowState> {
  FollowMemberBloc() : super(FollowMemberInitialState()) {
    on<FollowMemberEvent>(_onFollowMemberEvent);
    on<UnFollowMemberEvent>(_onUnFollowMemberEvent);
  }

  Future<void> _onFollowMemberEvent(
      FollowMemberEvent event, Emitter<FollowState> emit) async {
    await DbService.followMember(event.someone);
    event.someone.followed = true;

    emit(FollowMemberSuccessState(member: event.someone));

    DbService.storePostsToMyFeed(event.someone);
    // sendNotificationToFollowedMember(someone);
  }

  Future<void> _onUnFollowMemberEvent(
      UnFollowMemberEvent event, Emitter<FollowState> emit) async {
    await DbService.unfollowMember(event.someone);
    event.someone.followed = false;

    emit(FollowMemberSuccessState(member: event.someone));

    DbService.removePostsFromMyFeed(event.someone);
  }
}
