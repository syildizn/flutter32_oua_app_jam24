import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatelessWidget {
  static String routeName = "homePage";




  final Map<String?, dynamic> data;

  const DetailPage({Key? key, required this.data}) : super(key: key);


  Future<void> _launchMaps(double latitude, double longitude) async {
    final Uri googleMapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri);
    } else {
      throw 'Harita başlatılamadı';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String image = data['image'] ?? 'https://via.placeholder.com/100';
    final String name = data['name'] ?? 'İsim yok';
    final String address = data['adress'] ?? 'Adres yok';
    final String feature = data['feature'] ?? 'Özellik yok';
    final GeoPoint location = data['location'];
    final double latitude = location.latitude;
    final double longitude = location.longitude;

    return Scaffold(
      appBar: AppBar(
        title: Text(name), // veya başka bir başlık
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Image.network(image),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Adres: $address " ),
                  Text("              Konum:"),
                  IconButton(onPressed: (){
                    if (location != null ) {
                      // Enlem ve boylam bilgisini kullanarak harita uygulamasını başlat
                      _launchMaps(location.latitude , location.longitude );
                    }else {
                      // Eğer konum verisi yoksa varsayılan bir konum kullanabilirsiniz
                      _launchMaps(38.5820911, 26.9637778);
                    }
                  }, icon: Icon(Icons.assistant_navigation,color: Colors.blue,)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(feature),
            ),
          ],
        ),
      ),
    );
  }
}
