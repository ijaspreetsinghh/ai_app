import 'package:ai/services/open_ai_service.dart';
import 'package:ai/view/styles/colors.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  String lastWords = "";
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;
  final FlutterTts flutterTts = FlutterTts();
  final OpenApiService openApiService = OpenApiService();
  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize(
      onStatus: (status) async {
        if (status == 'done') {
          final speech = await openApiService.isArtPromptAPI(lastWords);
          if (speech.contains('https')) {
            generatedImageUrl = speech;
            generatedContent = null;
            print('url is $generatedImageUrl');
            setState(() {});
          } else {
            generatedImageUrl = null;
            generatedContent = speech;
            setState(() {});
            systemSpeak(speech);
          }
        }
      },
    );
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

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
    print(lastWords);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {},
        ),
        centerTitle: true,
        title: const Text(
          'Jarvis',
          style: TextStyle(fontFamily: "Mulish", fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.whiteColor,
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + delay * 3),
        child: FloatingActionButton(
          onPressed: () async {
            if (await speechToText.hasPermission &&
                speechToText.isNotListening) {
              startListening();
            } else if (speechToText.isListening) {
              stopListening();
            } else {
              initTextToSpeech();
            }
          },
          backgroundColor: AppColors.firstSuggestionBoxColor,
          child: Icon(
            speechToText.isListening ? Icons.stop_rounded : Icons.mic,
            color: speechToText.isListening
                ? Colors.redAccent
                : AppColors.blackColor,
          ),
        ),
      ),
      body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ZoomIn(
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                        color: AppColors.assistantCircleColor,
                        image: const DecorationImage(
                          image: AssetImage(
                            'assets/images/virtualAssistant.png',
                          ),
                        ),
                        borderRadius: BorderRadius.circular(100)),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.borderColor,
                      ),
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                          topLeft: Radius.zero,
                          topRight: Radius.circular(16))),
                  child: Text(
                    generatedContent == null
                        ? 'Good morning, how can i help you?'
                        : generatedContent!,
                    style: TextStyle(
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.w700,
                        fontSize: generatedContent == null ? 22 : 16,
                        color: AppColors.blackColor),
                  ),
                ),
              ),
            ),
            if (generatedImageUrl != null)
              FadeIn(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(generatedImageUrl!)),
              ),
            const SizedBox(
              height: 24,
            ),
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Column(
                children: [
                  SlideInLeft(
                    child: const Text(
                      'Here are few commands',
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 20,
                          fontFamily: 'Mulish',
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const SuggestionBox(
                      title: 'ChatGPT',
                      desc:
                          'A smarter way to stay organized and informed with ChatGPT',
                      bgColor: AppColors.firstSuggestionBoxColor,
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay),
                    child: const SuggestionBox(
                      title: 'Dall-E',
                      desc:
                          'Get inspired and stay creative with your personal assistant powered by Dall-E',
                      bgColor: AppColors.secondSuggestionBoxColor,
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay + delay),
                    child: const SuggestionBox(
                      title: 'Smart Voice Assistant',
                      desc:
                          'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                      bgColor: AppColors.thirdSuggestionBoxColor,
                    ),
                  ),
                ],
              ),
            ),
          ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }
}

class SuggestionBox extends StatelessWidget {
  const SuggestionBox(
      {super.key,
      required this.title,
      required this.desc,
      required this.bgColor});
  final String title;
  final String desc;
  final Color bgColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: bgColor,
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 18, fontFamily: "Mulish"),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          desc,
          style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 14, fontFamily: "Mulish"),
        ),
      ]),
    );
  }
}
