import 'package:bloc/bloc.dart';
import 'package:instaclone/bloc/myfeed/my_feed_event.dart';
import 'package:instaclone/bloc/myfeed/my_feed_state.dart';
import 'package:instaclone/services/db_service.dart';

import '../../model/post_model.dart';

class MyFeedBloc extends Bloc<MyFeedEvent, MyFeedState>{
  List<Post> items = [];

  MyFeedBloc():super(MyFeedInitialState()){
    on<LoadFeedPostEvent>(_onLoadFeedPostEvent);
    on<RemoveFeedPostEvent>(_onRemoveFeedPostEvent);
  }

  Future<void> _onLoadFeedPostEvent(
      LoadFeedPostEvent event, Emitter<MyFeedState> emit) async{
    emit(MyFeedLoadingState());

    var feeds = await DbService.loadFeeds();
    items.clear();
    items.addAll(feeds);

    if(feeds.isNotEmpty){
      emit(MyFeedSuccessState(items: items));
    }else{
      emit(MyFeedFailureState("No data"));
    }
  }

  Future<void> _onRemoveFeedPostEvent(
      RemoveFeedPostEvent event, Emitter<MyFeedState> emit) async{
    emit(MyFeedLoadingState());
    await DbService.removePost(event.post);
    emit(RemoveFeedPostState());
  }
}