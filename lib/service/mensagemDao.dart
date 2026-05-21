import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class MensagemDao {
  final CollectionReference _mensagens = FirebaseFirestore.instance.collection('mensagens');

  // Retorna a stream de mensagens para alimentar a UI
  Stream<QuerySnapshot> getMensagensStream() {
    return _mensagens.orderBy('time').snapshots();
  }

  // Método unificado para salvar texto
  Future<void> sendMessage({
    String? text,
    XFile? imgFile,
    required String uid,
    required String senderName,
    required String senderPhotoUrl,
  }) async {
    Map<String, dynamic> data = {
      'time': Timestamp.now(),
      'url': '',
      'text': '',
      'uid': uid,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
    };

    if (imgFile != null) {
      data['url'] = await uploadImage(imgFile);
    } else {
      data['text'] = text;
    }

    await _mensagens.add(data);
  }

  // upload
  Future<String> uploadImage(XFile imgFile) async {
    String imageUrl = "";
    try {
      firebase_storage.UploadTask uploadTask;
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("imgs")
          .child(DateTime.now().millisecondsSinceEpoch.toString());

      final metadados = firebase_storage.SettableMetadata(
          contentType: "image/jpeg",
          customMetadata: {"picked-file-path": imgFile.path});

      if (kIsWeb) {
        uploadTask = ref.putData(await imgFile.readAsBytes(), metadados);
      } else {
        uploadTask = ref.putFile(File(imgFile.path), metadados);
      }
      var taskSnapshot = await uploadTask;
      imageUrl = await taskSnapshot.ref.getDownloadURL();
    } catch (error) {
      print('Erro ao fazer upload da imagem: $error');
    }
    return imageUrl;
  }
}