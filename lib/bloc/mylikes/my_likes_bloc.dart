import 'package:bloc/bloc.dart';
import 'package:instaclone/bloc/mylikes/my_likes_event.dart';
import 'package:instaclone/bloc/mylikes/my_likes_state.dart';
import 'package:instaclone/bloc/mysearch/my_search_state.dart';
import 'package:instaclone/services/db_service.dart';

class MyLikesBloc extends Bloc<MyLikesEvent, MyLikesState>{
  MyLikesBloc(): super(MyLikesInitialState()){
    on<LoadLikesPostsEvent>(_onLoadLikesPostsEvent);
    on<UnLikePostEvent>(_onUnLikePostEvent);
    on<RemovePostEvent>(_onRemovePostEvent);
  }

  Future<void> _onLoadLikesPostsEvent(LoadLikesPostsEvent event, Emitter<MyLikesState> emit)async{
    emit(MyLikesLoadingState());

    var items = await DbService.loadLikes();

    if(items.isNotEmpty){
      emit(MyLikesSuccessState(items: items));
    }else{
      emit(MyLikesFailureState("No data"));
    }
  }

  Future<void> _onUnLikePostEvent(UnLikePostEvent event, Emitter<MyLikesState> emit)async{
    emit(MyLikesLoadingState());

    await DbService.likePost(event.post, false);

    emit(UnLikePostSuccessState());
  }

  Future<void> _onRemovePostEvent(RemovePostEvent event, Emitter<MyLikesState>emit)async{
     emit(MyLikesLoadingState());
     await DbService.removePost(event.post);
     emit(RemovePostSuccessState());
  }


}