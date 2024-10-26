import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instaclone/bloc/splash/splash_bloc.dart';
import 'package:instaclone/bloc/splash/splash_event.dart';
import 'package:instaclone/bloc/splash/splash_state.dart';
import 'package:instaclone/pages/home_page.dart';
import 'package:instaclone/pages/signin_page.dart';
import 'package:instaclone/services/auth_service.dart';

class SplashPage extends StatefulWidget {
  static const String id = "splash_page";

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  late SplashBloc splashBloc;

  @override
  void initState() {
    super.initState();
    splashBloc = BlocProvider.of<SplashBloc>(context);
    splashBloc.add(SplashWaitEvent());
    splashBloc.initNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<SplashBloc, SplashState>(
        listener: (context, state){
          if(state is SplashLoadedState){
            splashBloc.callNextPage(context);
          }
        },
        builder: (context, state){
          return Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(193, 53, 132, 1),
                      Color.fromRGBO(131, 58, 180, 1),
                    ])),
            child: const Column(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      "Instagram",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 45,
                          fontFamily: "Billabong"),
                    ),
                  ),
                ),
                Text(
                  "All rights reserved",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          );
        },
      )
    );
  }
}
