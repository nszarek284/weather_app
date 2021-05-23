
//paczki niezbędne do skompilowania aplikacji (np. http do pobierania danych z API)
import 'package:flutter/material.dart';
import 'package:weatherapp/all_weather_info.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//zmienne używane w obu widokach
int temperature = 0;
String location = 'Gliwice';
String weather = 'clear';
String APIKey = '048e59a8f8b286d0e889c03d84ce4a2f';
String iconID = '';
AllWeatherInfo weatherInfo;
Color textColor = Colors.black;
String timeSunset = '';
String timeSunrise = '';
String date = '';

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

//klasa, w której tworzony jest widok standardowy
class _WeatherAppState extends State<WeatherApp> {

//funkcja wywoływana po wprowadzeniu nazwy miasta
  void onTextFieldSubmitted(String text) {
    setState(() {
      location = text;
    });
    updateWeather();
  }
  //funkcja tworząca datę i godzinę w poprawnym formacje
  String setTimeFormat(int hour, int minute, String timeFormat, bool time) {
    if(hour % 10 == hour)
      timeFormat = '0' + hour.toString();
    else
      timeFormat = hour.toString();
    if(time)
      timeFormat +=":";
    else
      timeFormat +=".";
    if(minute % 10 == minute)
      timeFormat +='0' + minute.toString();
    else
      timeFormat += minute.toString();
    return timeFormat;
  }

  //funkcja nadająca wartości zmiennym na podstawie danych z API (oraz aktualnej dacie i godzinie)
  void updateWeather() {
    getWeather().then((value) {
      setState(() {
        weatherInfo = value;
        iconID = weatherInfo.weather.first.icon;
        date = setTimeFormat(DateTime.now().day, DateTime.now().month,date,false);
        timeSunset = setTimeFormat(weatherInfo.sys.sunset.hour, weatherInfo.sys.sunset.minute, timeSunset,true);
        timeSunrise = setTimeFormat(weatherInfo.sys.sunrise.hour, weatherInfo.sys.sunrise.minute, timeSunrise,true);
        if(iconID.indexOf('n') != -1) {
          weather = "night";
          textColor = Colors.white;
        }
        else {
          weather = "clear";
          textColor = Colors.black;
        }
      });
    });
  }

  //funkcja pobierająca dane z API
  Future<AllWeatherInfo> getWeather() async {
    var response = await http.get('https://api.openweathermap.org/data/2.5/weather?units=metric&q=$location&appid=$APIKey');

    if (response.statusCode >= 200 && response.statusCode < 300)
      return AllWeatherInfo.fromJson(json.decode(response.body));
    else
      return Future.error(response);
  }

