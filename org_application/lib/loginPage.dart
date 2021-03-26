import 'Bool.dart';
import 'color.dart';
import 'http_service.dart';
import 'scale_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'navigation.dart';

LightThemeColors colors = LightThemeColors();
Color backgroundColor = colors.getBackgroundColor();
Color textColor = colors.getTextColor();
Color logoColor = colors.getLogoColor();

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  bool _loginErrorIsActivated = false;
  Bool hasPlayed = Bool(value: false);
  bool isloading = false;

  @override
  Widget build(BuildContext context) {

    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;

    if (darkModeOn){
      DarkThemeColors colors = DarkThemeColors();
      backgroundColor = colors.backgroundColor;
      textColor = colors.textColor;
      logoColor = colors.logoColor;
    } else {
      LightThemeColors colors = LightThemeColors();
      backgroundColor = colors.backgroundColor;
      textColor = colors.textColor;
      logoColor = colors.logoColor;
    }

    TextStyle style = TextStyle(
        color: textColor, fontFamily: 'Ginto', fontSize: 14.0);
    final emailField = TextField(
        obscureText: false,
        style: style,
        controller: _emailController,
        onChanged: (String notUsed) {
          if (this.mounted) {
            setState(() {
              _loginErrorIsActivated = false;
            });
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, -10.0),
          hintText: "Email",
          hintStyle: style,
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: _loginErrorIsActivated
                      ? Color(0xFFFF4040)
                      : logoColor,
                  width: 2.0)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: _loginErrorIsActivated
                      ? Color(0xFFFF4040)
                      : logoColor,
                  width: 3.0)),
        ));
    final passwordField = TextField(
        obscureText: false,
        style: style,
        controller: _phoneNumberController,
        onChanged: (String notUsed) {
          if (this.mounted) {
            setState(() {
              _loginErrorIsActivated = false;
            });
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, -10.0),
          hintText: "Mobile number",
          hintStyle: style,
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: logoColor, width: 2.0)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: logoColor, width: 3.0)),
          errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: _loginErrorIsActivated
                      ? Color(0xFFFF4040)
                      : logoColor,
                  width: 2.0)),
          focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: _loginErrorIsActivated
                      ? Color(0xFFFF4040)
                      : logoColor,
                  width: 3.0)),
          errorText: _loginErrorIsActivated
              ? "Email and mobile number does not match"
              : null,
        ));

    final loginButton = Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(30.0),
      color: logoColor,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: !isloading
            ? () async {
                if (this.mounted) {
                  setState(() {
                    isloading = true;
                  });
                }
                HttpService httpService = HttpService();
                String loggedIn = await httpService.login(
                    _emailController.text, _phoneNumberController.text);
                if (loggedIn != null) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    Navigator.pop(context, true);
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Navigation(memberId: loggedIn)),
                        ModalRoute.withName('/'));
                  });
                } else {
                  if (this.mounted) {
                    setState(() {
                      _loginErrorIsActivated = true;
                      isloading = false;
                    });
                  }
                }
              }
            : null,
        child: RichText(
          text: TextSpan(
            text: 'Login',
            style: TextStyle(
              fontFamily: 'Ginto',
              color: textColor,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: AppBar(
                title: Text(''),// You can add title here
                leading: new IconButton(
                  icon: new Icon(Icons.arrow_back_ios, color: textColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                backgroundColor: backgroundColor, //You can make this transparent
                elevation: 0.0, //No shadow
              ),),
            Padding(
                padding:
                    EdgeInsets.only(top: height * 0.1, bottom: height * 0.06),
                child: Hero(
                  tag: 'logo',
                  child: Material(
                      type: MaterialType.transparency,
                      child: Text('invite',
                          style: TextStyle(
                              fontFamily: 'Ginto',
                              fontWeight: FontWeight.w600,
                              color: logoColor,
                              fontSize: 48))),
                )),
            Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 500),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 40.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: <Widget>[
                  Padding(
                      padding:
                          EdgeInsets.only(left: width / 12, right: width / 12),
                      child: emailField),
                  Container(
                      height: height / 6,
                      padding: EdgeInsets.only(
                          top: height / 30,
                          left: width / 12,
                          right: width / 12),
                      child: passwordField),
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.only(
                    top: height * 0.02, left: width / 12, right: width / 12),
                child: ScaledAnimation(
                  child: !isloading
                      ? loginButton
                      : CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              logoColor)),
                  delay_milliseconds: 500,
                  hasPlayed: hasPlayed,
                  key: UniqueKey(),
                ))
          ],
        ),
      ),
    );
  }
}
