import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart'; // import the package
//import 'package:flutter_tts/flutter_tts.dart';
//import 'package:speech_to_text/speech_recognition_error.dart';
import 'dart:async';
//import 'package:speech_to_text/speech_to_text.dart';
//import 'package:speech_to_text/speech_recognition_result.dart';

class MesajYaz extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pie Chart Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Pie Chart Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum TtsState { playing, stopped, paused, continued }

class _MyHomePageState extends State<MyHomePage> {
  Map<String, double> data = new Map();
  bool _loadChart = true;
  //var flutterTts = FlutterTts();
  TtsState ttsState = TtsState.stopped;
  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;
  String durum = "";
  String okuma = "";
  String yazma = "";
  String komut = "";
  String mesaj = "";
  String kime = "";
  //SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  String lastError = '';
  String lastStatus = '';
  bool _logEvents = false;
  List<dynamic> mesajlar = [];
  @override
  void initState() {
    data.addAll({
      'Kasa 1' + ' 100': 100,
      'Kasa 2': 50,
      'Kasa 3': 75,
      'Kasa 4': 25,
      'Kasa 5': 5
    });
    super.initState();
    //kontrol();
    //initTts();
    //  _initSpeech();
  }

  /* void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: errorListener,
      onStatus: statusListener,
      //debugLogging: true,
    );
    // print(_speechEnabled);
    setState(() {});
  }

  void errorListener(SpeechRecognitionError error) {
    _logEvent('Received error status: $error, listening: }');
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }*/

  void _logEvent(String eventDescription) {
    if (_logEvents) {
      var eventTime = DateTime.now().toIso8601String();
      print('olay :$eventTime $eventDescription');
    }
  }

  void statusListener(String status) {
    _logEvent('Received listener status: $status, listening:}');
    setState(() {
      lastStatus = '$status';
    });
    print(lastStatus);
  }

  /// Each time to start a speech recognition session
  /*void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    print("dinliyor");
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }*/

  /* initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }*/

  /* Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }*/

  /*void kontrol() {
    Timer.periodic(Duration(seconds: 3), (timer) async {
      //print(_speechToText.isNotListening);
      if (ttsState == TtsState.stopped) {
        if (durum == "menu") {
          if (_speechToText.isNotListening) {
            await _speechToText.listen(
                listenFor: Duration(seconds: 3),
                onResult: (val) => setState(() {
                      lastStatus = val.recognizedWords;
                      if (lastStatus == "dinle") {
                        _speechToText.stop();
                        durum = "dinle";
                      }
                      if (lastStatus == "yaz") {
                        _speechToText.stop();
                        durum = "yaz";
                      }
                    }));
          }
          //print(durum + " " + _speechEnabled.toString());
        }
        if (durum == "dinle") {
          if (okuma == "") {
            if (mesajlar.length > 0) {
              String oku = "";
              mesajlar.forEach((element) {
                print(element);
                oku = oku +
                    ",Gönderen :" +
                    element['kime'].toString() +
                    " , Mesajı," +
                    element['mesaj'].toString();
              });
              var result = await flutterTts.speak(mesajlar.length.toString() +
                  ", Mesajınız Var." +
                  oku +
                  ". Başka Mesajınız yok.");
              if (result == 1)
                setState(() {
                  ttsState = TtsState.playing;
                  okuma = "bitti";
                  durum = "";
                 
                });
            }
            
             else {
              var result = await flutterTts.speak("Hiç Mesajınız Yok.");
              
              
              if (result == 1)
                setState(() {
                
                  ttsState = TtsState.playing;
                  okuma = "bitti";
                  durum="";
                    //durum = "menu";
                  yazma = "";
                  //okuma = "";
                  lastStatus = "";
                    print(durum+komut);
                               
                   
                  
                }
                );
            }
          }
           
        }
       
        if (durum == "yaz") {
          if (yazma == "") {
            var result = await flutterTts.speak("Kime Mesaj yazacağım?");
            if (result == 1)
              setState(() {
                ttsState = TtsState.playing;
                yazma = "kime";
              });
          }
          if (yazma == "kime") {
            if (_speechToText.isNotListening) {
              await _speechToText.listen(
                  listenFor: Duration(seconds: 5),
                  // pauseFor: Duration(seconds: 3),
                  onResult: (val) => setState(() {
                        kime = val.recognizedWords;

                        yazma = "mesajne";
                      }));
            }
          }
          if (yazma == "mesajne") {
            var result = await flutterTts.speak("Mesaj Nedir?");
            if (result == 1)
              setState(() {
                ttsState = TtsState.playing;
                yazma = "mesajbu";
              });
          }
          if (yazma == "mesajbu") {
            if (_speechToText.isNotListening) {
              await _speechToText.listen(
                  listenFor: Duration(seconds: 5),
                  // pauseFor: Duration(seconds: 3),
                  onResult: (val) => setState(() {
                        mesaj = val.recognizedWords;
                        print(mesaj);
                        yazma = "mesajbitti";
                      }));
            }
          }
          if (yazma == "mesajbitti") {
            var result = await flutterTts.speak("Mesaj Gönderilsin mi?");
            if (result == 1)
              setState(() {
                ttsState = TtsState.playing;

                yazma = "gonderiptal";
                print("gondersoru " + yazma);
              });
          }
          if (yazma == "gonderiptal") {
            if (_speechToText.isNotListening) {
              await _speechToText.listen(
                  listenFor: Duration(seconds: 3),
                  // pauseFor: Duration(seconds: 3),
                  onResult: (val) => setState(() {
                        komut = val.recognizedWords;

                        yazma = "gisonuc";
                        print(
                            "mesajgonderilsin mi?" + komut + " yazma " + yazma);
                      }));
            }
          }
          if (yazma == "gisonuc") {
            if (komut == "gönder") {
              print(komut);
              dynamic mm = "";
              mm = {"kime": kime, "mesaj": mesaj};
              mesajlar.add(mm);
              var result = await flutterTts.speak("Mesaj Gönderildi");

              setState(() {
                ttsState = TtsState.playing;
                yazma = "tamalandı";
                komut = "";
              });
            }
            if (komut == "iptal") {
              var result = await flutterTts.speak("Mesaj iptal Edildi");
              if (result == 1)
                setState(() {
                  ttsState = TtsState.playing;
                  yazma = "tamalandı";
                  komut = "";
                });
            }
            //print(mesajlar);
          }
        }
      }
    });
  }*/

