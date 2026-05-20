import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatComposer extends StatefulWidget {
  final Function({String? text, XFile? imgFile}) onSendMessage;

  const ChatComposer({Key? key, required this.onSendMessage}) : super(key: key);

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;
  final ImagePicker picker = ImagePicker();

  void _reset() {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: const IconThemeData(color: Colors.cyan),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.photo_camera),
              onPressed: () async {
                final img = await picker.pickImage(source: ImageSource.camera);
                if (img == null) return;
                widget.onSendMessage(imgFile: img);
              },
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration.collapsed(hintText: "Enviar uma mensagem"),
                onChanged: (text) {
                  setState(() {
                    _isComposing = text.isNotEmpty;
                  });
                },
                onSubmitted: (text) {
                  if (_isComposing) {
                    widget.onSendMessage(text: text);
                    _reset();
                  }
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isComposing
                    ? () {
                  widget.onSendMessage(text: _textController.text);
                  _reset();
                }
                    : null,
              ),
            )
          ],
        ),
      ),
    );
  }
}