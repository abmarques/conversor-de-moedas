import 'package:flutter/material.dart';

import 'package:http/http.dart' as http; //Permitir as requisições
import 'dart:async'; //Perimitir requisições de modo assíncrono sem travar o programa
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?key=ef3385e2"; //Requisição com API da HG FINANCE BRASIL

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber))        
      )  
    )
  ));
}

Future<Map> getData() async{
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text){
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text){
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar/euro).toStringAsFixed(2);
  }
  void _euroChanged(String text){
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    dolarController.text = (euro * this.euro/dolar).toStringAsFixed(2);
    realController.text = (euro * this.euro).toStringAsFixed(2);
  }

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor de Moedas \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando Dados...",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                textAlign: TextAlign.center,)
              );
            default:
              if(snapshot.hasError){
                return Center(
                  child: Text("Erro ao Carregar Dados :(",
                    style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25.0),
                    textAlign: TextAlign.center,)
                );
            }else {

              dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
              euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

              return SingleChildScrollView(
                
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[                 
                    Icon(Icons.monetization_on, size: 150.0, color: Colors.amber),
                    buildTextField("Real", "R\$", realController, _realChanged),
                    Divider(),
                    buildTextField("Dolar", "US\$", dolarController, _dolarChanged),
                    Divider(),
                    buildTextField("Euro", "€", euroController, _euroChanged)
                ]),
              );
            }
          }
        }
      ),
    );
  }
}

Widget buildTextField(String labelText, String preFixText, TextEditingController txtEdtController, Function valueChanged){
  return TextField(
    
    controller: txtEdtController,
    decoration: InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: preFixText
    ),
    style: TextStyle(
      color: Colors.amber, fontSize: 25.0
    ),
    onChanged: valueChanged,
    keyboardType: TextInputType.number,
  ); 
}