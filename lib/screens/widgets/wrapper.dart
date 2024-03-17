import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter32_oua_app_jam24/screens/homePage.dart';
import 'package:flutter32_oua_app_jam24/screens/signInPage.dart';

class Wrapper extends StatelessWidget {

  static String routeName = "Wrapper";

  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;

    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        // Eğer bağlantı bekleniyorsa bir yükleme çarkı göster
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        // Snapshot'ta veri varsa ve kullanıcı nesnesi null değilse, kullanıcı giriş yapmış demektir.
        if (snapshot.hasData && snapshot.data != null) {
          // Kullanıcı giriş yapmışsa HomePage'e yönlendir
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(HomePage.routeName);
          });
          return Container(); // Bu sırada gösterilecek bir geçici widget, örneğin boş bir Container
        }
        // Kullanıcı giriş yapmamışsa SignInPage'e yönlendir
        return SignInPage();
      },
    );
  }
}