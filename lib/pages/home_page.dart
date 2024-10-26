import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instaclone/bloc/home/home_bloc.dart';
import 'package:instaclone/bloc/home/home_event.dart';
import 'package:instaclone/bloc/home/home_state.dart';
import 'package:instaclone/bloc/mysearch/follow_member_bloc.dart';
import 'package:instaclone/bloc/mysearch/my_search_bloc.dart';
import 'package:instaclone/bloc/myupload/image_picker_bloc.dart';
import 'package:instaclone/bloc/myupload/my_upload_bloc.dart';
import 'package:instaclone/pages/my_feed_page.dart';
import 'package:instaclone/pages/my_likes_page.dart';
import 'package:instaclone/pages/my_profile_page.dart';
import 'package:instaclone/pages/my_search_page.dart';
import 'package:instaclone/pages/my_upload_page.dart';
import 'package:instaclone/services/log_service.dart';

import '../bloc/myfeed/like_post_bloc.dart';
import '../bloc/myfeed/my_feed_bloc.dart';
import '../bloc/mylikes/my_likes_bloc.dart';
import '../bloc/myprofile/axis_count_bloc.dart';
import '../bloc/myprofile/my_photo_bloc.dart';
import '../bloc/myprofile/my_posts_bloc.dart';
import '../bloc/myprofile/my_profile_bloc.dart';

class HomePage extends StatefulWidget {
  static const String id = "home_page";

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeBloc homeBloc;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    homeBloc = context.read<HomeBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        LogService.i(state.currentIndex.toString());
      },
      builder: (context, state) {
        return Scaffold(
          body: PageView(
            controller: _pageController,
            children: [
              MultiBlocProvider(
                providers: [
                  BlocProvider(create: (context) => MyFeedBloc()),
                  BlocProvider(create: (context) => LikePostBloc()),
                ],
                child: MyFeedPage(
                  pageController: _pageController,
                ),
              ),
              MultiBlocProvider(
                providers: [
                  BlocProvider(create: (context) => MySearchBloc()),
                  BlocProvider(create: (context) => FollowMemberBloc()),
                ],
                child: MySearchPage(),
              ),
              MultiBlocProvider(
                providers: [
                  BlocProvider(create: (context) => ImagePickerBloc()),
                  BlocProvider(create: (context) => MyUploadBloc()),
                ],
                child: MyUploadPage(
                  pageController: _pageController,
                ),
              ),
              BlocProvider(
                create: (context) => MyLikesBloc(),
                child: MyLikesPage(),
              ),
              MultiBlocProvider(
                providers: [
                  BlocProvider(create: (context) => MyProfileBloc(),),
                  BlocProvider(create: (context) => MyPostsBloc(),),
                  BlocProvider(create: (context) => AxisCountBloc(),),
                  BlocProvider(create: (context) => MyPhotoBloc(),)
                ],
                child: MyProfilePage(),
              ),
            ],
            onPageChanged: (int index) {
              homeBloc.add(PageViewEvent(currentIndex: index));
            },
          ),
          bottomNavigationBar: CupertinoTabBar(
            onTap: (int index) {
              homeBloc.add(BottomNavEvent(currentIndex: index));
              _pageController!.animateToPage(index,
                  duration: Duration(milliseconds: 200), curve: Curves.easeIn);
            },
            currentIndex: state.currentIndex,
            activeColor: Color.fromRGBO(193, 53, 132, 1),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(
                Icons.home,
                size: 32,
              )),
              BottomNavigationBarItem(
                  icon: Icon(
                Icons.search,
                size: 32,
              )),
              BottomNavigationBarItem(
                  icon: Icon(
                Icons.add_box,
                size: 32,
              )),
              BottomNavigationBarItem(
                  icon: Icon(
                Icons.favorite,
                size: 32,
              )),
              BottomNavigationBarItem(
                  icon: Icon(
                Icons.account_circle,
                size: 32,
              )),
            ],
          ),
        );
      },
    );
  }
}
