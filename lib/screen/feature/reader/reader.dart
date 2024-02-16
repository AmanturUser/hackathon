import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:http/http.dart' as http;
import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData, SystemChrome, SystemUiOverlayStyle;

class ReaderPage extends StatefulWidget {
  const ReaderPage({Key? key}) : super(key: key);

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  late EpubController _epubReaderController;

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    audioPlayer.stop();
    // TODO: implement dispose
    super.dispose();
  }
  final _openAI = OpenAI.instance.build(
    token: "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",
    baseOption: HttpSetup(
      receiveTimeout: const Duration(
        seconds: 5,
      ),
    ),
    enableLog: true,
  );
  final apiKey = 'AIzaSyAPXbaIlXvuDRCDtnPdh0lh83bo0zW0fps'; // Replace with your actual API key
  final apiUrl = 'https://translation.googleapis.com/language/translate/v2';
  var copyText;

  bool chat=false;

  final ChatUser _currentUser =
  ChatUser(id: '1', firstName: '', lastName: '');

  final ChatUser _gptChatUser =
  ChatUser(id: '2', firstName: 'Жардамчы', lastName: '',profileImage: 'assets/images/virtualAssistant.png');

  List<ChatMessage> _messages = <ChatMessage>[];
  List<ChatUser> _typingUsers = <ChatUser>[];

  late var audioData;
  final AudioPlayer audioPlayer = AudioPlayer();

  bool selectScreen=false;
  bool progress=false;

  final text='''Илгери өткөн заманда бир абышка, кемпирдин Айгерим жана Арген деген балдары болуптур. Алар өтө тентек, ата энесин да, бири-бирин да укпаган бейбаш жана ынтымагы жок балдар экен.  Бир күнү алар ата энесинин айткандарын укпай, алыска ойноп кетип калышат.

Балдар кеч киргенин билбей адашып, караңгы коюу түндө  жарыкты издеп, өтө алыска кетип калышат. Таң аткыча уктабай абдан чарчашат.

Таң атканда карашса, таптакыр башка жакта жүргөн болушат. Үйү тургай, айылы да көрүнбөйт. Ачка, чарчаган балдар уктайлы дешсе аларды капыстан чыга калган аюу кубалайт. Экөө кыйкырып качып баратышып, чоң агын сууга түшүп кетишип, агып жөнөшөт.

Аларды жей албай калганына өкүнүп, аюу артка кетет. Балдар агып баратса, сууда сүзгөн жылан кубалайт. Балдар андан коркконунан  жээкке качып чыгышат.  Алар титиреп үшүп, ыйлап отурушса, ары жактан карышкыр чыга калып, экөөнү жемек болот. Ошондо Арген эжекеси Айгеримди катуу кучактап ыйлап жиберет. Эки адамдын бир адамга жабышып калганын көргөн карышкыр чочуп кетип, качып жөнөйт. Ошондо Айгерим менен Арген кучакташкан бойдон көпкө ыйлашат да, ынтымактуу болсо эч ким жей албасын түшүнүшөт. Бири-бирин сыйлаган көп жамандыктардан сактаарын билишет. Анан алар ынтымактуу болууга сөз беришет.

Экөө дагы бирөө келип кол салбасын деп уктагандан коркуп, ыйлап отура беришет. Ата-энелерин абдан сагынышат. Эч качан урушпайлы, апабызды, атабызды сыйлайлы дешет. Ошондо кайдан жайдан аппак сакалдуу абышка пайда болуп экөөнө саламдашат, экөө ордуларынан тура калып учурашып, үйлөрүнө жеткирүүгө жардам сурашат. Абышка балдарга  ушул суунун жээги менен түптүз кете берсе үйлөрүнө жетээрин айтып, көздөн кайым болот. Эки бала жетелешкен бойдон суунун жээги менен кете берет, кете берет, бирок эч жетишпейт. Акыры чарчап, ачка болуп отуруп калышат. Анан суунун ичинде балыктардын сүзүп жүргөнүн көрүшүп, аларды кармап, от жагып бышырып жешет. Ошондогу балыктын даамы укмуш сезилди экөөнө, тим  эле жеп аткан бармагын тиштеп ийгилери келет. Көрсө, адам өз эмгеги менен тапкан тамагы таттуу болот турбайбы дешет балдар. Алар курсактарын тойгузгандан кийин кучакташкан бойдон уктап калышат. Канча уктаганын ким билсин, ойгонуп кетишсе, уйкулары канып калыптыр. Эч ким аларга тийбептир. Алар туруп бети-колдорун жуунуп, от жагып көпкө отурушат.

Тентек болуп жүргөн күндөрүн эстешет, ата-энесин сагынганын айтышат. Анан кеч кирип кетпесин деп кайра дагы балык кармап жешип, жолун андан ары улашат. Кете беришип, кете беришип, үч күн, үч түн дегенде араң алардын айылы, анан үйү көрүнөт. Ошондо балдар чарчап-чаалыккан кебетелери менен элдин көзүнө көрүнгүлөрү келбей, кийимдерин чечип жууп, өздөрү да жуунуп, чачтарын иретке келтирип, татынакай болуп баралы дешет. Алар жуулган кийимдерин кийели деп атышканда баягы аксакал пайда болуп, аларга чак кооз кийимдерди жана дүр дүйнө тамак аштарды берет. «Эми эч качан урушпагыла, ата-энеңерди сыйлагыла» деп кетет.

Балдар сүйүнгөнүнөн жаңы кийимдерди кийинишип, түрдүү тамак-аштарды көтөрүнүп, үйүн көздөй чуркап кетишет. Аларды көргөн адамдардын баары таң калып карап калышат. «Балдарыбыз жоголуп өлдү» деген ата-энеси ыйлай берип көздөрү көрбөй калган болот. Алар балдарынын үндөрүн угуп, көздөрү көрүп калат. Балдар бара калып эле ата-энеси менен учурашкандан кийин бири үйүн жыйнап, бири тамак бышырып, ата-энесин сыйлап жашап калышкан экен. Алар ошентип абдан акылдуу, билимдүү, сулуу балдар болуп чоңоюшуп, бактылуу жашашат.''';

