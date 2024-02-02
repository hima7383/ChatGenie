import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:midholiday/dialog_temp.dart';
import 'package:midholiday/openoi.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String lastWords = '';
  String? genimage;
  String? genwords;
  final OpenAiService openai = OpenAiService();
  final speechToText = SpeechToText();
  FlutterTts flutteetts = FlutterTts();
  @override
  void initState() {
    super.initState();
    initSpeechToText();
    flutteetts = FlutterTts();
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutteetts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alex"),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // using pics
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  height: 123,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/virtualAssistant.png'),
                      )),
                )
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            if (genimage != null) Image.network(genimage!),
            Text(
              genwords == null && genimage == null
                  ? "heya how can i help!"
                  : genwords!,
              style: TextStyle(
                  fontSize: genwords == null ? 23 : 18,
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(
              height: 100,
            ),
            // app futures
            Visibility(
              visible: genwords == null && genimage == null,
              child: Column(
                children: [
                  FuturesBox(
                    color: Colors.green.shade100,
                    title: 'Chat GPT',
                    Description: 'Using Ai for better answers for your needs',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FuturesBox(
                    color: Colors.blue.shade200,
                    title: 'Voice Commands',
                    Description:
                        'save typing time and get quick answers on the go',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (await speechToText.hasPermission && speechToText.isNotListening) {
            await startListening();
          } else if (speechToText.isListening) {
            log(lastWords);
            final temp = await openai.decideCorrectApi(lastWords);
            if (temp.contains('https')) {
              genimage = temp;
              genwords = null;
              setState(() {});
            } else {
              genimage = null;
              genwords = temp;
              setState(() {});
              await systemSpeak(temp);
            }
            await stopListening();
          } else {
            initSpeechToText();
          }
        },
        backgroundColor: Colors.blue.shade100,
        child: const Icon(Icons.mic),
      ),
    );
  }
}
