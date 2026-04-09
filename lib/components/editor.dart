import 'package:flutter/material.dart';

class Editor extends StatelessWidget {
  final TextEditingController controlador;
  final String rotulo;
  final String hint;
  final IconData? icone;
  final String? msgErro; // parâmetro para a mensagem de validação

  Editor(this.controlador, this.rotulo, this.hint, [this.icone, this.msgErro]);

  @override
  Widget build(BuildContext context) {
    // trocado o TextField por TextFormField
    return TextFormField(
      controller: controlador,
      style: TextStyle(fontSize: 18.0),
      decoration: InputDecoration(
        icon: icone != null ? Icon(icone) : null,
        labelText: rotulo,
        hintText: hint,
      ),
      validator: (value) {
        if (msgErro != null && (value == null || value.isEmpty)) {
          return msgErro;
        }
        return null;
      },
    );
  }
}