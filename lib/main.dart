import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const TranslationScreen());
  }
}

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  String _sourceLang = 'Türkçe';
  String _targetLang = 'İngilizce';
  String _spokenText = '';
  String _translatedText = '';

  final List<String> _languages = [
    'Türkçe',
    'İngilizce',
    'Almanca',
    'Arapça',
    'Çince',
    'Japonca',
  ];

  final Map<String, TranslateLanguage> _languageCodes = {
    'Türkçe': TranslateLanguage.turkish,
    'İngilizce': TranslateLanguage.english,
    'Almanca': TranslateLanguage.german,
    'Arapça': TranslateLanguage.arabic,
    'Çince': TranslateLanguage.chinese,
    'Japonca': TranslateLanguage.japanese,
  };

  late stt.SpeechToText _speech;
  late OnDeviceTranslator _translator;
  late FlutterTts _flutterTts;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _translator = OnDeviceTranslator(
      sourceLanguage: _languageCodes[_sourceLang]!,
      targetLanguage: _languageCodes[_targetLang]!,
    );
    _flutterTts = FlutterTts();
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage(_targetLang == 'Türkçe' ? 'tr-TR' : 'en-US');
    await _flutterTts.setPitch(1.0);
  }

  void _startListening(String lang) async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) async {
            setState(() {
              _spokenText = result.recognizedWords;
            });
            if (result.finalResult) {
              _translateAndSpeak();
            }
          },
          localeId:
              lang == 'Türkçe'
                  ? 'tr_TR'
                  : lang == 'İngilizce'
                  ? 'en_US'
                  : lang == 'Almanca'
                  ? 'de_DE'
                  : lang == 'Arapça'
                  ? 'ar_SA'
                  : lang == 'Çince'
                  ? 'zh_CN'
                  : 'ja_JP',
        );
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  void _translateAndSpeak() async {
    if (_spokenText.isNotEmpty) {
      final translated = await _translator.translateText(_spokenText);
      setState(() {
        _translatedText = translated;
      });
      await _flutterTts.setLanguage(
        _targetLang == 'Türkçe' ? 'tr-TR' : 'en-US',
      );
      await _flutterTts.speak(_translatedText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesli Çeviri'),
        backgroundColor: Colors.blue[800],
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Dil Seçimi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Konuşulan Dil',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _sourceLang,
                        items:
                            _languages.map((String lang) {
                              return DropdownMenuItem<String>(
                                value: lang,
                                child: Text(lang),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _sourceLang = newValue!;
                            _translator = OnDeviceTranslator(
                              sourceLanguage: _languageCodes[_sourceLang]!,
                              targetLanguage: _languageCodes[_targetLang]!,
                            );
                          });
                        },
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        underline: Container(),
                      ),
                    ],
                  ),
                  const Icon(Icons.swap_horiz, color: Colors.blueGrey),
                  Column(
                    children: [
                      const Text(
                        'Çevrilecek Dil',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _targetLang,
                        items:
                            _languages.map((String lang) {
                              return DropdownMenuItem<String>(
                                value: lang,
                                child: Text(lang),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _targetLang = newValue!;
                            _translator = OnDeviceTranslator(
                              sourceLanguage: _languageCodes[_sourceLang]!,
                              targetLanguage: _languageCodes[_targetLang]!,
                            );
                          });
                        },
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        underline: Container(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Butonlar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTapDown: (_) => _startListening(_sourceLang),
                  onTapUp: (_) => _stopListening(),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 50,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$_sourceLang Konuş',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTapDown: (_) => _startListening(_targetLang),
                  onTapUp: (_) => _stopListening(),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 50,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$_targetLang Konuş',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Metin Kutusu
            Container(
              width: 340,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_spokenText.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Konuşulan: $_spokenText',
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                  if (_translatedText.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Çevrilen: $_translatedText',
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
