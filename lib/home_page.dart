import 'package:flutter/material.dart';
import 'package:midholiday/dialog_temp.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String lastwords = '';
  final speech = SpeechToText();
  @override
  void initState() {
    super.initState();
    speechtotext();
  }

  Future<void> speechtotext() async {
    await speech.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speech.listen(onResult: onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future<void> stopListening() async {
    await speech.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastwords = result.recognizedWords;
    });
  }

  @override
  void dispose() {
    super.dispose();
    speech.stop();
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
            const Text(
              "heya how can i help!",
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w400),
            ),
            const SizedBox(
              height: 100,
            ),
            // app futures
            Column(
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
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (await speech.hasPermission && speech.isNotListening) {
            await startListening();
          } else if (speech.isListening) {
            await stopListening();
          } else {
            speechtotext();
          }
        },
        backgroundColor: Colors.blue.shade100,
        child: const Icon(Icons.mic),
      ),
    );
  }
}
