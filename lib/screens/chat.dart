import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../components/chat_message.dart';
import '../components/chat_composer.dart';
import '../service/mensagemDao.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  User? _currentUser;
  bool _isLoading = false;
  final MensagemDao _mensagemDao = MensagemDao();

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  // Passa essa função para o ChatComposer
  void _handleSendMessage({String? text, XFile? imgFile}) async {
    if (_currentUser != null) {
      setState(() {
        _isLoading = true;
      });

      // Se a foto do Firebase Auth estiver nula, criamos um avatar genérico
      String photoUrl = _currentUser?.photoURL ??
          'https://ui-avatars.com/api/?name=${_currentUser?.email}&background=E01C2F&color=fff';

      await _mensagemDao.sendMessage(
        text: text,
        imgFile: imgFile,
        uid: _currentUser!.uid,
        senderName: _currentUser!.email ?? 'Anônimo',
        senderPhotoUrl: photoUrl,
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentUser != null ? 'Olá, ${_currentUser?.email}' : 'Chat'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Apontando para o serviço DAO
              stream: _mensagemDao.getMensagensStream(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Center(child: CircularProgressIndicator());
                  default:
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("Nenhuma mensagem..."));
                    }
                    List<DocumentSnapshot> documents = snapshot.data!.docs.reversed.toList();
                    return ListView.builder(
                      itemCount: documents.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return ChatMessage(
                          data: documents[index],
                          mine: documents[index].get('uid') == _currentUser?.uid,
                        );
                      },
                    );
                }
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          ChatComposer(onSendMessage: _handleSendMessage),
        ],
      ),
    );
  }
}