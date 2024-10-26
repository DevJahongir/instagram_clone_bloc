import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instaclone/bloc/myfeed/like_post_bloc.dart';
import 'package:instaclone/bloc/myfeed/like_post_event.dart';
import 'package:instaclone/bloc/myfeed/like_post_state.dart';
import 'package:instaclone/bloc/myfeed/my_feed_bloc.dart';
import 'package:instaclone/bloc/myfeed/my_feed_event.dart';
import 'package:instaclone/bloc/myfeed/my_feed_state.dart';
import 'package:instaclone/model/post_model.dart';
import 'package:instaclone/services/db_service.dart';
import 'package:instaclone/services/utils_service.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class MyFeedPage extends StatefulWidget {
  final PageController? pageController;

  const MyFeedPage({super.key, this.pageController});

  @override
  State<MyFeedPage> createState() => _MyFeedPageState();
}

class _MyFeedPageState extends State<MyFeedPage> {
  late MyFeedBloc feedBloc;

  /// Delete Posts
  _dialogRemovePost(Post post) async {
    var result = await Utils.dialogCommon(
        context, "Instagram", "Do you want to delete this post?", false);

    if (result) {
      feedBloc.add(RemoveFeedPostEvent(post: post));
    }
  }

  @override
  void initState() {
    super.initState();
    feedBloc = context.read<MyFeedBloc>();
    feedBloc.add(LoadFeedPostEvent());

    feedBloc.stream.listen((state) {
      if (state is RemoveFeedPostState) {
        feedBloc.add(LoadFeedPostEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyFeedBloc, MyFeedState>(
      builder: (context, state) {
        if (state is MyFeedLoadingState) {
          viewOfFeedPage(true, feedBloc.items); //loading
        }
        if (state is MyFeedSuccessState) {
          viewOfFeedPage(false, state.items); // success
        }
        return viewOfFeedPage(false, feedBloc.items); // error
      },
    );
  }

  Widget viewOfFeedPage(bool isLoading, List<Post> items) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Instagram",
            style: TextStyle(
                color: Colors.black, fontFamily: 'Billabong', fontSize: 30),
          ),
          actions: [
            IconButton(
              onPressed: () {
                widget.pageController!.animateToPage(2,
                    duration: Duration(microseconds: 200),
                    curve: Curves.easeIn);
              },
              icon: Icon(Icons.camera_alt),
              color: Color.fromRGBO(193, 53, 132, 1),
            ),
          ],
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

  /// imaga zoom
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
                          : const Image(
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

          // post_image with zoom feature
          GestureDetector(
            onDoubleTap: () {
              _showZoomableImage(context, post.img_post);
            },
            child: CachedNetworkImage(
              width: MediaQuery.of(context).size.width,
              imageUrl: post.img_post,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) =>
                  Center(child: Icon(Icons.error)),
              fit: BoxFit.cover,
            ),
          ),

          //like_share
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (!post.liked) {
                      context
                          .read<LikePostBloc>()
                          .add(LikePostEvent(post: post));
                    } else {
                      context
                          .read<LikePostBloc>()
                          .add(UnLikePostEvent(post: post));
                    }
                  });
                },
                icon: BlocBuilder<LikePostBloc, LikeState>(
                  builder: (context, state) {
                    return post.liked
                        ? const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        : const Icon(
                            Icons.favorite_border,
                            color: Colors.black,
                          );
                  },
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.share),
              ),
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

// Show zoomable image in a dialog
  void _showZoomableImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: PhotoView(
            imageProvider: CachedNetworkImageProvider(imageUrl),
            backgroundDecoration: BoxDecoration(),
          ),
        );
      },
    );
  }

// Widget _itemOfPost(Post post) {
//   return Container(
//     color: Colors.white,
//     child: Column(
//       children: [
//         Divider(),
//
//         // #user_info
//         Container(
//           margin: EdgeInsets.only(bottom: 10),
//           padding: EdgeInsets.symmetric(horizontal: 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(40),
//                     child: post.img_user.isNotEmpty
//                         ? Image.network(
//                             post.img_user,
//                             width: 40,
//                             height: 40,
//                             fit: BoxFit.cover,
//                           )
//                         : const Image(
//                             width: 40,
//                             height: 40,
//                             image: AssetImage("assets/images/ic_person.png")),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         post.fullname,
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold, color: Colors.black),
//                       ),
//                       const SizedBox(
//                         height: 3,
//                       ),
//                       Text(
//                         post.date,
//                         style: const TextStyle(fontWeight: FontWeight.normal),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               post.mine
//                   ? IconButton(
//                       onPressed: () {
//                         _dialogRemovePost(post);
//                       },
//                       icon: Icon(Icons.more_horiz),
//                     )
//                   : SizedBox.shrink(),
//             ],
//           ),
//         ),
//
//         // post_image
//         CachedNetworkImage(
//           width: MediaQuery.of(context).size.width,
//           imageUrl: post.img_post,
//           placeholder: (context, url) => Center(
//             child: CircularProgressIndicator(),
//           ),
//           errorWidget: (context, url, error) =>
//               Center(child: Icon(Icons.error)),
//           fit: BoxFit.cover,
//         ),
//
//         //like_share
//         Row(
//           children: [
//             IconButton(
//                 onPressed: () {
//                   setState(() {
//                     if (!post.liked) {
//                       _apiPostLike(post);
//                     } else {
//                       _apiPostUnliked(post);
//                     }
//                   });
//                 },
//                 icon: post.liked
//                     ? const Icon(
//                         Icons.favorite,
//                         color: Colors.red,
//                       )
//                     : const Icon(
//                         Icons.favorite_border,
//                         color: Colors.black,
//                       )),
//             IconButton(
//               onPressed: () {},
//               icon: Icon(Icons.share),
//             )
//           ],
//         ),
//
//         // #caption
//         Container(
//           width: MediaQuery.of(context).size.width,
//           margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
//           child: RichText(
//             softWrap: true,
//             overflow: TextOverflow.visible,
//             text: TextSpan(
//                 text: post.caption,
//                 style: TextStyle(
//                   color: Colors.black,
//                 )),
//           ),
//         )
//       ],
//     ),
//   );
// }
}
