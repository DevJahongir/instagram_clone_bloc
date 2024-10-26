import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instaclone/bloc/mylikes/my_likes_bloc.dart';
import 'package:instaclone/bloc/mylikes/my_likes_event.dart';
import 'package:instaclone/bloc/mylikes/my_likes_state.dart';
import 'package:instaclone/model/post_model.dart';
import 'package:instaclone/services/db_service.dart';

import '../services/utils_service.dart';

class MyLikesPage extends StatefulWidget {
  final PageController? pageController;

  const MyLikesPage({super.key, this.pageController});

  @override
  State<MyLikesPage> createState() => _MyLikesPageState();
}

class _MyLikesPageState extends State<MyLikesPage> {

  late MyLikesBloc likesBloc;

  _dialogRemovePost(Post post) async {
    var result = await Utils.dialogCommon(
        context, "Instagram", "Do you want to delete this post?", false);

    if(result){
      context.read<MyLikesBloc>().add(RemovePostEvent(post: post));
    }
  }


  @override
  void initState() {
    super.initState();
    likesBloc = context.read<MyLikesBloc>();
    likesBloc.add(LoadLikesPostsEvent());
  }



  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyLikesBloc, MyLikesState>(

      listener: (context, state){
         if(state is UnLikePostEvent){
           likesBloc.add(LoadLikesPostsEvent());
         }
         if(state is RemovePostEvent){
           likesBloc.add(LoadLikesPostsEvent());
         }
      },

      builder: (context, state){
        if(state is MyLikesLoadingState){
          return viewOfMyLikesPage(true, []);
        }
        if(state is MyLikesSuccessState){
          return viewOfMyLikesPage(false, state.items);
        }
        return viewOfMyLikesPage(false, []);
      },
    );
  }

  Widget viewOfMyLikesPage(bool isLoading, List<Post> items){
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Likes",
            style: TextStyle(
                color: Colors.black, fontSize: 30),
          ),
        ),
        body: Stack(
          children: [
            ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, index) {
                return _itemOfPost(items[index]);
              },
            ),
            isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : SizedBox.shrink()
          ],
        ));
  }

  Widget _itemOfPost(Post post) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Divider(),

          // #user_info
          Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: post.img_user.isNotEmpty
                          ? Image.network(
                        post.img_user,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      )
                          : Image(
                          width: 40,
                          height: 40,
                          image: AssetImage("assets/images/ic_person.png")),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.fullname,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          post.date,
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ],
                ),
                post.mine
                    ? IconButton(
                       onPressed: () {
                         _dialogRemovePost(post);
                       },
                       icon: Icon(Icons.more_horiz),
                )
                    : SizedBox.shrink(),
              ],
            ),
          ),

          // post_image
          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            imageUrl: post.img_post,
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) =>
                Center(child: Icon(Icons.error)),
            fit: BoxFit.cover,
          ),

          //like_share
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    context.read<MyLikesBloc>().add(UnLikePostEvent(post: post));
                  },
                  icon: post.liked
                      ? const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  )
                      : const Icon(
                    Icons.favorite_border,
                    color: Colors.black,
                  )),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.share),
              )
            ],
          ),

          // #caption
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: RichText(
              softWrap: true,
              overflow: TextOverflow.visible,
              text: TextSpan(
                  text: post.caption,
                  style: TextStyle(
                    color: Colors.black,
                  )),
            ),
          )
        ],
      ),
    );
  }
}
