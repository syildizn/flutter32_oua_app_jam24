import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter32_oua_app_jam24/screens/homePage.dart';
import 'package:flutter32_oua_app_jam24/screens/signUpPage.dart';

class SignInPage extends StatefulWidget {
  static String routeName = "signInPage";

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  bool _showPassword = false;

  Future<void> signIn() async {
    try {
      // Kullanıcı giriş işlemi
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Giriş işlemi başarılı, HomePage'e yönlendir
      Navigator.of(context).pushReplacementNamed(
          HomePage.routeName); // Eğer route isimlerinizi kullanıyorsanız
    } catch (e) {
      // Giriş işlemi hatalı, hata mesajını göster
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Giriş başarısız'),
          content: Text(e.toString()),
          actions: <Widget>[
            TextButton(
              child: Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.greenAccent.shade400,
          elevation: 0,
          title: Text('Giriş Yap', style: TextStyle(color: Colors.white)),
        ),
        body: SingleChildScrollView(
            child: Container(
          padding: EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 40),
              Image.asset("assets/images/yu.png",height: 150,width: 400),
              SizedBox(height: 40),
              TextField(
                onChanged: (value) => setState(() => email = value),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                onChanged: (value) => setState(() => password = value),
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.greenAccent.shade400,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text('Giriş Yap',style: TextStyle(color: Colors.white)),
                onPressed: signIn, // signIn metodunu burada çağır
              ),
              TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.greenAccent.shade700,
                ),
                child: Text('Üyeliğiniz yok mu? Kayıt olun'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                },
              ),
            ],
          ),
        ),
        ),
    );
  }
}
