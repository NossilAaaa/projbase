import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage extends StatelessWidget {
  final DocumentSnapshot<Object?> data;
  final bool mine;

  const ChatMessage({Key? key, required this.data, required this.mine}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: <Widget>[
          !mine
              ? Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: Image.network(data.get('senderPhotoUrl')).image,
            ),
          )
              : Container(),
          Expanded(
            child: Column(
              crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                data.get('url') != ""
                    ? Image.network(data.get("url"), width: 150)
                    : Text(
                  data.get('text'),
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  data.get("senderName"),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
          mine
              ? Padding(
            padding: const EdgeInsets.only(left: 16),
            child: CircleAvatar(
              backgroundImage: Image.network(data.get('senderPhotoUrl')).image,
            ),
          )
              : Container(),
        ],
      ),
    );
  }
}