_getAns() async {
  try {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer BROeCBj5mv4T4cGRuj0usAf42S0bvaCzZCoF3VfVIue8ShP5GVtsIQgr64ubMlct'
    };
    var jsonAudio=jsonEncode({
      "text": copyText,
      "speaker_id": 1
    });
    var requestAudio = await http.post(Uri.parse('http://tts.ulut.kg/api/tts'),body: jsonAudio,headers: headers);

    if (requestAudio.statusCode == 200) {
      print('Audio get');
      setState(() {
        audioData=requestAudio.bodyBytes;
      });
      await audioPlayer.setSourceBytes(audioData);
      audioPlayer.play(audioPlayer.source!);
      // var rng = new Random();
// get temporary directory of device.
// get temporary path from temporary directory.
// create a new file in temporary path with random file name.
//             File file = new File((rng.nextInt(100)).toString() + '.mp3');
//             await file.writeAsBytes(audioData);
    }
    else {
      print(requestAudio.reasonPhrase);
    }
    // return translated text
  } catch (error) {
    print('Error translating text: $error');
    throw error; // rethrow error to handle it elsewhere if needed
  }
}

_getAnsSecond(ChatMessage m) async{
  setState(() {
    progress=true;
    _messages.insert(0, m);
    _typingUsers.add(_gptChatUser);
  });

  final String translation;
  final params = {
    'q': m.text,
    'target': 'en',
    'key': apiKey,
  };
  try {
    final response = await http.post(Uri.parse(apiUrl), body: params);

    final decodedResponse = json.decode(response.body);
    translation = decodedResponse['data']['translations'][0]['translatedText'];

    print(translation); // return translated text
  } catch (error) {
    print('Error translating text: $error');
    throw error; // rethrow error to handle it elsewhere if needed
  }
  List<Map<String,dynamic>> _messagesHistory = _messages.reversed.map((m) {
    if (m.user == _currentUser) {
      return {
        "role": "user",
        "content": 'What is $translation?'
      };
      // Messages(role: Role.user, content: m.text);
    } else {
      return {
        "role": "assistant",
        "content": 'What is $translation?'
      };
      // Messages(role: Role.assistant, content: m.text);
    }
  }).toList();
  final request = ChatCompleteText(
    model: GptTurbo0301ChatModel(),
    messages:
      _messagesHistory,
    maxToken: 500,
  );
  final response = await _openAI.onChatCompletion(request: request);
  print(response!.choices.length);
  var translationSecond;
  for (var element in response!.choices) {
    if (element.message != null) {

      final params = {
        'q': element.message!.content,
        'target': 'ky',
        'key': apiKey,
      };
      try {
        final response = await http.post(Uri.parse(apiUrl), body: params);

        final decodedResponse = json.decode(response.body);
        translationSecond = decodedResponse['data']['translations'][0]['translatedText'];

        print(translationSecond); // return translated text
      } catch (error) {
        print('Error translating text: $error');
        throw error; // rethrow error to handle it elsewhere if needed
      }
      setState(() {
      });
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer BROeCBj5mv4T4cGRuj0usAf42S0bvaCzZCoF3VfVIue8ShP5GVtsIQgr64ubMlct'
      };
      var jsonAudio=jsonEncode({
        "text": translationSecond,
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
        print(requestAudio.reasonPhrase);
      }
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
              user: _gptChatUser,
              createdAt: DateTime.now(),
              text: translationSecond),
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






  setState(() {
    chat=true;
    progress=false;
    _typingUsers.remove(_gptChatUser);
  });
}
  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton(
      onPressed: chat ? () async{
        audioPlayer.stop();
        chat=false;
        setState(() {
        });
      } : () async{
        ClipboardData? clipboardData = await Clipboard.getData('text/plain');
        if (clipboardData != null && clipboardData.text != null && copyText!=clipboardData.text) {
          copyText=clipboardData.text;
          selectScreen=true;
        }
        setState(() {
        });
      },
      child: chat ? Icon(Icons.arrow_back_ios_new_rounded) : Icon(Icons.list),
    ),
    /*appBar: AppBar(
      title: EpubViewActualChapter(

        controller: _epubReaderController,
        builder: (chapterValue) => Text(
          chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? '',
          textAlign: TextAlign.start,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.save_alt),
          color: Colors.white,
          onPressed: () => _showCurrentEpubCfi(context),
        ),
      ],
    ),*/
    body:
      SafeArea(
        child: chat ? Padding(
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
                // getChatResponse(m);
              },
              readOnly: true,
              messages: _messages),
        ) : progress ? Center(child: CircularProgressIndicator()) : selectScreen ? Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: (){
                _getAns();
                selectScreen=false;
                setState(() {

                });
              }, child: Text('Окуп беруу')),
              ElevatedButton(onPressed: (){
                _getAnsSecond(ChatMessage(user: _currentUser, text: copyText, createdAt: DateTime.now()));
                selectScreen=false;
                progress=true;
                setState(() {

                });
              }, child: Text('Маанисин билуу'))
            ],
          ),
        ) : Padding(
          padding: EdgeInsets.all(17),
          child: SelectableText(text,style: TextStyle(
            fontSize: 18
          ),),
        ),
      )
    /*EpubView(

      builders: EpubViewBuilders<DefaultBuilderOptions>(
        options: const DefaultBuilderOptions(),
        chapterDividerBuilder: (_) => const Divider(),
      ),
      controller: _epubReaderController,
    ),*/
  );
}