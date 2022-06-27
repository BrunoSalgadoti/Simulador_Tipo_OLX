import 'package:flutter/material.dart';

class BotaoCustomizado extends StatelessWidget {


  final dynamic texto;
  final Color corTexto;
  final Color corBotao;
  final Color corShadow;
  final VoidCallback? onPressed;
  final double fontSize;
  final double elevation;


  BotaoCustomizado({
    @required this.texto,
    this.onPressed,
    this.corTexto = Colors.white,
    this.corBotao = Colors.purple,
    this.corShadow = Colors.white24,
    this.fontSize = 20,
    this.elevation = 08
  });

  @override
  Widget build(BuildContext context) {

    return ElevatedButton(
        onPressed: this.onPressed,

        child: Text(
          this.texto,
          style: TextStyle(
              color: this.corTexto,
              fontSize: this.fontSize
          ),
        ),
        style: ElevatedButton.styleFrom(
            primary: this.corBotao,
            shadowColor: this.corShadow,
            elevation: this.elevation,
            padding:  const EdgeInsets.fromLTRB(32, 16, 32, 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
            ))
    );
  }
}
