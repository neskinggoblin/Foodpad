import 'dart:async';
import '../../models/recipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RecipeStepScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeStepScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  _RecipeStepScreenState createState() => _RecipeStepScreenState();
}

class _RecipeStepScreenState extends State<RecipeStepScreen> {
  int currentStepIndex = 0;
  int score = 0;
  late int countdown;
  late Timer timer;
  final databaseReference = FirebaseDatabase.instance.reference();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    countdown = widget.recipe.process[0].timer;
    startCountdown();
  }

  void startCountdown() {
    const duration = Duration(seconds: 1);

    timer = Timer.periodic(duration, (timer) {
      if (mounted) {
        setState(() {
          countdown--;

          if (countdown == 0) {
            timer.cancel();
            print("Countdown completed!");
          }
        });
      } else {
        timer.cancel(); // Cancel the timer if the widget is not mounted
      }
    });

    print("Start countdown for 10 seconds...");
  }

  void addRecipeScore() async {
    // Replace 'your_recipe_description' with the actual description of the recipe in your Firebase Database
    String recipeDescription = widget.recipe.key;

    //List<Map<String, dynamic>> score = [];
    //databaseReference.child('recipes/$recipeDescription').push().set(score);
    // Replace with actual data
    Map<String, dynamic> scoreData = {
      'id': user!.uid!,
      'profile_img': user!.photoURL!,
      'name': user!.displayName!,
      'scores': score,
    };

    DatabaseReference reference = FirebaseDatabase.instance
        .reference()
        .child('recipes/$recipeDescription/score');
    try {
      reference.once().then((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        // ตรวจสอบว่ามีข้อมูลหรือไม่
        if (snapshot.value != null) {
          // ได้รับข้อมูล
          Map<dynamic, dynamic> values = snapshot.value as Map;

          bool check = false;
          for (var entry in values.entries) {
            var key = entry.key;
            var value = entry.value;
            print('$key: $value');
            var score_ = value['scores'];
            var id = value['id'];
            print('คะแนน: $score_');
            if (id == user!.uid!) {
              check = true;
              if (score > score_) {
                print("id == user!.uid!");
                print(id == user!.uid!);
                reference.child(key).update(scoreData);
              }
            }
          }
          if (check == false) {
            reference.push().set(scoreData);
          }
        } else {
          print('ไม่มีข้อมูล');
          reference.push().set(scoreData);
        }
      });
    } catch (error) {
      print('เกิดข้อผิดพลาด: $error');
    }
    //databaseReference.child('recipes/$recipeDescription/score').push().set(scoreData);
  }

  void showSubmitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Row(
              children: [
                // Please Give us your profile,

                Flexible(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Congratulations!',
                      style: TextStyle(
                        fontFamily: 'Coiny',
                        color: Color.fromARGB(255, 255, 80, 80),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            content: GestureDetector(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'You have completed the recipe!',
                    style: TextStyle(
                      fontFamily: 'Coiny',
                      color: Color.fromARGB(255, 54, 52, 52),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Score : $score',
                        style: TextStyle(
                          fontSize: 24,
                          color: Color.fromARGB(255, 255, 153, 36),
                          fontFamily: 'Coiny',
                        ),
                      ),
                      SizedBox(width: 10),
                      Image.asset(
                        'assets/img/chef_score.png',
                        width: 24,
                        height: 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  addRecipeScore();
                  Navigator.pop(context); // Pop RecipeStepScreen

                  Navigator.pushReplacementNamed(context, '/recipe_details',
                      arguments: widget.recipe);
                },
                child: Text('OK'),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            elevation: 5,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    timer.cancel(); // Cancel the timer in the dispose method
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffFF9900),
        title: Text(
          'Cooking Steps',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontFamily: 'Coiny',
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 255, 253, 249),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left Card for Cooking Step
              Card(
                margin: EdgeInsets.symmetric(horizontal: 0.0),
                color: Colors.orange,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft:
                        Radius.circular(8.0), // Adjust the radius as needed
                    bottomLeft: Radius.circular(8.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cooking Steps',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontFamily: 'Coiny',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Right Card for Countdown
              Card(
                margin: EdgeInsets.symmetric(horizontal: 0.0),
                color: Color.fromARGB(255, 255, 255, 255),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight:
                        Radius.circular(8.0), // Adjust the radius as needed
                    bottomRight: Radius.circular(8.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(children: [
                        Image.asset(
                          'assets/img/countdown.png',
                          width: 24,
                          height: 24,
                        ),
                        Text(
                          ' $countdown s',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xffFF3333),
                            fontFamily: 'Coiny',
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step ${currentStepIndex + 1}:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Sriracha',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.recipe.process[currentStepIndex].name,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Sriracha',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (currentStepIndex <
                            widget.recipe.process.length - 1) {
                          setState(() {
                            currentStepIndex++;
                            countdown =
                                widget.recipe.process[currentStepIndex].timer;
                          });
                          startCountdown();
                        } else {
                          showSubmitDialog();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding:
                            EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Coiny',
                        ),
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        if (currentStepIndex <
                            widget.recipe.process.length - 1) {
                          if (countdown == 0) {
                            setState(() {
                              currentStepIndex++;
                              countdown =
                                  widget.recipe.process[currentStepIndex].timer;
                              score += 100;
                            });
                            startCountdown();
                          }
                        } else if (currentStepIndex ==
                                widget.recipe.process.length - 1 &&
                            countdown == 0) {
                          setState(() {
                            showSubmitDialog();
                            score += 100;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding:
                            EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'Next',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Coiny',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
