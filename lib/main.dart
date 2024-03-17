import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter32_oua_app_jam24/screens/widgets/wrapper.dart';
import 'firebase_options.dart';
import 'package:flutter32_oua_app_jam24/routes.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Bu satırı ekleyin
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: Wrapper.routeName,
      routes: routes,

    );
  }
}






