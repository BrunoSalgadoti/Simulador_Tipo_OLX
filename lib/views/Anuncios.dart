import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:olx_app/main.dart';
import 'package:olx_app/models/Anuncio.dart';
import 'package:olx_app/util/Configuracoes.dart';
import 'package:olx_app/views/widgets/ItemAnuncio.dart';

class Anuncios extends StatefulWidget {
  const Anuncios({Key? key}) : super(key: key);

  @override
  State<Anuncios> createState() => _AnunciosState();
}

class _AnunciosState extends State<Anuncios> {

  List<String> itensMenu = [];
  late List<DropdownMenuItem<String>> _listaItensDropCategorias;
  late List<DropdownMenuItem<String>> _listaItensDropEstados;

  final _controler = StreamController<QuerySnapshot>.broadcast();
  String? _itemSelecionadoEstado;
  String? _itemSelecionadoCategoria;


  _deslogarUsuario() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();

    Navigator.pushNamed(context, "/login");
  }

  _escolhaMenuItem( String itemEscolhido ){

    switch( itemEscolhido ){
      case "Meus Anúncios" :
        Navigator.pushNamed(context, "/meus-anuncios");
        break;
      case "Entrar / Cadastrar" :
        Navigator.pushNamed(context, "/login");
        break;
      case "Deslogar" :
        _deslogarUsuario();
        break;
    }
  }

  Future<dynamic> _verificaUsuarioLogado() async{

    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = await auth.currentUser;

    if( usuarioLogado == null ){
      itensMenu = [
        "Entrar / Cadastrar"
      ];
    }else{
      itensMenu = [
        "Meus Anúncios", "Deslogar"
      ];
    }
  }

  _carregarItensDropdown(){

    //Categorias
    _listaItensDropCategorias = Configuracoes().getCategorias();

    //Estados
    _listaItensDropEstados = Configuracoes().getEstados();

  }

  Future<Stream<QuerySnapshot>?> _adicionarListenerAnuncios() async{

    FirebaseFirestore db = FirebaseFirestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("anuncios")
        .snapshots();

    stream.listen((dados) {
      _controler.add(dados);
    });
  }

  Future<Stream<QuerySnapshot>?> _filtrarAnuncios() async{

    FirebaseFirestore db = FirebaseFirestore.instance;
    Query query = db.collection("anuncios");

    if( _itemSelecionadoEstado != null){
      query = query.where("estado", isEqualTo:  _itemSelecionadoEstado);
    }
    if( _itemSelecionadoCategoria != null){
      query = query.where("categoria", isEqualTo:  _itemSelecionadoCategoria);
    }

    Stream<QuerySnapshot> stream = query.snapshots();
    stream.listen((dados) {
      _controler.add(dados);
    });
  }

  @override
  void initState() {
    super.initState();
    _carregarItensDropdown();
    _verificaUsuarioLogado();
    _adicionarListenerAnuncios();
  }

  @override
  Widget build(BuildContext context) {

    var carregandoDados = Center(
      child: Column(children: const [

        Text("Carregando Anúncios"),
        CircularProgressIndicator()
      ],
      ),);

    return Scaffold(

        appBar: AppBar(
          title: const Text("OLX"),
          elevation: 0,
          actions: [
            PopupMenuButton<String>(
                onSelected: _escolhaMenuItem,
                itemBuilder: (context){
                  return itensMenu.map(( String item ){
                    return PopupMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList();

                }
            )
          ],
        ),

        body: Column(
          children: [

            Row(children: [

              Expanded(
                  child: DropdownButtonHideUnderline(
                    child: Center(
                      child: DropdownButton(
                        iconEnabledColor: temaPadrao.primaryColor,
                        value: _itemSelecionadoEstado,
                        items: _listaItensDropEstados,
                        style: const TextStyle(
                            fontSize: 22,
                            color: Colors.black
                        ),
                        onChanged: (estado){
                          setState(() {
                            _itemSelecionadoEstado = estado as String?;
                            _filtrarAnuncios();
                          });
                        },
                      ),
                    ),
                  )),

              Container(
                color: Colors.grey[200],
                width: 2,
                height: 60,
              ),

              Expanded(
                  child: DropdownButtonHideUnderline(
                    child: Center(
                      child: DropdownButton(
                        iconEnabledColor: temaPadrao.primaryColor,
                        value: _itemSelecionadoCategoria,
                        items: _listaItensDropCategorias,
                        style: const TextStyle(
                            fontSize: 22,
                            color: Colors.black
                        ),
                        onChanged: (categoria){
                          setState(() {
                            _itemSelecionadoCategoria = categoria as String?;
                            _filtrarAnuncios();
                          });
                        },
                      ),
                    ),
                  )),
            ],),

            StreamBuilder(
                stream: _controler.stream,
                builder: (context, AsyncSnapshot){

                  switch ( AsyncSnapshot.connectionState ){

                    case ConnectionState.none :
                    case ConnectionState.waiting:
                      return carregandoDados;

                    case ConnectionState.active:
                    case ConnectionState.done:

                      QuerySnapshot?  querySnapshot = AsyncSnapshot.data as QuerySnapshot<Object?>?;

                      if( querySnapshot!.docs.isEmpty ){
                        return Container(
                          padding: EdgeInsets.all(25),
                          child: const Text("Nenhum anúncio :( ",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            ),),
                        );
                      }

                      return Expanded(
                          child: ListView.builder(
                              itemCount: querySnapshot.docs.length,
                              itemBuilder: (_, indice){

                                List<DocumentSnapshot> anuncios = querySnapshot.docs.toList();
                                DocumentSnapshot documentSnapshot = anuncios[indice];
                                Anuncio anuncio = Anuncio.fromDocumentSnapshot(documentSnapshot);

                                return ItemAnuncio(
                                  anuncio: anuncio,
                                  onTapItem: (){
                                    Navigator.pushNamed(
                                        context,
                                        "/detalhes-anuncio",
                                        arguments: anuncio
                                    );
                                  },
                                );
                              })
                      );
                  }
                }
            ),
          ],)
    );
  }
}
