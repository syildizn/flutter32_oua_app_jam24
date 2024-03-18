import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProfilScreen extends StatefulWidget {
  static String routeName = "profilPage";
  const ProfilScreen({Key? key}) : super(key: key);

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  User? user = FirebaseAuth.instance.currentUser;
  String? _downloadUrl;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _uploadAndSaveImage();
    }
  }

  Future<void> _uploadAndSaveImage() async {
    if (_profileImage == null) return;

    String fileName = 'profile_${user!.uid}.jpg';
    firebase_storage.Reference ref =
    firebase_storage.FirebaseStorage.instance.ref('profile_images/$fileName');

    firebase_storage.UploadTask task = ref.putFile(_profileImage!);
    try {
      firebase_storage.TaskSnapshot snapshot = await task;
      _downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'image': _downloadUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profil fotoğrafı güncellendi")),
      );
    } on firebase_storage.FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Resim yükleme hatası: ${e.message}")),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen isim girin")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'name': _nameController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profil güncellendi")),
    );
  }

  Future<void> _loadUser() async {
    if (user == null) return;

    DocumentSnapshot document = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (document.exists) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = data['name'] ?? "";
        _downloadUrl = data['image'] ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(230, 237, 247, 1),
    appBar: AppBar(
    backgroundColor: Colors.deepOrange.shade300,
    title: Text(
    'Profil',
    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    ),
    body: ListView(
    padding: EdgeInsets.all(20),
    children: [
      CircleAvatar(
        radius: 50,
        backgroundColor: Colors.transparent,
        backgroundImage: _profileImage != null
            ? FileImage(_profileImage!)
            : (_downloadUrl != null && _downloadUrl!.isNotEmpty)
            ? NetworkImage(_downloadUrl!)
            : AssetImage('assets/images/anony.png') as ImageProvider,
        onBackgroundImageError: (_, __) {
          setState(() {
            // Eğer resim yüklenemiyorsa, varsayılan resmi kullan
            _downloadUrl = null;
          });
        },
      ),

      SizedBox(height: 20),
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.greenAccent.shade400,
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        textStyle:
        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    onPressed: _pickImage,
    child: Text('Profil Fotoğrafı Seç',style: TextStyle(color: Colors.white)),
    ),
      SizedBox(height: 50),
      TextField(
        controller: _nameController,
        decoration: InputDecoration(labelText: 'İsim',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,),
      ),
      SizedBox(height: 20),
      TextField(
        enabled: false,
        controller: TextEditingController(text: user?.email),
        decoration: InputDecoration(labelText: 'E-mail',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,),
      ),
      SizedBox(height: 40),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.greenAccent.shade400,
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          textStyle:
          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onPressed: _updateProfile,
        child: Text('Bilgileri Güncelle',style: TextStyle(color: Colors.white)),
      ),
    ],
    ),
    );
  }
}

