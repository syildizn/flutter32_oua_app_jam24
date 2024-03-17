import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  static String routeName = "homePage";

  final Map<String?, dynamic> data;

  const DetailPage({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String image = data['image'] ?? 'https://via.placeholder.com/100';
    final String name = data['name'] ?? 'İsim yok';
    final String address = data['adress'] ?? 'Adres yok';
    final String feature = data['feature'] ?? 'Özellik yok';

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
              child: Text("Adres: $address"),
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
