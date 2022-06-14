/*

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:karakaya_soguk/static/global.dart';
import 'package:karakaya_soguk/ui/mesajyaz.dart';
import 'anasayfa.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Mesajlar extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}
/*final Map<String, HighlightedWord> _highlights = {
    'sen': HighlightedWord(
      onTap: () => print('flutter'),
      textStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
    ),
    'yaz': HighlightedWord(
      onTap: () => print('voice'),
      textStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
    'bitir': HighlightedWord(
      onTap: () => print('subscribe'),
      textStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    ),
    'like': HighlightedWord(
      onTap: () => print('like'),
      textStyle: const TextStyle(
        color: Colors.blueAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
    'comment': HighlightedWord(
      onTap: () => print('comment'),
      textStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
    
  };*/

class MyCustomFormState extends State<Mesajlar> {
  final _formKey = GlobalKey<FormState>();
  var _cumle = TextEditingController();
  TextToSpeech tts = TextToSpeech();
  String mesaj;
  Timer timer;
  @override
  void dispose() {
    super.dispose();
    //anons2();
  }

  @override
  void initState() {
    super.initState();
    //_speech = stt.SpeechToText();
    anons();
    //anons2();
  }

/*void okudum(){
print(_text);
timer = Timer.periodic(
      const Duration(seconds: 2),
      (timer) {
       kontrol();
      },
    );

}*/
  /* void kontrol() {
if(_text=="oku"){

         
         setState(() {
           //tts.speak(_text);
         print(_text);
           _text="";
             
         });
         
       }
  }*/

  void anons() async {
    tts.speak(
        "Merhaba ! Mesaj Yazmak İçin Yaz, Mesajlarınızı dinlemek için Dinle deyiniz!");
    await Future.delayed(const Duration(seconds: 7), () {
      _listen();
    });
  }

  void anons2() async {
    //tts.speak("Ne yazcan");
    //tts.stop();
    //tts.pause();
    _text = "";
    await Future.delayed(const Duration(seconds: 3), () {
      //_listen();
      print("anons2 deyim");
      return null;
    });
  }

  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1;
  String _text2 = "";

  _listen2() async {
    if (!_isListening) {
      //var timeoa=Duration(seconds: 3);
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
        //finalTimeout: timeoa,
      );
      if (available) {
        setState(() => _isListening = true);

        _speech.listen(
          onResult: (val) => setState(() {
            _text2 = val.recognizedWords;
            print("listen2de" + _text2);

            // if (val.hasConfidenceRating && val.confidence > 0) {
            //   _confidence = val.confidence;
            // }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  _listen() async {
    if (!_isListening) {
      // var timeoa=Duration(seconds: 3);
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
        //finalTimeout: timeoa,
      );
      if (available) {
        setState(() => _isListening = true);

        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (_text == "oku") {
              setState(() => _isListening = false);
              _speech.stop();
            } else if (_text == "yaz") {
              setState(() {
                setState(() => _isListening = false);
                _speech.stop();
                _text = "";
                /* Navigator.push (
    context,
    MaterialPageRoute(builder: (context) => MesajYaz()),
);*/
                // _speech.cancel();
                // anons2();
                //dispose();
                print("yaz içinde");
              });
            } else if (_text == "bitir") {
              setState(() {
                _speech.stop();
              });
            }

            // if (val.hasConfidenceRating && val.confidence > 0) {
            //   _confidence = val.confidence;
            // }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[900],
          centerTitle: true,
          title: Text("Messages"),
          automaticallyImplyLeading: Global.kuladi.isEmpty ? false : true,
        ),
        drawer: MyDrawer(),
        body: //_isListening? Center(child: CircularProgressIndicator(),):
            Container(
                child: Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 10),
                          TextField(
                            controller: _cumle,
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(20.0, 0, 0, 0),
                              // hintText: "Sunucu IP ve SQL Instance",
                              labelText: 'Word',
                            ),
                          ),
                          SizedBox(height: 10),
                          MaterialButton(
                            height: 50,
                            onPressed: () {
                              // _kaydet();
                              String text = _cumle
                                  .text; // "Merhaba! Mesajları Dinlemek için Dinle, Mesaj Yazmak İçin Yaz Demelisiniz";
                              tts.speak(text);
                            },
                            textColor: Colors.white,
                            color: Colors.blue[900],
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Read',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ),
                          /*Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: TextHighlight(
            text: _text,
           // words: _highlights,
            textStyle: const TextStyle(
              fontSize: 32.0,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
          
        )*/
                          Container(
                            padding: const EdgeInsets.fromLTRB(
                                30.0, 30.0, 30.0, 150.0),
                            child: Text(_text),
                          )
                        ]))));
  }

  _kaydet() async {
    /*
    
                              await  _listen().then((value)async {
                                    setState(() {
                                      cmara.text=value;
                                    });
                                      await carilist(cmara.text);                  
                      await cmguncelle(state);
                                  });
    */
  }
*/
