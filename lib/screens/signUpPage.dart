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
      appBar: AppBar(
        title: Text('Kayıt Ol'),
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
            child: Text('Kayıt Ol'),
            onPressed: () async {
              dynamic result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
              if (result != null) {
                _showDialog(title: 'Başarılı', content: 'Başarılı şekilde kayıt oldunuz. Şimdi giriş sayfasına gidip giriş yapabilirsiniz.', navigateToSignIn: true);
              } else {
                _showDialog(title: 'Hata', content: _errorMessage ?? 'Kayıt olurken bir hata oluştu.');
              }
            },
          ),
          TextButton(
            child: Text('Zaten üye misiniz? O halde giriş yapın'),
            onPressed: () {
              Navigator.of(context).pop();

            },
          ),
        ],
      ),
    );
  }
}
