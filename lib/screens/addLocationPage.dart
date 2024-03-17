import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;


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


  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _featureController.dispose();
    _cityController.dispose();
    super.dispose();
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


  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String city = _cityController.text;
      String imageUrl = '';
      if (_imageFile != null) {
        imageUrl = await _uploadImageToStorage(File(_imageFile!.path));
      }

      // Firestore koleksiyonuna yeni bir mekan ekleyin
      await FirebaseFirestore.instance.collection('cities/$city/location').add({
        'name': _nameController.text,
        'adress': _addressController.text,
        'feature': _featureController.text,
        'image': imageUrl,
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
      appBar: AppBar(title: Text('Mekan Öner')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'Şehir Adı'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Şehir adı boş bırakılamaz';
                  }
                  final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
                  if (!validCharacters.hasMatch(value)) {
                    return 'Geçersiz karakterler içermemelidir (Özel semboller, Türkçe karakterler vs.)';
                  }
                  return null;
                }),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Mekan Adı'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Mekan adı boş bırakılamaz';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Adres'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Adres boş bırakılamaz';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _featureController,
              decoration: InputDecoration(labelText: 'Özellikler'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Özellikler boş bırakılamaz';
                }
                return null;
              },
            ),

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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Gönder'),
            ),
          ],
        ),
      ),
    );
  }
}
