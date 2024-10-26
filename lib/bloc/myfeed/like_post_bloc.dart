import 'package:bloc/bloc.dart';
import 'package:instaclone/bloc/myfeed/like_post_event.dart';
import 'package:instaclone/services/db_service.dart';

import 'like_post_state.dart';

class LikePostBloc extends Bloc<LikedEvent, LikeState>{
  LikePostBloc(): super(LikePostInitialState()){
    on<LikePostEvent>(_onLikePostEvent);
    on<UnLikePostEvent>(_onUnLikePostEvent);
  }

  Future<void> _onLikePostEvent(
      LikePostEvent event, Emitter<LikeState> emit)async{
    await DbService.likePost(event.post, true);
    event.post.liked = true;
    emit(LikePostSuccessState(post: event.post));
  }

  Future<void> _onUnLikePostEvent(
      UnLikePostEvent event, Emitter<LikeState> emit)async{
    await DbService.likePost(event.post, false);
    event.post.liked = false;
    emit(LikePostSuccessState(post: event.post));
  }
}