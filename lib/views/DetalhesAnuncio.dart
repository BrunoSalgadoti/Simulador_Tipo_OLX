import 'package:flutter/material.dart';
import 'package:olx_app/main.dart';
import 'package:olx_app/models/Anuncio.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:core';
import 'package:oa_fone/oa_fone.dart';

class DetalhesAnuncio extends StatefulWidget {

  Anuncio anuncio;
  DetalhesAnuncio(this.anuncio);

  @override
  State<DetalhesAnuncio> createState() => _DetalhesAnuncioState();
}

class _DetalhesAnuncioState extends State<DetalhesAnuncio> {

  late Anuncio _anuncio;

  List<Widget> _getListaImagens (){

    List<String> listaUrlImagens = _anuncio.fotos;
    return listaUrlImagens.map((url) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(url),
              fit: BoxFit.fitWidth,
            )
        ),
      );
    }).toList();
  }

  Future<dynamic> _ligarTelefone( String telefone, BuildContext context) async {

    ligarPaciente(
        'tel:${telefone.toString()}', context);
  }

  @override
  void initState() {
    super.initState();
    _anuncio =  widget.anuncio;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Anuncio"),
      ),

      body: Stack(children: [

        ListView(children: [

          SizedBox(
            height: 250,
            child: CarouselSlider(
                items: _getListaImagens(),
                options: CarouselOptions(
                  padEnds: true,
                  height: 400,
                  aspectRatio: 16/9,
                  initialPage: 0,
                  enableInfiniteScroll: false,
                  autoPlayCurve: Curves.bounceIn,
                  enlargeCenterPage: true,
                  clipBehavior: Clip.antiAlias,
                  //onPageChanged: callbackFunction,
                  scrollDirection: Axis.horizontal,
                )
            ),
          ),

          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Text(
                  "R\$ ${_anuncio.preco}",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: temaPadrao.primaryColor
                  ),),

                Text(
                  "${_anuncio.titulo}",
                  style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w400
                  ),),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),

                const Text(
                  "Descrição",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),),

                Text(
                  "${_anuncio.descricao}",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 25),
                  child: Divider(),
                ),

                const Text(
                  "Contato",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),),

                Padding(
                  padding: EdgeInsets.only(bottom: 66),
                  child: Text(
                    "${_anuncio.telefone}",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),),
                )
              ],),
          )
        ],),

        Positioned(
          left: 16,
          right: 16,
          bottom: 38,
          child: GestureDetector(
            child: Container(
              child: const Text(
                "Ligar",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),

              ),
              padding: EdgeInsets.all(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: temaPadrao.primaryColor,
                  borderRadius: BorderRadius.circular(30)
              ),
            ),
            onTap: (){
              _ligarTelefone( _anuncio.telefone, context);
            },
          ),
        )

      ],),
    );
  }
}
