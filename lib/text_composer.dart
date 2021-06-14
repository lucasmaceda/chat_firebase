import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  TextComposer(this.sendMessage);
  final Function({String text, File imgFile}) sendMessage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _isComposing = false;
  void _reset() {
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () async {
              PickedFile selectedFile =
                  await ImagePicker().getImage(source: ImageSource.camera);
              if (selectedFile == null) return;
              File selected = File(selectedFile.path);
              widget.sendMessage(imgFile: selected);
            },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration.collapsed(
                hintText: "Enviar uma mensagem",
              ),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                widget.sendMessage(text: text);
                _reset();
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _isComposing
                ? () {
                    widget.sendMessage(text: _controller.text);
                    _reset();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
