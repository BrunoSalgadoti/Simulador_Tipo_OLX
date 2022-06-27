import 'package:flutter/material.dart';
import 'package:olx_app/views/Anuncios.dart';
import 'package:olx_app/views/DetalhesAnuncio.dart';
import 'package:olx_app/views/Login.dart';
import 'package:olx_app/views/MeusAnuncios.dart';
import 'package:olx_app/views/NovoAnuncio.dart';

class RouteGenerator {

  static Route<dynamic>? generateRoute(RouteSettings settings){

    dynamic args = settings.arguments;

    switch( settings.name ){

      case "/" :
        return MaterialPageRoute(
          builder:(_) => Anuncios(),
        );

      case "/login" :
        return MaterialPageRoute(
          builder:(_) => Login(),
        );

      case "/meus-anuncios" :
        return MaterialPageRoute(
          builder:(_) => MeusAnuncios(),
        );

      case "/novo-anuncio" :
        return MaterialPageRoute(
          builder:(_) => NovoAnuncio(),
        );

      case "/detalhes-anuncio" :
        return MaterialPageRoute(
          builder:(_) => DetalhesAnuncio(args),
        );

      default:
        _erroRota();
    }
  }

  static Route<dynamic> _erroRota(){

    return MaterialPageRoute(
        builder: (_){

          return Scaffold(
            appBar: AppBar(
              title: const Text("Tela não encontrada!"),
            ),

            body: const Center(
              child: Text("Tela não encontrada!"),
            ),
          );
        }
    );
  }

}