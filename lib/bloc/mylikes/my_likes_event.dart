import 'package:equatable/equatable.dart';
import 'package:instaclone/model/post_model.dart';

abstract class MyLikesEvent extends Equatable{
  const MyLikesEvent();
}

class LoadLikesPostsEvent extends MyLikesEvent{
  @override
  List<Object?> get props => [];
}

class UnLikePostEvent extends MyLikesEvent{
  Post post;

  UnLikePostEvent({required this.post});

  @override
  List<Object?> get props => [];
}
class RemovePostEvent extends MyLikesEvent{
  Post post;

  RemovePostEvent({required this.post});

  @override
  List<Object?> get props => [];
}