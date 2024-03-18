import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';


class AddLocationPage extends StatefulWidget {
  static String routeName = "addLocationPage";

  @override
  _AddLocationPageState createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _featureController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  LatLng? _selectedLocation;
  Location _location = Location();
  LatLng? _initialPosition;
  String? _selectedCity;


  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _featureController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      final userLocation = await _location.getLocation();
      setState(() {
        _initialPosition = LatLng(userLocation.latitude!, userLocation.longitude!);
      });
    } on Exception catch (e) {
      // Konum bilgisi alınamadığında bir hata mesajı gösterebilirsiniz.
      print('Konum bilgisi alınamadı: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
          if (pickedFile != null) {
            _showImageSelectedAlert();
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resim seçilmedi')),
        );
      }
    } catch (e) {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resim seçme işlemi sırasında bir hata oluştu: $e')),
      );
    }
  }

  void _showImageSelectedAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Resim Seçildi'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Seçilen resim başarıyla yüklendi.'),
                SizedBox(height: 15),
                Image.file(File(_imageFile!.path)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> _uploadImageToStorage(File image) async {
    String fileName = Path.basename(image.path);
    Reference storageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask = storageRef.putFile(image);

    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }


  // Kullanıcının harita üzerinde bir konum seçmesi için bir fonksiyon
  void _selectLocation(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    Navigator.of(context).pop();  // Harita ekranını kapat
  }

  // Harita göstermek için bir dialog açan fonksiyon
  void _showMapDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            height: 600, // Harita için yükseklik belirleyin
            width: 600,
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {},
              initialCameraPosition: CameraPosition(
                target: _initialPosition ?? LatLng(38.5820911, 26.9637778), // Başlangıç konumu
                zoom: 17,
              ),
              onTap: _selectLocation, // Haritaya dokunulduğunda konum seç
            ),
          ),
        );
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String city = _cityController.text;
      String imageUrl = '';
      if (_imageFile != null) {
        imageUrl = await _uploadImageToStorage(File(_imageFile!.path));
      }

      // // Firestore koleksiyonuna yeni bir mekan ekleyin
      // await FirebaseFirestore.instance.collection('cities/$city/location').add({
      //   'name': _nameController.text,
      //   'adress': _addressController.text,
      //   'feature': _featureController.text,
      //   'image': imageUrl,
      //   'location': GeoPoint(_selectedLocation!.latitude, _selectedLocation!.longitude), // Seçilen konum
      //   'id':,
      // });
      // Belge referansı oluştur
      DocumentReference docRef = FirebaseFirestore.instance.collection('cities/$city/location').doc();
      // Firestore'a yeni döküman gönder
      await docRef.set({
        'name': _nameController.text,
        'adress': _addressController.text,
        'feature': _featureController.text,
        'image': imageUrl,
        'location': GeoPoint(_selectedLocation!.latitude, _selectedLocation!.longitude),
        'id': docRef.id, // Otomatik olarak oluşturulan ID'yi belgeye ayarlayın
      });

      // Formu gönderdikten sonra önceki sayfaya dön
      Navigator.of(context).pop();
    }else {
      // Kullanıcıya hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tüm alanları doldurun ve bir resim seçin.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(230,237,247,1),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade300,
      title: Text('Mekan Öner',style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            // TextFormField(
            //     controller: _cityController,
            //     decoration: InputDecoration(labelText: 'Şehir Adı'),
            //     validator: (value) {
            //       if (value == null || value.isEmpty) {
            //         return 'Şehir adı boş bırakılamaz';
            //       }
            //       final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
            //       if (!validCharacters.hasMatch(value)) {
            //         return 'Geçersiz karakterler içermemelidir (Özel semboller, Türkçe karakterler vs.)';
            //       }
            //       return null;
            //     }),
        DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Şehir Seçiniz',
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2.0)
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        value: _selectedCity,
        onChanged: (String? newValue) {
          setState(() {
            _selectedCity = newValue;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Lütfen bir şehir seçiniz';
          }
          return null;
        },
        items: <String>['izmir', 'istanbul', 'ankara']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Mekan Adı',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Mekan adı boş bırakılamaz';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Adres',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0)
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Adres boş bırakılamaz';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _featureController,
              decoration: InputDecoration(
                labelText: 'Özellikler',
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0)
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Özellikler boş bırakılamaz';
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Resim Seç:"),
                  IconButton(onPressed: ()async{
                    await _pickImage();
                  }, icon: Icon(Icons.image)),
                  if (_imageFile != null)
                    Icon(Icons.check_circle, color: Colors.green) // Resim seçildiyse yeşil tik
                  else
                    Icon(Icons.cancel, color: Colors.red), // Resim seçilmediyse kırmızı x
                ],
              ),
            ),
            SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.greenAccent.shade400,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: _showMapDialog, // Harita dialogunu açar
              child: Text('Konum Seç',style: TextStyle(color: Colors.white)),
            ),

            if (_selectedLocation != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Seçilen Konum: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}'),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.greenAccent.shade400,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),

              ),
              onPressed: _submitForm,
              child: Text('Gönder',style: TextStyle(color: Colors.white)),

            ),
          ],
        ),
      ),
    );
  }
}
