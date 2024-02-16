// ignore_for_file: unnecessary_null_comparison, constant_identifier_names
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import '../widgets/stats_row_widget.dart';

import '../../../../../core/ml/realtime_object_detection_classifier/recognition.dart';
import '../../../../../core/ml/realtime_object_detection_classifier/stats.dart';
import '../widgets/camera_view.dart';
import '../widgets/camera_view_singleton.dart';
import '../widgets/object_box_widget.dart';

// ignore: must_be_immutable
class RealTimeObjectDetectionPage extends StatefulWidget {
  const RealTimeObjectDetectionPage({super.key});

  static const String routeName = 'RealTimeObjectDetectionHomePage';

  @override
  State<RealTimeObjectDetectionPage> createState() => _RealTimeObjectDetectionPageState();

  static const BOTTOM_SHEET_RADIUS = Radius.circular(24.0);
  static const BORDER_RADIUS_BOTTOM_SHEET = BorderRadius.only(topLeft: BOTTOM_SHEET_RADIUS, topRight: BOTTOM_SHEET_RADIUS);
}

class _RealTimeObjectDetectionPageState extends State<RealTimeObjectDetectionPage> {

  /// Results to draw bounding boxes
  List<Recognition>? results;

  /// Realtime stats
  Stats? stats;

  /// Scaffold Key
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final _openAI = OpenAI.instance.build(
    token: "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",
    baseOption: HttpSetup(
      receiveTimeout: const Duration(
        seconds: 5,
      ),
    ),
    enableLog: true,
  );

  @override
  void dispose() {
    audioPlayer.stop();
    // TODO: implement dispose
    super.dispose();
  }

  final apiKey = 'AIzaSyAPXbaIlXvuDRCDtnPdh0lh83bo0zW0fps'; // Replace with your actual API key
  final apiUrl = 'https://translation.googleapis.com/language/translate/v2';

  late var audioData;
  final ChatUser _currentUser =
  ChatUser(id: '1', firstName: '', lastName: '');

  final ChatUser _gptChatUser =
  ChatUser(id: '2', firstName: 'Жардамчы', lastName: '',profileImage: 'assets/images/virtualAssistant.png');

  List<ChatMessage> _messages = <ChatMessage>[];
  List<ChatUser> _typingUsers = <ChatUser>[];


