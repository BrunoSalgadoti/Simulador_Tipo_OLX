import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class InputCustomizado extends StatelessWidget {

  TextEditingController? controllerLog1 = TextEditingController();
  TextEditingController? controllerLog2 = TextEditingController();
  final String hint = "";
  final String label;
  final bool  obscure;
  final bool autofocus;
  final TextInputType type;
  final dynamic maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final String? Function(String?)? onSaved;


  InputCustomizado({
    this.controllerLog1,
    this.controllerLog2,
    required hint,
    this.label = "",
    this.obscure = false,
    this.autofocus = false,
    this.type = TextInputType.text,
    this.inputFormatters = const [],
    this.validator,
    this.maxLines = 1,
    this.onSaved

  }
      );

  @override
  Widget build(BuildContext context) {

    return TextFormField(
      controller: controllerLog1,
      obscureText: this.obscure,
      autofocus: this.autofocus,
      keyboardType: this.type,
      inputFormatters: this.inputFormatters,
      maxLines: this.maxLines,
      validator: this.validator,
      onSaved: this.onSaved,
      style:  const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.normal
      ),

      decoration: InputDecoration(
          contentPadding:  EdgeInsets.fromLTRB( 32, 16, 32, 16),
          hintText: this.hint,
          labelText: this.label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6)
          )
      ),
    );
  }
}
