import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instaclone/bloc/mysearch/follow_member_bloc.dart';
import 'package:instaclone/bloc/mysearch/follow_member_event.dart';
import 'package:instaclone/bloc/mysearch/follow_member_state.dart';
import 'package:instaclone/bloc/mysearch/my_search_bloc.dart';
import 'package:instaclone/bloc/mysearch/my_search_event.dart';
import 'package:instaclone/bloc/mysearch/my_search_state.dart';
import 'package:instaclone/services/db_service.dart';

import '../model/member_model.dart';

class MySearchPage extends StatefulWidget {
  const MySearchPage({super.key});

  @override
  State<MySearchPage> createState() => _MySearchPageState();
}

class _MySearchPageState extends State<MySearchPage> {
  late MySearchBloc searchBloc;


  var searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    searchBloc = context.read<MySearchBloc>();
    searchBloc.add(LoadSearchMembersEvent(keyword: ""));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MySearchBloc, MySearchState>(
      builder: (context, state){
        if(state is MySearchLoadingState){
          return viewOfSearchPage(true, []);
        }
        if(state is MySearchSuccessState){
          return viewOfSearchPage(false, state.items);
        }
        return viewOfSearchPage(false, []);
      },
    );
  }

  Widget viewOfSearchPage(bool isLoading, List<Member> items){
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "Search",
            style: TextStyle(color: Colors.black, fontSize: 30),
          ),
        ),
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  // #search_member
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.only(left: 10, right: 10),
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: TextField(
                      controller: searchController,
                      style: TextStyle(color: Colors.black87),
                      decoration: const InputDecoration(
                          hintText: "Search",
                          border: InputBorder.none,
                          hintStyle:
                          TextStyle(fontSize: 15, color: Colors.grey),
                          icon: Icon(
                            Icons.search,
                            color: Colors.grey,
                          )),
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (ctx, index) {
                        return _itemOfMember(items[index]);
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }

  Widget _itemOfMember(Member member) {
    return SizedBox(
      height: 90,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(70),
              border: Border.all(
                width: 1.5,
                color: Color.fromRGBO(193, 53, 132, 1),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22.5),
              child: member.img_url.isEmpty
                  ? const Image(
                image: AssetImage("assets/images/ic_person.png"),
                width: 45,
                height: 45,
                fit: BoxFit.cover,
              )
                  : Image.network(
                member.img_url,
                width: 45,
                height: 45,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullname,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis, // Handle long names
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  member.email,
                  style: TextStyle(color: Colors.black54),
                  overflow: TextOverflow.ellipsis, // Handle long emails
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (member.followed) {
                context.read<FollowMemberBloc>().add(UnFollowMemberEvent(someone: member));
              } else {
                context.read<FollowMemberBloc>().add(FollowMemberEvent(someone: member));
              }
            },
            child: Container(
              width: 100,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: member.followed ? Colors.grey : Colors.blue, // Change background color to grey when unfollowed
                border: Border.all(
                  width: 1,
                  color: member.followed ? Colors.grey : Colors.blue, // Change border color to grey when unfollowed
                ),
              ),
              child: Center(
                child: BlocBuilder<FollowMemberBloc, FollowState>(
                  builder: (context, state) {
                    return Text(
                      member.followed ? "Unfollow" : "Follow",
                      style: TextStyle(
                        color: member.followed ? Colors.black : Colors.white, fontWeight: FontWeight.bold// Change text color to black when unfollowed
                      ),
                    );
                  },
                ),
              ),
            ),
          )


        ],
      ),
    );
  }

}
