import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olx_app/models/Anuncio.dart';
import 'package:olx_app/util/Configuracoes.dart';
import 'package:olx_app/views/widgets/BotaoCustomizado.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:olx_app/views/widgets/InputCustomizado.dart';
import 'package:validadores/validadores.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class NovoAnuncio extends StatefulWidget {
  const NovoAnuncio({Key? key}) : super(key: key);

  @override
  State<NovoAnuncio> createState() => _NovoAnuncioState();
}

class _NovoAnuncioState extends State<NovoAnuncio> {

  final List<File> _listaImagens = [];
  List<DropdownMenuItem<String>> _listaItensDropEstados = [];
  List<DropdownMenuItem<String>> _listaItensDropCategorias = [];
  final _formKey = GlobalKey<FormState>();
  Anuncio? _anuncio;
  BuildContext? _dialogContext;

  String? _itemSelecionadoEstado;
  String? _itemSelecionadoCategoria;

  Future<dynamic> _selecionarImagemGaleria( ) async {

    String origemImagem = "";

    showDialog(
        context: context,
        builder:  (context){
          return AlertDialog(
            title: const Text("Selecionar imagem"),
            content: const Text("Escolha o local de onde \n quer inserir a foto"),
            contentPadding: const EdgeInsets.all(16),
            actions: <Widget> [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[

                    BotaoCustomizado(
                        corBotao: Colors.white,
                        corTexto: Colors.blue,
                        corShadow: Colors.black,
                        elevation: 9,
                        texto: "Galeria",
                        onPressed: () {
                          setState(() {
                            origemImagem = "galeria";
                          });
                          Navigator.pop(context);
                        }),

                    BotaoCustomizado(
                        corBotao: Colors.white,
                        corTexto: Colors.deepPurpleAccent,
                        corShadow: Colors.black,
                        elevation: 9,
                        texto: "Câmera",
                        onPressed: () {
                          setState(() {
                            origemImagem = "camera";
                          });
                          Navigator.pop(context);
                        }),
                  ])
            ],
          );
        }
    ).whenComplete(() async  {

      ImagePicker Piker = ImagePicker();

      XFile? imagemSelecionada;

      if( origemImagem == "camera" ) {
        imagemSelecionada =  await Piker.pickImage(source: ImageSource.camera);
      }else if( origemImagem == "galeria") {
        imagemSelecionada = await Piker.pickImage(source: ImageSource.gallery);
      }

      dynamic imagem = File(imagemSelecionada!.path);

      setState(() {
        _listaImagens.add( imagem );
      });
    });
  }

  _abrirDialog (BuildContext context){

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: ( BuildContext context){
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 20,width: 20,),
                Text("Salvando anúncio...")
              ],),
          );}
    );
  }

  Future<dynamic> _salvaAnuncio() async{

    _abrirDialog( _dialogContext! );

    //Upload Imagem no Storage
    await _uploadImagem();

    //Salvar anuncio no Firebase
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;
    dynamic idUsuarioLogado = usuarioLogado!.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection( "meus_anuncios" )
        .doc( idUsuarioLogado )
        .collection( "anuncios" )
        .doc( _anuncio!.id )
        .set( _anuncio!.toMap()).then((_) {

      //Salvar anúncio público
      db.collection("anuncios")
          .doc( _anuncio!.id)
          .set( _anuncio!.toMap() ).then((_) {

        Navigator.pop(_dialogContext!);
        Navigator.pop(context);

      });
    });
  }

  Future<dynamic> _uploadImagem( ) async {

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();

    for( dynamic imagem in _listaImagens ) {

      dynamic nomeImagem = DateTime.now().microsecondsSinceEpoch.toString();
      Reference arquivo = pastaRaiz
          .child('meus_anuncios')
          .child(_anuncio!.id)
          .child( nomeImagem);

      //upload da imagem
      UploadTask uploadTask = arquivo.putFile(imagem);
      TaskSnapshot taskSnapshot = await uploadTask;

      dynamic url = await taskSnapshot.ref.getDownloadURL();
      _anuncio?.fotos.add(url);
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarItensDropdown();

    _anuncio = Anuncio.gerarId();
  }

  _carregarItensDropdown(){

    //Categorias
    _listaItensDropCategorias = Configuracoes().getCategorias();

    //Estados
    _listaItensDropEstados = Configuracoes().getEstados();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Novo anúncio"),
      ),

      body: SingleChildScrollView(

        child: Container(
          padding: const EdgeInsets.all(16),

          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                //Àrea de imagens
                FormField<List>(
                  initialValue: _listaImagens,
                  validator: ( imagens ){
                    if( imagens?.length == 0 ){
                      return "Necessário selecionar uma imagem!";
                    }
                    return null;
                  },
                  builder: ( state ){
                    return Column(children: [
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _listaImagens.length + 1,
                            itemBuilder: (context, indice){

                              if( indice == _listaImagens.length ){
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),

                                  child: GestureDetector(
                                    onTap: (){
                                      _selecionarImagemGaleria();
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey[400],
                                      radius: 50,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,

                                        children: [
                                          Icon(
                                            Icons.add_a_photo,
                                            size: 40,
                                            color: Colors.grey[100],
                                          ),
                                          Text(
                                            "Adicionar",
                                            style: TextStyle(
                                                color: Colors.grey[100]
                                            ),
                                          )
                                        ],),
                                    ),
                                  ),
                                );
                              }
                              if( _listaImagens.length > 0 ){
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),

                                  child: GestureDetector(
                                      onTap: (){
                                        showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Image.file(_listaImagens[indice] ),
                                                  BotaoCustomizado(
                                                    texto: "Excluir",
                                                    corTexto: Colors.red,
                                                    corBotao: Colors.white,
                                                    elevation: 0,
                                                    onPressed: (){
                                                      setState(() {
                                                        _listaImagens.removeAt(indice);
                                                        Navigator.pop(context);
                                                      });
                                                    },

                                                  )
                                                ],),
                                            )
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundImage: FileImage(_listaImagens[indice]),
                                        child: Container(
                                          color: const Color.fromRGBO(255, 255, 255, 0.4),
                                          alignment: Alignment.center,
                                          child: const Icon( Icons.delete, color: Colors.red,),
                                        ),
                                      )
                                  ),
                                );

                              }
                              return Container();
                            }),
                      ),
                      if( state.hasError )
                        Text(
                          "[${state.errorText}]",
                          style: const TextStyle(
                              color: Colors.red, fontSize: 16
                          ),
                        ),
                    ],);
                  },
                ),

                //Menus Dropdown
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: DropdownButtonFormField<String>(
                          value: _itemSelecionadoEstado,
                          hint:  const Text("Estados"),
                          onSaved: (estado){
                            _anuncio?.estado = estado!;
                          },
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20
                          ),
                          items:  _listaItensDropEstados,
                          validator: (valor){
                            return Validador()
                                .add(Validar.OBRIGATORIO, msg: "Campo obrigatóirio")
                                .valido(valor);
                          },
                          onChanged: (valor){
                            setState(() {
                              _itemSelecionadoEstado = valor.toString();
                            });
                          },
                        ),
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: DropdownButtonFormField<String>(
                          value: _itemSelecionadoCategoria,
                          hint:  const Text("Categorias"),
                          onSaved: (categoria){
                            _anuncio?.categoria = categoria!;
                          },
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20
                          ),
                          items:  _listaItensDropCategorias,
                          validator: (valor){
                            return Validador()
                                .add(Validar.OBRIGATORIO, msg: "Campo obrigatóirio")
                                .valido(valor);
                          },
                          onChanged: (valor){
                            setState(() {
                              _itemSelecionadoCategoria = valor.toString();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                //Caixa de textos e botoes
                Padding(
                  padding: const EdgeInsets.only(bottom: 15, top: 15),
                  child: InputCustomizado(
                      controllerLog1: null,
                      hint: "Título",
                      label: "Título",
                      onSaved: (titulo){
                        _anuncio?.titulo = titulo!;
                      },
                      validator: (valor){
                        return Validador()
                            .add(Validar.OBRIGATORIO, msg: "Campo obrigatóirio")
                            .valido(valor);
                      }),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: InputCustomizado(
                      controllerLog1: null,
                      hint:"Preço",
                      label: "Preço",
                      onSaved: (preco){
                        _anuncio?.preco = preco!;
                      },
                      type: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CentavosInputFormatter(casasDecimais: 2),
                      ],
                      validator: (valor){
                        return Validador()
                            .add(Validar.OBRIGATORIO, msg: "Campo obrigatóirio")
                            .valido(valor);
                      }),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: InputCustomizado(
                    controllerLog1: null,
                    hint: "Telefone",
                    label: "Telefone",
                    onSaved: (telefone){
                      _anuncio?.telefone = telefone!;
                    },
                    type: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TelefoneInputFormatter(),

                    ],
                    validator: (valor){
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: "Campo obrigatóirio")
                          .valido(valor);
                    },),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: InputCustomizado(
                    controllerLog1: null,
                    hint: "Descrição (200 caracteres)",
                    label: "Descrição (200 caracteres)",
                    onSaved: (descricao){
                      _anuncio?.descricao = descricao!;
                    },
                    maxLines: null,
                    validator: (valor){
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: "Campo obrigatóirio")
                          .maxLength(200, msg: "Máximo de 200 caracteres")
                          .valido(valor);
                    },),
                ),

                BotaoCustomizado(
                  texto: "Cadastrar anúncio",
                  onPressed: (){
                    if( _formKey.currentState!.validate() ){

                      //Salvar Campos
                      _formKey.currentState!.save();

                      //Configura dialog context
                      _dialogContext = context;

                      //salvar anúncios
                      _salvaAnuncio();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
