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
      backgroundColor: Color.fromRGBO(230,237,247,1),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade300,
        title: Text(widget.data?['name'] ?? 'İsim yok', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),), // veya başka bir başlık
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0), // Resme yuvarlak köşeler ekledik
                child: Image.network(image, fit: BoxFit.cover,height: 200), // Resmi kaplayacak şekilde ayarladık
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
              child: Row(mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                      child: Text(
                        "Adres: $address",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Text("              Konum:",),
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
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Color.fromRGBO(230,237,247,1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 1), // changes position of shadow
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18.0),
              width: double.infinity,
               // Özellikler için arka plan rengi
              child: Text(
                feature,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Text(
                "Yorumlar",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
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
                    return Center(child: Text("Henüz yorum yok.",style: TextStyle(fontSize: 16)));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final commentData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      return Card(
                        color: Colors.orange.shade100,
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        child: ListTile(
                          title: Text(
                            commentData['text'] ?? "",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            commentData['createdAt'] == null ? "" : (commentData['createdAt'] as Timestamp).toDate().toString(),
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Divider(),
            Padding(
              padding: const  EdgeInsets.all(18.0),
              child: Divider(),
            ),
            Padding(
              padding: EdgeInsets.all(18.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        labelText: 'Yorum yap',
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blue),
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
