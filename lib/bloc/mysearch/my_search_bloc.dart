import 'package:bloc/bloc.dart';
import 'package:instaclone/bloc/mysearch/my_search_event.dart';
import 'package:instaclone/bloc/mysearch/my_search_state.dart';
import 'package:instaclone/services/db_service.dart';

class MySearchBloc extends Bloc<MySearchEvent, MySearchState>{
  MySearchBloc(): super(MySearchInitialState()){
    on<LoadSearchMembersEvent>(_onLoadSearchMembersEvent);
  }

  Future<void> _onLoadSearchMembersEvent(
      LoadSearchMembersEvent event, Emitter<MySearchState> emit)async{
    emit(MySearchLoadingState());

    var members = await DbService.searchMembers(event.keyword);

    if(members.isNotEmpty){
      emit(MySearchSuccessState(items: members));
    }else{
      emit(MySearchFailureState("No data"));
    }
  }
}