  @override
  void initState() {
    super.initState();
    updateWeather();
  }
//budowa widoku
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              //ustawianie tła
              image: AssetImage('images/$weather.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: weatherInfo == null
              ? Center(child: CircularProgressIndicator())
              : Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    //pole do wprowadzania nazwy miasta
                    Container(
                      width: 300,
                      margin: EdgeInsets.only(top: 40.0, bottom: 20.0),
                      child: TextField(
                        onSubmitted: (String input) {
                          onTextFieldSubmitted(input);
                        },
                        style:
                        TextStyle(color: textColor, fontSize: 25),
                        decoration: InputDecoration(
                          //tekst wyświetlany, gdy pole jest puste
                            hintText: 'Search another location...',
                            hintStyle: TextStyle(
                                color: textColor, fontSize: 18.0),
                            //ikona lupy
                            prefixIcon:
                            Icon(Icons.search, color: textColor)
                        ),
                        cursorColor: textColor,

                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    //ikona prezentująca pogodę w danym dniu
                    Center(
                      child: Image.asset('images/$iconID.png', scale: 5, height: 150,),
                    ),
                    //krótki opis pogody
                    Center(
                        child: Text (
                          weatherInfo.weather.first.description,
                          style: TextStyle(
                              color: textColor, fontSize: 25.0,
                          ),
                        )
                    ),
                    //wyszukane miasto
                    Center(
                      child: Text(
                        location,
                        style: TextStyle(
                            color: textColor, fontSize: 50.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    //aktualna data w formacie [dzien.miesiac]
                    Center(
                      child: Text(
                       date,
                        style: TextStyle(
                            color: textColor, fontSize: 20.0),
                      ),
                    ),
                    //rząd z dwoma elementami - ikoną termometru oraz napisem z wartością temperatury
                    Container(
                      margin: EdgeInsets.only(top: 50.0, left: 30.0),
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('images/preassure.png', scale: 9),
                          Text(
                            " " + weatherInfo.main.temp.toInt().toString() + ' °C',
                            style: TextStyle(
                                color: textColor, fontSize: 35.0),
                          ),
                        ],
                      ),
                    ),
                    //rząd z dwoma elementami - ikoną barometru oraz napisem z wartością ciśnienia
                    Container(
                      margin: EdgeInsets.only(top: 10.0, left: 30.0),
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('images/barometer.png', scale: 9),
                          Text(
                            " " + weatherInfo.main.pressure.toString() + ' hPa',
                            style: TextStyle(
                              color: textColor, fontSize: 35.0,),
                          ),
                        ],
                      ),
                    ),
                    //rząd z dwoma elementami - ikoną wschodu słońca oraz napisem z jego godziną
                    Container(
                      margin: EdgeInsets.only(top: 10.0, left: 30.0),
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('images/sunrise.png', scale: 9),
                          Text(
                            " " + timeSunrise,
                            style: TextStyle(
                              color: textColor, fontSize: 35.0,),
                          ),
                        ],
                      ),
                    ),
                    //rząd z dwoma elementami - ikoną zachodu słońca oraz napisem z jego godziną
                    Container(
                      margin: EdgeInsets.only(top: 10.0, left: 30.0),
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('images/sunset.png', scale: 9),
                          Text(
                            " " + timeSunset,
                            style: TextStyle(
                                color: textColor, fontSize: 35.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}

class SeniorWeatherApp extends StatefulWidget {
  @override
  _SeniorWeatherAppState createState() => _SeniorWeatherAppState();
}

//klasa, w której tworzony jest widok uproszczony
class _SeniorWeatherAppState extends State<SeniorWeatherApp> {

//funkcja wywoływana po wprowadzeniu nazwy miasta
  void onTextFieldSubmitted(String text) {
    setState(() {
      location = text;
    });
    updateWeather();
  }
  //funkcja tworząca datę i godzinę w poprawnym formacje
  String setTimeFormat(int hour, int minute, String timeFormat, bool time) {
    if(hour % 10 == hour)
      timeFormat = '0' + hour.toString();
    else
      timeFormat = hour.toString();
    if(time)
      timeFormat +=":";
    else
      timeFormat +=".";
    if(minute % 10 == minute)
      timeFormat +='0' + minute.toString();
    else
      timeFormat += minute.toString();
    return timeFormat;
  }

  //funkcja nadająca wartości zmiennym na podstawie danych z API (oraz aktualnej dacie i godzinie)
  void updateWeather() {
    getWeather().then((value) {
      setState(() {
        weatherInfo = value;
        iconID = weatherInfo.weather.first.icon;
        date = setTimeFormat(DateTime.now().day, DateTime.now().month,date,false);
        timeSunset = setTimeFormat(weatherInfo.sys.sunset.hour, weatherInfo.sys.sunset.minute, timeSunset,true);
        timeSunrise = setTimeFormat(weatherInfo.sys.sunrise.hour, weatherInfo.sys.sunrise.minute, timeSunrise,true);
        if(iconID.indexOf('n') != -1) {
          weather = "night";
          textColor = Colors.white;
        }
        else {
          weather = "clear";
          textColor = Colors.black;
        }
      });
    });
  }
  //funkcja pobierająca dane z API
  Future<AllWeatherInfo> getWeather() async {
    var response = await http.get('https://api.openweathermap.org/data/2.5/weather?units=metric&q=$location&appid=$APIKey');

    if (response.statusCode >= 200 && response.statusCode < 300)
      return AllWeatherInfo.fromJson(json.decode(response.body));
    else
      return Future.error(response);
  }

  @override
  void initState() {
    super.initState();
    updateWeather();
  }
  //budowa widoku analogiczna jak dla widoku podstawowego
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/Senior$weather.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: weatherInfo == null
              ? Center(child: CircularProgressIndicator())
              : Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      width: 300,
                      margin: EdgeInsets.only(top: 40.0, bottom: 20.0),
                      child: TextField(
                        onSubmitted: (String input) {
                          onTextFieldSubmitted(input);
                        },
                        style:
                        TextStyle(color: textColor, fontSize: 25),
                        decoration: InputDecoration(
                            hintText: 'Search another location...',
                            hintStyle: TextStyle(
                                color: textColor, fontSize: 18.0),
                            prefixIcon:
                            Icon(Icons.search, color: textColor)
                        ),
                        cursorColor: textColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Center(
                      child: Image.asset('images/$iconID.png', scale: 5, height: 150,),
                    ),
                    Center(
                        child: Text (
                          weatherInfo.weather.first.description,
                          style: TextStyle(
                            color: textColor, fontSize: 25.0,
                          ),
                        )
                    ),
                    Center(
                      child: Text(
                        location,
                        style: TextStyle(
                            color: textColor, fontSize: 50.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Center(
                      child: Text(
                        "NOW",
                        style: TextStyle(
                            color: textColor, fontSize: 25.0),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 40.0,left: 30.0),
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Temp.    ",
                            style: TextStyle(
                                color: textColor, fontSize: 40.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            weatherInfo.main.temp.toInt().toString() + ' °C',
                            style: TextStyle(
                                color: textColor, fontSize: 40.0),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15.0, left: 30, right: 30),
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Press.    ",
                            style: TextStyle(
                              color: textColor, fontSize: 40.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            weatherInfo.main.pressure.toString() + ' hPa',
                            style: TextStyle(
                              color: textColor, fontSize: 40.0,),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15.0, left: 30.0),
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Sunrise  ",
                            style: TextStyle(
                              color: textColor, fontSize: 40.0,fontWeight: FontWeight.bold),
                          ),
                          Text(
                            timeSunrise,
                            style: TextStyle(
                              color: textColor, fontSize: 40.0,),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15.0, left: 30.0),
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Sunset   ",
                            style: TextStyle(
                                color: textColor, fontSize: 40.0, fontWeight: FontWeight.bold),
                          ),

                        Text(
                          timeSunset,
                          style: TextStyle(
                              color: textColor, fontSize: 40.0),
                        ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}