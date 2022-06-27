import 'package:flutter/material.dart';
import 'package:olx_app/models/Usuario.dart';
import 'package:olx_app/views/widgets/BotaoCustomizado.dart';
import 'package:olx_app/views/widgets/InputCustomizado.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();

  bool _cadastrar = false;
  String _mensagemErro = "";
  String _textoBotao = "Entrar";


  _validarCampos(){

    //Recupera dados dos campos
    String _email = _controllerEmail.text;
    String _senha = _controllerSenha.text;

    if( _email.isNotEmpty && _email.contains("@")) {

      if ( _senha.isNotEmpty && _senha.length > 6 ) {

        //Configurar Usuario
        Usuario usuario = Usuario();
        usuario.email = _email;
        usuario.senha = _senha;


        //Cadastrar ou Logar
        if( _cadastrar ){
          //Cadastrar
          _cadastrarUsuario(usuario);
        }else{
          //Logar
          _logarUsuario(usuario);
        }

      }else{
        setState(() {
          _mensagemErro = "Preencha a senha! digite mais de 6 caracteres";
        });
      }
    }else{
      setState(() {
        _mensagemErro = "Preencha com um e-mail válido";
      });
    }
  }

  _cadastrarUsuario( Usuario usuario ) {

    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;

    auth.createUserWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha
    ).then(( dynamic firebaseUser) {

      dynamic uid = auth.currentUser!.uid;

      db.collection("usuarios")
          .doc( uid.toString())
          .set( usuario.toMap());

      //redirecionar para tela principal
      Navigator.pushReplacementNamed(context, "/");

    }).catchError((error){
      _mensagemErro = "Erro ao autenticar o usuário, \n "
          "verifique os campos e tente novamente";});
  }

  _logarUsuario( Usuario usuario ) async {

    FirebaseAuth auth = FirebaseAuth.instance;

    auth.signInWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha
    ).then(( dynamic firebaseUser) {

      //redirecionar para tela principal
      Navigator.pushReplacementNamed(context, "/");

    }).catchError((error){
      _mensagemErro = "Usuário não existe, \n "
          "verifique os campos e tente novamente";});
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),

      body: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,

        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Padding(
                  padding:const EdgeInsets.only(bottom: 32),

                  child: Image.asset(
                    "imagens/logo.png",
                    width: 200,
                    height: 150,
                  ),
                ),

                InputCustomizado(
                  controllerLog1: _controllerEmail,
                  hint: "E-mail",
                  label: "E-mail",
                  autofocus: true,
                  type: TextInputType.emailAddress,
                ),
                const  Padding( padding: EdgeInsets.only(top: 12)),

                InputCustomizado(
                  controllerLog1: _controllerSenha,
                  hint: "Senha",
                  label: "Senha",
                  obscure: true,
                  type: TextInputType.text,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("logar"),
                    Switch(
                        value: _cadastrar,
                        onChanged: (bool valor){
                          setState(() {
                            _cadastrar = valor;
                            _textoBotao = "Entrar";
                            if ( _cadastrar  ){
                              _textoBotao = "Cadastrar";
                            }else{
                              _textoBotao = "logar";
                            }
                          });
                        }
                    ),
                    const Text("Cadastrar")
                  ],
                ),

                BotaoCustomizado(
                    texto: _textoBotao,
                    onPressed: (){ _validarCampos();}
                ),

                BotaoCustomizado(
                  texto: "Ir para anúncios",
                  corBotao: Colors.transparent,
                  corTexto: Colors.black,
                  onPressed: (){
                    Navigator.pushReplacementNamed(context, "/");
                  },
                ),

                Padding(padding: const EdgeInsets.only(top: 20),
                  child: Text( _mensagemErro,
                    style:  const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red
                    ),
                  ),

                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
