import 'package:flutter/material.dart';

class AppTheme {
  static const blue=Color(0xFF3157E8), bg=Color(0xFFF7F8FA), ink=Color(0xFF171A21), muted=Color(0xFF6D7480), green=Color(0xFF14966B), amber=Color(0xFFF59E0B), red=Color(0xFFDC3D4B);
  static ThemeData light()=>ThemeData(useMaterial3:true,scaffoldBackgroundColor:bg,colorScheme:ColorScheme.fromSeed(seedColor:blue),fontFamily:'Inter',appBarTheme:const AppBarTheme(backgroundColor:bg,foregroundColor:ink,elevation:0),cardTheme:const CardTheme(color:Colors.white,elevation:0,margin:EdgeInsets.zero,shape:RoundedRectangleBorder(borderRadius:BorderRadius.all(Radius.circular(18)),side:BorderSide(color:Color(0xFFE9EBEF)))),inputDecorationTheme:const InputDecorationTheme(filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(14)),borderSide:BorderSide.none),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(14)),borderSide:BorderSide(color:Color(0xFFE9EBEF))),contentPadding:EdgeInsets.symmetric(horizontal:16,vertical:15));
}
