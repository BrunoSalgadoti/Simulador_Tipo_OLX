import 'package:flutter/material.dart';
import 'package:brasil_fields/brasil_fields.dart';

class Configuracoes {

  List<DropdownMenuItem<String>> getEstados (){

    List<DropdownMenuItem<String>> listaItensDropEstados = [];

    //Regiões
    listaItensDropEstados.add(
        const DropdownMenuItem(child:Text(
          "Região", style: TextStyle(
            color: Color(0xff9c27b0)
        ),
        ), value: null,));

    for( var estado in Estados.listaEstadosSigla){
      listaItensDropEstados.add(
          DropdownMenuItem(child: Text(estado), value: estado,)
      );
    }
    return listaItensDropEstados;

  }

  List<DropdownMenuItem<String>> getCategorias (){

    List<DropdownMenuItem<String>> itensDropCategorias = [];

    //Categorias

    /* OBS:
    (Melhor iserir as categorias direto no firebase caso precise
     modificar um campo ou inserir outro, não precisa republicar o APP
    desta forma só atualizar o Firebase e não tem que publicar uma nova versão
    do APP só para isso)
     */

    itensDropCategorias.add(
        const DropdownMenuItem(child:Text(
          "Categoria", style: TextStyle(
            color: Color(0xff9c27b0)
        ),
        ), value: null,));

    itensDropCategorias.add(
        const DropdownMenuItem(child:Text("Automóvel"), value: "auto",));

    itensDropCategorias.add(
        const DropdownMenuItem(child:Text("Imóvel"), value: "imovel",));

    itensDropCategorias.add(
        const DropdownMenuItem(child:Text("Móveis"), value: "movel",));

    itensDropCategorias.add(
        const DropdownMenuItem(child: Text("Eletrônicos"), value: "eletro",));

    itensDropCategorias.add(
        const DropdownMenuItem(child:Text("Moda"), value: "moda",));

    itensDropCategorias.add(
        const DropdownMenuItem(child:Text("Esportes"), value: "esportes",));

    itensDropCategorias.add(
        const DropdownMenuItem(child:Text("Aluguel"), value: "aluguel",));

    itensDropCategorias.add(
        const DropdownMenuItem(child:Text("Negócios"), value: "negocios",));

    return itensDropCategorias;

  }

}