  List<Color> _colors = [
    Colors.teal,
    Colors.blueAccent,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.purple
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(
              "Durum: " + lastStatus,
              style: TextStyle(fontSize: 25),
            ),
            /*  _loadChart
                ? Expanded(
                    child: PieChart(
                    dataMap: data,
                    colorList:
                        _colors, // if not declared, random colors will be chosen
                    animationDuration: Duration(milliseconds: 1500),
                    chartLegendSpacing: 32.0,
                    chartRadius: MediaQuery.of(context).size.width /
                        2.7, //determines the size of the chart
                    showChartValuesInPercentage: true,
                    showChartValues: true,
                    showChartValuesOutside: false,
                    chartValueBackgroundColor: Colors.grey[200],
                    showLegends: true,
                    legendPosition: LegendPosition
                        .right, //can be changed to top, left, bottom
                    decimalPlaces: 1,
                    showChartValueLabel: true,
                    initialAngle: 0,
                    chartValueStyle: defaultChartValueStyle.copyWith(
                      color: Colors.blueGrey[900].withOpacity(0.9),
                    ),
                    chartType:
                        ChartType.disc, //can be changed to ChartType.ring
                  ))
                : SizedBox(
                    height: 150,
                  ),*/
            SizedBox(
              height: 50,
            ),
            RaisedButton(
              color: Colors.blue,
              child: Text(
                'Click for messages',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                setState(() {
                  ttsState = TtsState.playing;
                  durum = "menu";
                  yazma = "";
                  okuma = "";
                  lastStatus = "";
                });
                /*var result = await flutterTts.speak(
                    "Merhaba, Mesajları Dinlemek için, Dinle, Mesaj Yazmak için, Yaz, diyebilirsiniz.");
                // if (result == 1)*/
              },
            ),
            Text("Mesajlar:"),
            Expanded(
              child: ListView.builder(
                  // the number of items in the list
                  itemCount: mesajlar.length,

                  // display each item of the product list
                  itemBuilder: (context, index) {
                    return Card(
                      // In many cases, the key isn't mandatory
                      key: UniqueKey(),
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(mesajlar[index]['kime'] +
                              " : " +
                              mesajlar[index]['mesaj'])),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
