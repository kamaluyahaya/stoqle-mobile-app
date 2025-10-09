import 'package:flutter/material.dart';
import 'package:stoqle/features/view/profile/edit/gender_and_age.dart';
import 'package:stoqle/features/view/profile/edit/edit.dart';
import 'package:stoqle/index/welcome.dart';

import '../core/utils/navigations/welcomeNav.dart';
import '../features/auth/domain/login.dart';
import '../features/auth/domain/user_name.dart';
import '../features/view/posting/notes_posting/note_post.dart';
import '../index/intro_screen.dart';

final Map<String, WidgetBuilder> routes = {
  // '/login': (context) => LoginScreen(),
  '/intro': (context) => const IntroScreen(),
  '/login_screen': (context) => UserLogin(),
  '/edit_profile': (context) => EditProfilePage(),
  '/user_fullname': (context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return UserFullnamePage(args: args);
  },
  '/dashboard': (context) => Usernavigator(),
  '/gender_age': (context) => GenderAndAge(),
  '/welcome': (context) => WelcomePage(), // Define HomeScreen
  '/stoqle_text_posting': (context) =>
      StoqleTextPostPage(), // Define HomeScreen
  // '/followersPage': (context) => Follow(), // Define HomeScreen
};
