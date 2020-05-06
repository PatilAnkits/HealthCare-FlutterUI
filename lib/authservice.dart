import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'homepage.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phone Authentication',
      routes: <String, WidgetBuilder>{
        '/homepage': (BuildContext context) => DashboardPage(),
        '/loginpage': (BuildContext context) => MyApp(),
      },
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MyAppPage(title: 'MediKit'),
    );
  }
}

class MyAppPage extends StatefulWidget {
  MyAppPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyAppPageState createState() => _MyAppPageState();
}

class _MyAppPageState extends State<MyAppPage> {
  String phoneNo;
  String smsOTP;
  String verificationId;
  String errorMessage = '';
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> verifyPhone() async {
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      smsOTPDialog(context).then((value) {
        print('sign in');
      });
    };
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: this.phoneNo, // PHONE NUMBER TO SEND OTP
          codeAutoRetrievalTimeout: (String verId) {
            //Starts the phone number verification process for the given phone number.
            //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
            this.verificationId = verId;
          },
          codeSent:
              smsOTPSent, // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
          timeout: const Duration(seconds: 20),
          verificationCompleted: (AuthCredential phoneAuthCredential) {
            print(phoneAuthCredential);
          },
          verificationFailed: (AuthException exceptio) {
            print('${exceptio.message}');
          });
    } catch (e) {
      handleError(e);
    }
  }

  Future<bool> smsOTPDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter SMS Code'),
            content: Container(
              height: 85,
              child: Column(children: [
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: 'OTP'),
                  onChanged: (value) {
                    this.smsOTP = value;
                  },
                ),
                (errorMessage != ''
                    ? Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      )
                    : Container())
              ]),
            ),
            contentPadding: EdgeInsets.all(10),
            actions: <Widget>[
              RaisedButton(
                textColor: Colors.black,
                color: Colors.orange,
                child: Text('Done'),
                onPressed: () {
                  _auth.currentUser().then((user) {
                    if (user != null) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed('/homepage');
                    } else {
                      signIn();
                    }
                  });
                },
              )
            ],
          );
        });
  }

  signIn() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: smsOTP,
      );
      var credential2 = credential;
      final FirebaseUser user =
          (await _auth.signInWithCredential(credential2)).user;
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/homepage');
    } catch (e) {
      handleError(e);
    }
  }

  handleError(PlatformException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          errorMessage = 'Invalid Code';
        });
        Navigator.of(context).pop();
        smsOTPDialog(context).then((value) {
          print('sign in');
        });
        break;
      default:
        setState(() {
          errorMessage = error.message;
        });

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Color.fromRGBO(231, 76, 60, 50.0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text('MediKit',
            style: TextStyle(
                fontFamily: 'Montserrat', fontSize: 18.0, color: Colors.white)),
        centerTitle: true,
        actions: <Widget>[],
      ),
      body: SingleChildScrollView(
        child: new Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(125.0),
                  bottomLeft: Radius.circular(95.0)),
              color: Colors.white),
          height: MediaQuery.of(context).size.height - 110.0,
          width: MediaQuery.of(context).size.width,

          /* add child content here */
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 130.0,
                width: 130.0,
                child: new Image.asset("assets/images/steth.png"),
              ),
              SizedBox(
                height: 0.0,
              ),
              new Column(
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    'MediKit',
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'DancingScript',
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0,
                        color: Colors.black),
                  ),
                  SizedBox(height: 0.0),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      decoration: InputDecoration(
                          labelText: "Mobile No",
                          contentPadding:
                              new EdgeInsets.fromLTRB(20.0, 10.0, 100.0, 10.0),
                          border: OutlineInputBorder(),
                          hintText: ' Eg. +918698502533'),
                      onChanged: (value) {
                        this.phoneNo = value;
                      },
                    ),
                  ),
                  (errorMessage != ''
                      ? Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red),
                        )
                      : Container()),
                  SizedBox(
                    height: 10,
                  ),
                  RaisedButton(
                    color: Color.fromRGBO(231, 76, 60, 50.0),
                    onPressed: () {
                      verifyPhone();
                    },
                    child: Text('Verify'),
                  ),
                  SizedBox(
                    height: 30.0,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RaisedGradientButton extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double width;
  final double height;
  final Function onPressed;

  const RaisedGradientButton({
    Key key,
    @required this.child,
    this.gradient,
    this.width = double.infinity,
    this.height = 50.0,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 50.0,
      decoration: BoxDecoration(gradient: gradient, boxShadow: [
        BoxShadow(
          color: Colors.grey[500],
          offset: Offset(0.0, 1.5),
          blurRadius: 1.5,
        ),
      ]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: onPressed,
            child: Center(
              child: child,
            )),
      ),
    );
  }
}
