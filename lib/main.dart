import 'package:flutter/material.dart';
import 'package:olx_app/RouteGenerator.dart';
import 'package:olx_app/views/Anuncios.dart';
import 'package:firebase_core/firebase_core.dart';


final ThemeData temaPadrao = ThemeData(
    primaryColor: const Color(0xff9c27b0),
    appBarTheme:const AppBarTheme (
      backgroundColor: Color(0xff7b1fa2),
    ));


void main() async {

  //Iniciar o Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  runApp( MaterialApp(
        title: "Aula OLX Ûdemy",

        home: Anuncios(),

        theme: temaPadrao,

        initialRoute: "/",
        onGenerateRoute: RouteGenerator.generateRoute,

        debugShowCheckedModeBanner: false,
      )) ;
  }

