import 'package:equatable/equatable.dart';
import 'package:instaclone/model/post_model.dart';

abstract class MyFeedEvent extends Equatable {
  const MyFeedEvent();
}

class LoadFeedPostEvent extends MyFeedEvent{
  @override
  List<Object?> get props =>[];
}

class RemoveFeedPostEvent extends MyFeedEvent{
  Post post;

  RemoveFeedPostEvent({required this.post});

  @override
  List<Object?> get props => [];
}