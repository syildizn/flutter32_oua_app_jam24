import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter32_oua_app_jam24/screens/DetailPage.dart';
import 'package:flutter32_oua_app_jam24/screens/addLocationPage.dart';
import 'package:flutter32_oua_app_jam24/screens/profilPage.dart';
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
      backgroundColor: Color.fromRGBO(230,237,247,1),
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ProfilScreen()),
          );
        },icon: Icon(Icons.person,color: Colors.white,)),
        backgroundColor: Colors.deepOrange.shade300,
        title: Text('Ana Sayfa', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
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
                icon: Icon(Icons.arrow_downward, color: Colors.white),
                underline: Container(height: 2, color: Colors.white),
                dropdownColor: Colors.white,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCity = newValue!;
                  });
                },
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                items: citiesList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child:  Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      margin: EdgeInsets.symmetric(vertical: 4), // Menü öğeleri arasında boşluk
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Text(value, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  );
                }).toList(),

                itemHeight: 60, // Her bir dropdown menü öğesinin yüksekliği
              );
            },
          ),

          IconButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SignInPage()));
              },
              icon: Icon(Icons.exit_to_app_sharp, color: Colors.white),
          )],
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

          return  ListView.builder(
            itemCount: snapshot.data?.docs.length ?? 0,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;

              final String name = data['name'] ?? 'İsim yok';
              final String address = data['address'] ?? 'Adres yok';
              final String image = data['image'] ?? 'https://hips.hearstapps.com/hmg-prod/images/dog-puppy-on-garden-royalty-free-image-1586966191.jpg';
              final String feature = data['feature'] ?? 'Özellik yok';

              return Card(
                color: Colors.green.shade50,
                elevation: 5,
                margin: EdgeInsets.all(10),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(address),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(image),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetailPage(data: data,documaIdsi: document.id,)));
                  },
                ),
              );
            },
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
        backgroundColor: Colors.green.shade50,
        child: Icon(Icons.add, color: Colors.black),
        tooltip: 'Mekan Öner',
      ),
    );
  }
}
