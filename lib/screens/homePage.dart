import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter32_oua_app_jam24/screens/DetailPage.dart';
import 'package:flutter32_oua_app_jam24/screens/addLocationPage.dart';
import 'package:flutter32_oua_app_jam24/screens/signInPage.dart';

class HomePage extends StatefulWidget {
  static String routeName = "homePage";

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedCity = 'izmir'; // Varsayılan şehir

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ana Sayfa'),
        actions: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('cities').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();  // Veri yüklenirken bir yükleme çarkı göster
              }
              var citiesList = snapshot.data!.docs.map((doc) => doc.id).toList();
              print(citiesList);
              return DropdownButton<String>(
                value: _selectedCity,
                icon: Icon(Icons.arrow_downward),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCity = newValue!;
                  });
                },
                items: citiesList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              );
            },
          ),

          IconButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SignInPage()));
              },
              icon: Icon(Icons.exit_to_app_sharp)),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('cities')
            .doc(_selectedCity.toLowerCase())
            .collection('location')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Bir hata oluştu');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String?, dynamic> data =
                  document.data()! as Map<String?, dynamic>;

              // Verilerin null olmadığından emin olun
              final String name = data['name'] ?? 'İsim yok';
              final String address = data['adress'] ?? 'Adres yok';
              final String image = data['image'] ?? 'https://hips.hearstapps.com/hmg-prod/images/dog-puppy-on-garden-royalty-free-image-1586966191.jpg?crop=1xw:0.74975xh;center,top&resize=1200:*'; // Varsayılan bir resim URL'si sağlayın
              final String feature = data['feature'] ?? 'Özellik yok';
              final String documentId = data['id'] ?? document.id.toString();

              return ListTile(
                title: Text(name),
                subtitle: Text(address),
                trailing: Image.network(image, width: 100, height: 100),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetailPage(data: data,documaIdsi: document.id.toString(),)));
                } ,
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Mekan ekleme formu sayfasına yönlendir
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddLocationPage()),
          );
        },
        child: Icon(Icons.add_location),
        tooltip: 'Mekan Öner',
      ),
    );
  }
}
