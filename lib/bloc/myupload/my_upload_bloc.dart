import 'package:bloc/bloc.dart';
import 'package:instaclone/bloc/myupload/my_upload_event.dart';
import 'package:instaclone/bloc/myupload/my_upload_state.dart';
import 'package:instaclone/model/post_model.dart';
import 'package:instaclone/services/db_service.dart';
import 'package:instaclone/services/file_service.dart';

class MyUploadBloc extends Bloc<MyUploadEvent, MyUploadState>{
  MyUploadBloc(): super(MyUploadInitialState()){
    on<UploadPostEvent>(_onUpLoadPostEvent);
  }

  Future<void> _onUpLoadPostEvent(UploadPostEvent event, Emitter<MyUploadState> emit) async{
    emit(MyUploadLoadingState());

    var downloadUrl = await FileService.uploadPostImage(event.image);
    if(downloadUrl.isEmpty){
      emit(MyUploadFailureState('Please try again later'));
    }

    Post post = Post(event.caption, downloadUrl);
    //Post to post
    Post posted = await DbService.storePost(post);
    // Post to feeds
    await DbService.storeFeed(posted);
    emit(MyUploadSuccessState());
  }
}