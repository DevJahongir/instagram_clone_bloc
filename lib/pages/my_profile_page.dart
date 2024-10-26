import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instaclone/bloc/myprofile/axis_count_bloc.dart';
import 'package:instaclone/bloc/myprofile/my_photo_bloc.dart';
import 'package:instaclone/bloc/myprofile/my_photo_event.dart';
import 'package:instaclone/bloc/myprofile/my_photo_state.dart';
import 'package:instaclone/bloc/myprofile/my_posts_bloc.dart';
import 'package:instaclone/bloc/myprofile/my_posts_event.dart';
import 'package:instaclone/bloc/myprofile/my_posts_state.dart';
import 'package:instaclone/bloc/myprofile/my_profile_event.dart';
import 'package:instaclone/bloc/myprofile/my_profile_state.dart';
import 'package:instaclone/bloc/signin/signin_bloc.dart';
import 'package:instaclone/pages/signin_page.dart';
import 'package:instaclone/services/auth_service.dart';
import 'package:instaclone/services/db_service.dart';
import 'package:instaclone/services/file_service.dart';
import 'package:instaclone/services/utils_service.dart';

import '../bloc/myprofile/my_profile_bloc.dart';
import '../model/member_model.dart';
import '../model/post_model.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  late MyProfileBloc profileBloc;
  late MyPostsBloc postsBloc;
  late MyPhotoBloc photoBloc;

  final ImagePicker _picker = ImagePicker();

  _imgFromGallery() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    photoBloc.add(UploadMyPhotoEvent(image: File(image!.path)));
  }

  _imgFromCamera() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    photoBloc.add(UploadMyPhotoEvent(image: File(image!.path)));
  }

  _dialogLogout() async {
    var result = await Utils.dialogCommon(
        context, "Instagram", "Do you want to logout?", false);
    if (result) {
      _signOutUser();
    }
  }

  _signOutUser() {
    AuthService.signOutUser(context);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => BlocProvider(
                  create: (context) => SignInBloc(),
                  child: SignInPage(),
                )));
  }

  _dialogRemovePost(Post post) async {
    var result = await Utils.dialogCommon(
        context, "Instagram", "Do you want to delete this post?", false);

    if (result) {
      postsBloc.add(RemoveMyPostEvent(post: post));
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Pick Photo'),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Take Photo'),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    profileBloc = context.read<MyProfileBloc>();
    profileBloc.add(LoadProfileMemberEvent());

    postsBloc = context.read<MyPostsBloc>();
    postsBloc.add(LoadMyPostsEvent());
    postsBloc.stream.listen((state) {
      if (state is RemoveMyPostState) {
        postsBloc.add(LoadMyPostsEvent());
      }
    });

    photoBloc = context.read<MyPhotoBloc>();
    photoBloc.stream.listen((state) {
      if (state is MyPhotoSuccessState) {
        profileBloc.add(LoadProfileMemberEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyProfileBloc, MyProfileState>(
      builder: (context, state) {
        if (state is MyProfileLoadingState) {
          return viewOfMyProfilePage(true, Member("", ""));
        }
        if (state is MyProfileLoadMemberState) {
          return viewOfMyProfilePage(false, state.member);
        }
        return viewOfMyProfilePage(false, Member("", ""));
      },
    );
  }

  Widget viewOfMyProfilePage(bool isLoading, Member member) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text("Profile"),
          actions: [
            IconButton(
              onPressed: () {
                _dialogLogout();
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Color.fromRGBO(193, 53, 132, 1),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  // #myphoto
                  GestureDetector(
                    onTap: () {
                      _showPicker(context);
                    },
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(70),
                              border: Border.all(
                                width: 1.5,
                                color: Color.fromRGBO(193, 53, 132, 1),
                              )),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(35),
                              child: member.img_url.isEmpty
                                  ? const Image(
                                      image: AssetImage(
                                          "assets/images/ic_person.png"),
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      member.img_url,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    )),
                        ),
                        const SizedBox(
                          width: 80,
                          height: 80,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.add_circle,
                                color: Colors.purple,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    member.fullname.toUpperCase(),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    member.email,
                    style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ),

                  // #mycounts
                  Container(
                    height: 80,
                    margin: EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Column(
                              children: [
                                BlocBuilder<MyPostsBloc, MyPostsState>(
                                    builder: (context, state) {
                                  if (state is MyPostsSuccessState) {
                                    return Text(
                                      state.items.length.toString(),
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    );
                                  }
                                  return const Text(
                                    "0",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );

                                }
                                ),
                                Text(
                                  "POSTS",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  member.followers_count.toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "FOLLOWERS",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  member.following_count.toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "FOLLOWING",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // #list_grid
                  Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: IconButton(
                            onPressed: () {
                              context
                                  .read<AxisCountBloc>()
                                  .add(AxisCountEvent(axisCount: 1));
                            },
                            icon: Icon(Icons.list_alt),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: IconButton(
                            onPressed: () {
                              context
                                  .read<AxisCountBloc>()
                                  .add(AxisCountEvent(axisCount: 1));
                            },
                            icon: Icon(Icons.grid_view),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // #my_posts

                  BlocBuilder<MyPostsBloc, MyPostsState>(
                    builder: (context, state) {
                      if (state is MyPostsSuccessState) {
                        return viewOfMyPosts(state.items);
                      }
                      return viewOfMyPosts([]);
                    },
                  ),
                ],
              ),
            ),
            isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : SizedBox.shrink(),
          ],
        ));
  }

  Widget viewOfMyPosts(List<Post> items) {
    return Expanded(child: BlocBuilder<AxisCountBloc, int>(
      builder: (context, state) {
        return GridView.builder(
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: state),
          itemCount: items.length,
          itemBuilder: (ctx, index) {
            return _itemOfPost(items[index]);
          },
        );
      },
    ));
  }

  Widget _itemOfPost(Post post) {
    return GestureDetector(
        onLongPress: () {
          _dialogRemovePost(post);
        },
        child: Container(
          margin: const EdgeInsets.all(5),
          child: Column(
            children: [
              Expanded(
                child: CachedNetworkImage(
                  width: double.infinity,
                  imageUrl: post.img_post,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                post.caption,
                style: TextStyle(color: Colors.black87.withOpacity(0.7)),
                maxLines: 2,
              )
            ],
          ),
        ));
  }
}
