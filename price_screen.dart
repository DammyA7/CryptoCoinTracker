import 'package:flutter/material.dart';
import 'coin_data.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'dart:convert';
import 'package:http/http.dart' as http;

const apiKey = '7F2EA27D-6542-4040-8D4A-618C4EC9438E';
class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String selectedCurrency = 'USD';
  Map<String, dynamic> cryptoRate = {};

  DropdownButton<String> androidDropDown(){
    List<DropdownMenuItem<String>> dropDownItems = [];
    for(int i = 0; i<currenciesList.length;i++){
      String currency = currenciesList[i];
      var newItem = DropdownMenuItem(
        child: Text(currency),
        value: currency,
      );
      dropDownItems.add(newItem);
    }
    return DropdownButton<String>(
        value: selectedCurrency,
        items: dropDownItems,
        onChanged: (value) {
          setState(() {
            selectedCurrency = value;
            getCoinData();
          });
        });
  }

  CupertinoPicker IOSPicker(){
    List<Text> currencies = [];
    for(String currency in currenciesList){
      currencies.add(Text(currency));
    }

    return CupertinoPicker(
      itemExtent: 32,
      onSelectedItemChanged: (itemIndex){
      print(itemIndex);
      },
      children: currencies,
    );
  }

  Widget getPicker() {
    if(Platform.isIOS){
      return IOSPicker();
    }
    else{
      return androidDropDown();
    }
  }

  Future getData(String crypto, String fiat) async {
    String url = 'https://rest.coinapi.io/v1/exchangerate/$crypto/$fiat?apikey=$apiKey';
    http.Response response = await http.get(Uri.parse(url));
    if(response.statusCode == 200){
      var data = response.body;
      var value = (jsonDecode(data)['rate']);
      return value;
    }
    else{
      print(response.statusCode);
    }
  }

  void getCoinData() async {
    for(int i = 0; i < cryptoList.length; i++) {
      cryptoRate[cryptoList[i]] = await getData(cryptoList[i], selectedCurrency);
    }
    setState(() {
      for(int i = 0; i < cryptoList.length; i++){
        double convert = cryptoRate[cryptoList[i]];
        cryptoRate.update(cryptoList[i], (value) => convert.toStringAsFixed(2));
      }
    });
  }

  Widget blueCard(String crypto, String rate) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
      child: Card(
        color: Colors.lightBlueAccent,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
          child: TextWidget(selectedCurrency: selectedCurrency, crypto: crypto, rate: rate),
        ),
      ),
    );
  }

  void initState() {
    super.initState();
    getCoinData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < cryptoList.length; i++) blueCard(cryptoList[i], cryptoRate[cryptoList[i]] ?? 'loading...'),
          SizedBox(height: 80,),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.lightBlue,
            child: getPicker()
          ),
        ],
      ),
    );
  }
}

class TextWidget extends StatelessWidget {
  const TextWidget({
    Key key,
    @required this.selectedCurrency,
    @required this.rate,
    @required this.crypto
  });

  final String selectedCurrency;
  final String rate;
  final String crypto;
  @override
  Widget build(BuildContext context) {
    return Text(
      '1 $crypto = $rate $selectedCurrency',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20.0,
        color: Colors.white,
      ),
    );
  }
}






