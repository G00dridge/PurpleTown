import 'dart:core';
import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'decision_map.dart';

//Reference to List kept here
late Box<DecisionMap> box;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();   //HIVE SETUP
  Hive.registerAdapter(DecisionMapAdapter());
  box = await Hive.openBox<DecisionMap>('decisionMap');

  String csv = "assets/decision_map.csv"; //path to csv file asset
  String fileData = await rootBundle.loadString(csv);
  print(fileData);
  List <String> rows = fileData.split("\n");
  for (int i = 0; i < rows.length; i++)  {
    //selects an item from row and places
    String row = rows[i];
    List <String> itemInRow = row.split(",");
    DecisionMap decMap = DecisionMap()
      ..id = int.parse(itemInRow[0])
      ..option1Id = int.parse(itemInRow[1])
      ..option2Id = int.parse(itemInRow[2])
      ..description = itemInRow[3]
      ..question = itemInRow[4]
      ..option1 = itemInRow[5]
      ..option2 = itemInRow[6]
      ..summary = itemInRow[7]
      ..hint1 = itemInRow[8]
      ..hint2 = itemInRow[9];
      int key = int.parse(itemInRow[0]);
      box.put(key, decMap);
  }

  runApp (
    const MaterialApp(
      home: MyFlutterApp(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class MyFlutterApp extends StatefulWidget {
  const MyFlutterApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyFlutterState();
  }
}
class MyFlutterState extends State<MyFlutterApp> with TickerProviderStateMixin {

  //WRITE VARIABLES AND EVENT HANDLERS HERE
  late final AudioPlayer _audioPlayer2;
  late final AudioPlayer _audioPlayer;
  late int sleepCounter;
  late Color backgroundColour;
  late int id;
  late int option1Id;
  late int option2Id;
  late String description;
  late String question;
  late String option1;
  late String option2;
  late String summary;
  late String hint1;
  late String hint2;
  late String border;
  late String tempBorder;
  late bool alive;
  late AnimationController _controller1;
  late AnimationController _controller2;
  late Animation<int> typingAnimation;
  late Animation<int> borderAnimation;
  String tempSummary = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        //PLACE CODE HERE YOU WANT TO EXECUTE IMMEDIATELY AFTER
        //THE UI IS BUILT
        _audioPlayer = AudioPlayer();
        _audioPlayer2 = AudioPlayer();
        DecisionMap? current = box.get(11);
        if(current != null) {
          id = current.id;
          option1Id = current.option1Id;
          option2Id = current.option2Id;
          description = '${current.description}\n${current.question}';
          option1 = current.option1;
          option2 = current.option2;
          summary = current.summary;
          hint1 = current.hint1;
          hint2 = current.hint2;
          border = " " * 2599;
          sleepCounter = 0;
          backgroundColour = Colors.black;
          alive = true;
          makeBorder(hint1, hint2);
          _controller1 = AnimationController(vsync: this, duration: Duration(seconds: 7));
          _controller2 = AnimationController(vsync: this, duration: Duration(seconds: 4));
          typingAnimation = IntTween(begin: 0, end: description.length).animate(_controller1);
          borderAnimation = IntTween(begin: 0, end: tempBorder.length).animate(_controller2);
          repeatOnce();
          setBackgroundAudio();

        }
      });
    });
  }

  @override
  void dispose(){
    _audioPlayer2.dispose();
    _audioPlayer.dispose();
    _controller1.dispose();
    super.dispose();
  }

  void checkNodes(DecisionMap? current) async {
    if(current != null) {
      id = current.id;
      option1Id = current.option1Id;
      option2Id = current.option2Id;
      description = '${current.description}\n${current.question}';
      option1 = current.option1;
      option2 = current.option2;
      tempSummary = summary;
      summary = summary + current.summary;
      hint1 = current.hint1;
      hint2 = current.hint2;
      typingAnimation = IntTween(begin: 0, end: description.length).animate(_controller1);
      repeatOnce();
      if(id == 12){
        sleepCounter ++;
        backgroundColour = Colors.black;
        alive = true;
        summary ='';
      }
      else if(id == 00){
        description = summary;
        typingAnimation = IntTween(begin: 0, end: description.length).animate(_controller1);
        backgroundColour = const Color(0xF7A90631);
        borderAnimation = IntTween(begin: 0, end: tempBorder.length).animate(_controller2);
        tempBorder = " "*2599;
        alive = false;
        sleepCounter = 0;
      }

      if(sleepCounter == 3){
        DecisionMap? current = box.get(1);
        sleepCounter = 0;

        if(current != null) {
          id = current.id;
          option1Id = current.option1Id;
          option2Id = current.option2Id;
          description = '${current.description}\n${current.question}';
          option1 = current.option1;
          option2 = current.option2;
          tempSummary = summary;
          summary = summary+current.summary;
          hint1 = current.hint1;
          hint2 = current.hint2;
          typingAnimation = IntTween(begin: 0, end: description.length).animate(_controller1);
          repeatOnce();
        }
      }
    }
    if (option1.length > 20 || option2.length >= 20 ){
     option1 = '${option1.substring(0,20)}\n ${option1.substring(20,option1.length)}';
     option2 = '${option2.substring(0,20)}\n ${option2.substring(20,option2.length)}';
   }
  }

  Future setBackgroundAudio() async{
     await _audioPlayer.setAsset('midnight.mp3');
    _audioPlayer.play();
    await _audioPlayer.setLoopMode(LoopMode.all);
  }

  Future clickSound() async{
    await _audioPlayer2.setAsset('cork.mp3');
    _audioPlayer2.play();
  }

  void clickHandler1() {
    setState((){
      clickSound();
      if (option1 == 'Respawn from last decision'){
        summary = tempSummary;
      }
      DecisionMap? current = box.get(option1Id);

      _controller2.reverse();
      checkNodes(current);

    });
  }

  void clickHandler2() {
    setState((){
      clickSound();
      _controller2.reverse();
      DecisionMap? current = box.get(option2Id);
      checkNodes(current);
    });
  }

  String borderTop(){
    String top = '';
    String charactersForBorder = 'ABCDEFGHJKLNOPQRSTUVWXYZ';
    Random random = Random();
    for(int i = 0; i < 88; i++){
      int randomNumber = random.nextInt(24);
      top = top + charactersForBorder[randomNumber];
    }
    return top;
  }

  String borderSides(){
    String sides = '';
    String spaces = '_________________________________________________________________________________________________';
    String charactersForBorder = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    Random random = Random();
    for(int i = 0; i < 22; i++){
      int randomNumber = random.nextInt(24);
      sides = '$sides${charactersForBorder[randomNumber]}|$spaces|${charactersForBorder[randomNumber + 1]}\n';
    }
    return sides;
  }

  void makeBorder(String hint1,  String hint2){
    List<String> hints =[hint1, hint2];
    List<String> verticalBorderList = [ borderTop(), borderTop(), borderTop(), borderTop()];
    Random random = Random();
    for(String hint in hints){ // creates max bounds for random numbers to ensure hint length fits within border and puts them in
      int hintLength = 88 - hint.length;
      int topPicker = random.nextInt(3); //selects which border the hint goes in
      int hintPosition = random.nextInt(hintLength);
      verticalBorderList[topPicker] = verticalBorderList[topPicker].replaceRange(hintPosition, hintPosition+hint.length, hint);
    }
    tempBorder = '${verticalBorderList[0]}\n${verticalBorderList[1]}\n${borderSides()}${verticalBorderList[2]}\n${verticalBorderList[3]}';
  }

  void repeatOnce() async {
    _controller2.reset();
    border = tempBorder;
    makeBorder(hint1, hint2);
    _controller2.forward();
    _controller1.reset();
    await _controller1.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColour,
        body: Align(
          alignment: Alignment.center,
          child: SizedBox( // main body of the web app
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Stack( // main container for all the widgets
                  alignment: Alignment.topLeft,
                  children: [
                    Align( // Text border
                        alignment: const Alignment(0.0, -0.8),
                      child: DefaultTextStyle(
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 15,
                            color: Color(0xff16f52a),
                          ),
                          child: AnimatedBuilder(
                            animation: borderAnimation,
                            builder: (BuildContext context, Widget? child) {
                              return Text(border.replaceRange(0, borderAnimation.value, tempBorder.substring(0,borderAnimation.value)),
                                style: GoogleFonts.piazzolla(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.purple,
                                  shadows: [
                                    const Shadow(
                                      blurRadius: 1,
                                      color: Color(0xFFF3E5F5),
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                      ),
                    ),
                    Align(
                      alignment: const Alignment(-0.6, 0.5),
                      child: MaterialButton( // option1 button widget
                        onPressed: () {clickHandler1();},
                        color: const Color(0xff3a21d9),
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        textColor: const Color(0xfffffdfd),
                        height: 100,
                        minWidth: 190,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(
                          option1,
                          overflow: TextOverflow.fade,

                          maxLines: 2,
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0.6, 0.5),
                      child: Visibility(
                        visible: alive,
                        child: MaterialButton( // option2 button widget
                          onPressed: () {clickHandler2();},
                          color: const Color(0xff3a21d9),
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          textColor: const Color(0xfffffdfd),
                          height: 100,
                          minWidth: 190,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            option2,
                            overflow: TextOverflow.fade,

                            maxLines: 2,
                            softWrap: true,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                        alignment: const Alignment(0.0, -0.5 ),
                        child: SizedBox( // Description text
                            width: 900,
                            child: Align(alignment: const Alignment(0.0, -0.5),
                              child: DefaultTextStyle(
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 15,
                                    color: Color(0xff16f52a),
                                  ),
                                  child: AnimatedBuilder(
                                    animation: typingAnimation,
                                    builder: (BuildContext context, Widget? child) {
                                      return Text("${description.substring(0, typingAnimation.value)}_");
                                    }
                                    ),
                            )
                        )
                        ),
                    ),
                    Align(
                      alignment: const Alignment(0.0, -0.8),
                      child: TextLiquidFill( // game title text widget
                        text:'PURPLE TOWN',
                        waveColor: const Color(0xffb968ce),
                        waveDuration: const Duration(seconds: 15),
                        boxBackgroundColor: const Color(0xff16f52a),
                        boxHeight: 40,
                        textStyle: const TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ])
          ),
        ));
  }
}