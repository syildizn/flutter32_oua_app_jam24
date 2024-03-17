import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  static String routeName = "detailPage";

  final Map<String?, dynamic>? data;
  final String? documaIdsi;

  const DetailPage({Key? key,  this.data,  this.documaIdsi}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  final TextEditingController _commentController = TextEditingController();

  Future<void> _addComment(String documentId, String comment) async {
    if (comment.isNotEmpty) {
      final collectionRef = FirebaseFirestore.instance.collection('comments');
      await collectionRef.add({
        'text': comment,
        'createdAt': FieldValue.serverTimestamp(),
        'locationId': documentId,
      });
      _commentController.clear();
    }
  }

  Stream<QuerySnapshot> _loadComments(String documentId) {
    return FirebaseFirestore.instance
        .collection('comments')
        .where('locationId', isEqualTo: documentId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

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
    final String image = widget.data?['image'] ?? 'https://via.placeholder.com/100';
    final String name = widget.data?['name'] ?? 'İsim yok';
    final String address = widget.data?['adress'] ?? 'Adres yok';
    final String feature = widget.data?['feature'] ?? 'Özellik yok';
    final GeoPoint? location = widget.data?['location'];
    final double? latitude = location?.latitude;
    final double? longitude = location?.longitude;

    // Veri haritasından 'documentId' alın. Bu, yorumlarla ilişkilendirmek için kullanılacak.
    final String documentId = widget.documaIdsi ?? 'default_id';


    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data?['name'] ?? 'İsim yok'), // veya başka bir başlık
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
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: _loadComments(documentId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    print(
                        "snapError: ${snapshot.hasError} snapData: ${!snapshot.hasData} snapEmpt: ${snapshot.data?.docs.isEmpty} "
                    );
                    print(snapshot.error.toString());
                    return Center(child: Text("Henüz yorum yok."));
                  }

                  return ListView.builder(
                    shrinkWrap: true,

                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final commentData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(commentData['text'] ?? ""),
                        subtitle: Text(commentData['createdAt'] == null ? "" : (commentData['createdAt'] as Timestamp).toDate().toString()),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Divider(),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        labelText: 'Yorum yap',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      if (_commentController.text.isNotEmpty) {
                        _addComment(documentId, _commentController.text);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
