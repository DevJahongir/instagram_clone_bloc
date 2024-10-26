import '../../model/post_model.dart';

abstract class MyLikesState{}

class MyLikesInitialState extends MyLikesState{}

class MyLikesLoadingState extends MyLikesState{}

class MyLikesSuccessState extends MyLikesState{
  List<Post> items;

  MyLikesSuccessState({required this.items});
}

class MyLikesFailureState extends MyLikesState{
  final String errorMessage;

  MyLikesFailureState(this.errorMessage);
}


class UnLikePostSuccessState extends MyLikesState{
}

class RemovePostSuccessState extends MyLikesState{}

