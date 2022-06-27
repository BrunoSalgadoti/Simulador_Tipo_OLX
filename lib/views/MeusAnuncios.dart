import 'dart:async';
import 'package:flutter/material.dart';
import 'package:olx_app/models/Anuncio.dart';
import 'package:olx_app/views/widgets/BotaoCustomizado.dart';
import 'package:olx_app/views/widgets/ItemAnuncio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MeusAnuncios extends StatefulWidget {
  const MeusAnuncios({Key? key}) : super(key: key);

  @override
  State<MeusAnuncios> createState() => _MeusAnunciosState();
}

class _MeusAnunciosState extends State<MeusAnuncios> {

  final _controller = StreamController<QuerySnapshot>.broadcast();
  dynamic _idUsuarioLogado;

  Future<dynamic> _recuperarDadosUsuarioLogado() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = await auth.currentUser;
    _idUsuarioLogado = usuarioLogado!.uid;

  }

  Future<Stream<QuerySnapshot<Object?>>?> _adicionarListenerAnuncios() async{

    await _recuperarDadosUsuarioLogado();

    FirebaseFirestore db = FirebaseFirestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("meus_anuncios")
        .doc( _idUsuarioLogado )
        .collection("anuncios")
        .snapshots();

    stream.listen((dados) {
      _controller.add( dados );
    });

  }

  _removerAnuncio( String idAnuncio ){

    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("meus_anuncios")
        .doc( _idUsuarioLogado )
        .collection("anuncios")
        .doc( idAnuncio)
        .delete().then((_) {

      db.collection("anuncios")
          .doc( idAnuncio)
          .delete();
    });
  }

  @override
  void initState() {
    super.initState();
    _adicionarListenerAnuncios();
  }

  @override
  Widget build(BuildContext context) {

    var carregandoDados = Center(
      child: Column(children: const [
        Text("Carregando anúncios..."),
        CircularProgressIndicator()
      ],),
    );

    return Scaffold(

      appBar: AppBar(
        title: const Text("Meus anúncios"),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text("Adicionar"),
        onPressed: (){
          Navigator.pushNamed(context, "/novo-anuncio");
        },
      ),

      body: StreamBuilder(
          stream: _controller.stream,
          builder: (context, snapshot){

            switch(snapshot.connectionState){

              case ConnectionState.none:
              case ConnectionState.waiting:
                return carregandoDados;
                break;
              case ConnectionState.active:
              case ConnectionState.done:

              //Exibir mensagens de erro
                if( snapshot.hasError) {
                  return const Text("Erro ao carregar os dados!!");
                }

                QuerySnapshot? querySnapshot = snapshot.data as QuerySnapshot<Object?>?;

                return ListView.builder(
                    itemCount: querySnapshot!.docs.length,
                    itemBuilder: (_, indice){

                      List<DocumentSnapshot> anuncios = querySnapshot.docs.toList();
                      DocumentSnapshot documentSnapshot = anuncios[indice];
                      Anuncio anuncio = Anuncio.fromDocumentSnapshot(documentSnapshot);

                      return ItemAnuncio(
                        anuncio: anuncio,
                        onPressedRemover: (){
                          showDialog(
                              context: context,
                              builder: (context){
                                return AlertDialog(
                                  title: const Text("Confirmar"),
                                  content: const Text("Deseja realmente Excluir o anúncio?"),
                                  actions: [

                                    BotaoCustomizado(
                                      texto: "Cancelar",
                                      corBotao: Colors.white,
                                      corTexto: Colors.grey,
                                      onPressed: (){
                                        Navigator.of(context).pop();
                                      },
                                    ),

                                    BotaoCustomizado(
                                      texto: "Remover",
                                      corBotao: Colors.red,
                                      corTexto: Colors.white,
                                      onPressed: (){
                                        _removerAnuncio( anuncio.id);
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                              }
                          );
                        },
                      );
                    },
                    padding: EdgeInsets.only(bottom: 63)
                );
            }
          }
      ),
    );
  }
}
