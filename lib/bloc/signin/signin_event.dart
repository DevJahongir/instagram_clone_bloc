import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

abstract class SigninEvent extends Equatable {
  const SigninEvent();
}

class SignedInEvent extends SigninEvent {
  BuildContext context;
  String email;
  String password;

  SignedInEvent({
    required this.context, required this.email, required this.password
  });

  @override
  List<Object?> get props => [];
}