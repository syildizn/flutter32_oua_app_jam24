import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter32_oua_app_jam24/screens/signInPage.dart';

class SignUpPage extends StatefulWidget {

  static String routeName = "signUpPage";

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  bool _showPassword = false;
  String? _errorMessage;


  Future<void> _showDialog({required String title, String? content, bool navigateToSignIn = false}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Kullanıcının iletişim kutusunu kapatmak için düğmeye dokunması gerekir
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content ?? 'Bir hata oluştu.'),
          actions: <Widget>[
            TextButton(
              child: Text('Kapat'),
              onPressed: () {
                if (navigateToSignIn) {
                  _auth.signOut(); // Kullanıcı çıkışı yap
                  Navigator.of(context)
                      .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => SignInPage()), (Route<dynamic> route) => false);
                } else {
                  Navigator.of(context).pop(); // Dialog'u kapat
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.greenAccent.shade400,
        elevation: 0,
        title: Text('Kayıt Ol', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 30),
              Image.asset("assets/images/yu.png", height: 150, width: 400),
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
                  icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
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
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text('Kayıt Ol', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  dynamic result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
                  if (result != null) {
                    _showDialog(title: 'Başarılı', content: 'Başarılı şekilde kayıt oldunuz. Şimdi giriş sayfasına gidip giriş yapabilirsiniz.', navigateToSignIn: true);
                  } else {
                    _showDialog(title: 'Hata', content: _errorMessage ?? 'Kayıt olurken bir hata oluştu.');
                  }
                },
              ),
              SizedBox(height: 30),
              TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.greenAccent.shade700,
                ),
                child: Text('Zaten üye misiniz? O halde giriş yapın'),
                onPressed: () {
                  Navigator.of(context).pop();
          
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