  final AudioPlayer audioPlayer = AudioPlayer();

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      progress=true;
      _messages.insert(0, m);
      _typingUsers.add(_gptChatUser);
    });




    List<Map<String,dynamic>> _messagesHistory = _messages.reversed.map((m) {
      if (m.user == _currentUser) {
        return {
          "role": "user",
          "content": 'What is ${m.text}?'
        };
        // Messages(role: Role.user, content: m.text);
      } else {
        return {
          "role": "assistant",
          "content": 'What is ${m.text}?'
        };
        // Messages(role: Role.assistant, content: m.text);
      }
    }).toList();

    final request = ChatCompleteText(
      model: GptTurbo0301ChatModel(),
      messages: _messagesHistory,
      maxToken: 500,
    );
    final response = await _openAI.onChatCompletion(request: request);
    print(response!.choices.length);


    _messages.removeAt(0);
    setState(() {

    });
    for (var element in response!.choices) {
      if (element.message != null) {
        final String translation;
        final params = {
          'q': element.message!.content,
          'target': 'ky',
          'key': apiKey,
        };
        try {
          final response = await http.post(Uri.parse(apiUrl), body: params);

          final decodedResponse = json.decode(response.body);
          translation = decodedResponse['data']['translations'][0]['translatedText'];
          var headers = {
          'Content-Type': 'application/json',
            'Authorization': 'Bearer BROeCBj5mv4T4cGRuj0usAf42S0bvaCzZCoF3VfVIue8ShP5GVtsIQgr64ubMlct'
          };
          var jsonAudio=jsonEncode({
            "text": translation,
            "speaker_id": 1
          });
          var requestAudio = await http.post(Uri.parse('http://tts.ulut.kg/api/tts'),body: jsonAudio,headers: headers);

          if (requestAudio.statusCode == 200) {
            print('Audio get');
            setState(() {
              audioData=requestAudio.bodyBytes;
            });
            // var rng = new Random();
// get temporary directory of device.
// get temporary path from temporary directory.
// create a new file in temporary path with random file name.
//             File file = new File((rng.nextInt(100)).toString() + '.mp3');
//             await file.writeAsBytes(audioData);
          }
          else {
            print(response.reasonPhrase);
          }
          print(translation); // return translated text
        } catch (error) {
          print('Error translating text: $error');
          throw error; // rethrow error to handle it elsewhere if needed
        }
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
                user: _gptChatUser,
                createdAt: DateTime.now(),
                text: translation),
          );
        });
        await audioPlayer.setSourceBytes(audioData);
        audioPlayer.play(audioPlayer.source!);
        /*if (result == 1) {
          print('Успешно начало воспроизведение');
        } else {
          print('Произошла ошибка воспроизведении');
        }*/
      }
    }
    print(_messages.first.text);

    setState(() {
      chat=true;
      progress=false;
      _typingUsers.remove(_gptChatUser);
    });
  }

  Future<void> getChatSentenceResponse(ChatMessage m) async {
    setState(() {
      progress=true;
      _messages.insert(0, m);
      _typingUsers.add(_gptChatUser);
    });




    List<Map<String,dynamic>> _messagesHistory = _messages.reversed.map((m) {
      if (m.user == _currentUser) {
        return {
          "role": "user",
          "content": 'Make 5 sentences with this word ${m.text}'
        };
        // Messages(role: Role.user, content: m.text);
      } else {
        return {
          "role": "assistant",
          "content": 'Make 5 sentences with this word ${m.text}'
        };
        // Messages(role: Role.assistant, content: m.text);
      }
    }).toList();

    final request = ChatCompleteText(
      model: GptTurbo0301ChatModel(),
      messages: _messagesHistory,
      maxToken: 500,
    );
    final response = await _openAI.onChatCompletion(request: request);
    print(response!.choices.length);


    _messages.removeAt(0);
    setState(() {

    });
    for (var element in response!.choices) {
      if (element.message != null) {
        final String translation;
        final params = {
          'q': element.message!.content,
          'target': 'ky',
          'key': apiKey,
        };
        try {
          final response = await http.post(Uri.parse(apiUrl), body: params);

          final decodedResponse = json.decode(response.body);
          translation = decodedResponse['data']['translations'][0]['translatedText'];
          var headers = {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer BROeCBj5mv4T4cGRuj0usAf42S0bvaCzZCoF3VfVIue8ShP5GVtsIQgr64ubMlct'
          };
          var jsonAudio=jsonEncode({
            "text": translation,
            "speaker_id": 1
          });
          var requestAudio = await http.post(Uri.parse('http://tts.ulut.kg/api/tts'),body: jsonAudio,headers: headers);

          if (requestAudio.statusCode == 200) {
            print('Audio get');
            setState(() {
              audioData=requestAudio.bodyBytes;
            });
            // var rng = new Random();
// get temporary directory of device.
// get temporary path from temporary directory.
// create a new file in temporary path with random file name.
//             File file = new File((rng.nextInt(100)).toString() + '.mp3');
//             await file.writeAsBytes(audioData);
          }
          else {
            print(response.reasonPhrase);
          }
          print(translation); // return translated text
        } catch (error) {
          print('Error translating text: $error');
          throw error; // rethrow error to handle it elsewhere if needed
        }
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
                user: _gptChatUser,
                createdAt: DateTime.now(),
                text: translation),
          );
        });
        await audioPlayer.setSourceBytes(audioData);
        audioPlayer.play(audioPlayer.source!);
        /*if (result == 1) {
          print('Успешно начало воспроизведение');
        } else {
          print('Произошла ошибка воспроизведении');
        }*/
      }
    }
    print(_messages.first.text);

    setState(() {
      chat=true;
      progress=false;
      _typingUsers.remove(_gptChatUser);
    });
  }
  bool chat=false;
  bool chat_second=false;
  bool progress=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: chat ? FloatingActionButton(
        onPressed: (){
          chat=false;
          chat_second=false;
          audioPlayer.stop();
          setState(() {
          });
        },
        child: Icon(Icons.linked_camera_outlined),
      ): null,
      /*appBar: chat  ? AppBar(

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(onPressed: (){
              setState(() {
                chat=false;
              });
            }, icon: Icon(Icons.camera,size: 35)),
          )
        ],
      ) : null,*/
      key: scaffoldKey,
      body: chat ? Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 64
        ),
        child: DashChat(
            currentUser: _currentUser,
            typingUsers: _typingUsers,
            messageOptions: const MessageOptions(
              currentUserContainerColor: Colors.black,
              containerColor: Color.fromRGBO(
                0,
                166,
                126,
                1,
              ),
              textColor: Colors.white,
            ),
            onSend: (ChatMessage m) {
              getChatResponse(m);
            },
            readOnly: true,
            messages: _messages),
      ) :
      progress ? const Center(child: CircularProgressIndicator()) : SafeArea(
        child: Stack(
          children: [
            if(chat_second)
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: (){
                    getChatSentenceResponse(ChatMessage(user: _currentUser, text: results!.first.label, createdAt: DateTime.now()));
                  }, child: Text('Сүйлом тузуу')),
                  ElevatedButton(onPressed: (){
                    getChatResponse(ChatMessage(user: _currentUser, text: results!.first.label, createdAt: DateTime.now()));
                  }, child: Text('Маалымат алуу'))
                ],
              ),
            ),
            if(!chat_second)
            CameraView(resultsCallback, statsCallback),
            if(!chat_second)
            boundingBoxes(results),
            if(!chat_second)
            Positioned(
              bottom: 90,
              left: MediaQuery.of(context).size.width/2-65,
              child: InkWell(onTap: (){
                chat_second=true;
                setState(() {

                });
              }, child: const Icon(Icons.camera,size: 120,))
            )



            /*Align(
              alignment: Alignment.bottomCenter,
              child: DraggableScrollableSheet(
                initialChildSize: 0.4,
                minChildSize: 0.1,
                maxChildSize: 0.5,
                builder: (_, ScrollController scrollController) => Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                      color: aiDarkPurple.withOpacity(0.9),
                      borderRadius: RealTimeObjectDetectionPage.BORDER_RADIUS_BOTTOM_SHEET),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.keyboard_arrow_up,size: 48, color: aiPurple),
                          (stats != null)
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      StatsRow('Inference time:','${stats!.inferenceTime} ms'),
                                      StatsRow('Total prediction time:','${stats!.totalElapsedTime} ms'),
                                      StatsRow('Pre-processing time:','${stats!.preProcessingTime} ms'),
                                      StatsRow('Frame','${CameraViewSingleton.inputImageSize?.width} X ${CameraViewSingleton.inputImageSize?.height}'),
                                    ],
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )*/
          ],
        ),
      ),
    );
  }

  /// Returns Stack of bounding boxes
  Widget boundingBoxes(List<Recognition>? results) {
    if (results == null) {
      return Container();
    }
    return Stack(
      children: results.map((e) => BoxWidget(result: e)).toList(),
    );
  }

  /// Callback to get inference results from [CameraView]
  void resultsCallback(List<Recognition> results) {
    setState(() {
      this.results = results;
    });
  }

  /// Callback to get inference stats from [CameraView]
  void statsCallback(Stats stats) {
    setState(() {
      this.stats = stats;
    });
  }
}

