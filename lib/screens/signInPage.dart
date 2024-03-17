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
      Navigator.of(context).pushReplacementNamed(HomePage.routeName); // Eğer route isimlerinizi kullanıyorsanız
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
      appBar: AppBar(
        title: Text('Giriş Yap'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: TextField(
              onChanged: (value) {
                setState(() => email = value);
              },
              decoration: InputDecoration(labelText: 'Email'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: TextField(
              obscureText: !_showPassword,
              onChanged: (value) {
                setState(() => password = value);
              },
              decoration: InputDecoration(
                labelText: 'Password',
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
          ),
          ElevatedButton(
            child: Text('Giriş Yap'),
            onPressed: signIn, // signIn metodunu burada çağır
          ),
          TextButton(
            child: Text('Üyeliğiniz yok mu? Kayıt olun'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SignUpPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
