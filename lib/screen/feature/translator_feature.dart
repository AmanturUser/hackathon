import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../controller/image_controller.dart';
import '../../controller/translate_controller.dart';
import '../../helper/global.dart';
import '../../widget/custom_btn.dart';
import '../../widget/custom_loading.dart';
import '../../widget/language_sheet.dart';

class TranslatorFeature extends StatefulWidget {
  const TranslatorFeature({super.key});

  @override
  State<TranslatorFeature> createState() => _TranslatorFeatureState();
}

class _TranslatorFeatureState extends State<TranslatorFeature> {
  final _c = TranslateController();


  @override
  void dispose() {
    audioPlayer.stop();
    // TODO: implement dispose
    super.dispose();
  }

  final apiKey = 'AIzaSyAPXbaIlXvuDRCDtnPdh0lh83bo0zW0fps'; // Replace with your actual API key
  final apiUrl = 'https://translation.googleapis.com/language/translate/v2';

  late var audioData;
  final AudioPlayer audioPlayer = AudioPlayer();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //app bar
      appBar: AppBar(
        title: const Text('Котормочу'),
      ),

      //body
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(top: mq.height * .02, bottom: mq.height * .1),
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            //from language
            InkWell(
              onTap: () => Get.bottomSheet(LanguageSheet(c: _c, s: _c.from)),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              child: Container(
                height: 50,
                width: mq.width * .4,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: const BorderRadius.all(Radius.circular(15))),
                child:
                    Obx(() => Text(_c.from.isEmpty ? 'Auto' : _c.from.value)),
              ),
            ),

            //swipe language btn
            IconButton(
                onPressed: _c.swapLanguages,
                icon: Obx(
                  () => Icon(
                    CupertinoIcons.repeat,
                    color: _c.to.isNotEmpty && _c.from.isNotEmpty
                        ? Colors.blue
                        : Colors.grey,
                  ),
                )),

            //to language
            InkWell(
              onTap: () => Get.bottomSheet(LanguageSheet(c: _c, s: _c.to)),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              child: Container(
                height: 50,
                width: mq.width * .4,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: const BorderRadius.all(Radius.circular(15))),
                child: Obx(() => Text(_c.to.isEmpty ? 'To' : _c.to.value)),
              ),
            ),
          ]),

          //text field
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .035),
            child: TextFormField(
              controller: _c.textC,
              minLines: 5,
              maxLines: null,
              onTapOutside: (e) => FocusScope.of(context).unfocus(),
              decoration: const InputDecoration(
                  hintText: 'Которуу...',
                  hintStyle: TextStyle(fontSize: 13.5),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)))),
            ),
          ),

          //result field
          Obx(() => _translateResult()),

          //for adding some space
          SizedBox(height: mq.height * .04),

          //translate btn
          CustomBtn(
            onTap: _c.googleTranslate,
            // onTap: _c.translate,
            text: 'Которуу',
          )
        ],
      ),
    );
  }

  Widget _translateResult() => switch (_c.status.value) {
        Status.none => const SizedBox(),
        Status.complete => Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .04),
            child: TextFormField(

              controller: _c.resultC,
              maxLines: null,
              onTapOutside: (e) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
              suffixIcon: IconButton(onPressed:() async{
                try {
                  var headers = {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer BROeCBj5mv4T4cGRuj0usAf42S0bvaCzZCoF3VfVIue8ShP5GVtsIQgr64ubMlct'
                  };
                  var jsonAudio=jsonEncode({
                    "text": _c.resultC.text,
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
              }, icon: const Icon(Icons.mic)),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)))),
            ),
          ),
        Status.loading => const Align(child: CustomLoading())
      };
}
