import 'color.dart';
import 'startPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'http_service.dart';

LightThemeColors colors = LightThemeColors();
Color backgroundColor = colors.getBackgroundColor();
Color textColor = colors.getTextColor();
Color logoColor = colors.getLogoColor();

class AccountPage extends StatefulWidget {
  final String memberId;
  AccountPage({Key key, @required this.memberId}) : super(key: key);
  @override
  _AccountPageState createState() => _AccountPageState(memberId: memberId);
}

class _AccountPageState extends State<AccountPage> {
  String memberId;

  Future<void> alert(BuildContext context, String title, String message) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(title,
              style: TextStyle(
                  fontSize: 18, fontFamily: 'Ginto', color: textColor)),
          content: Text(message,
              style: TextStyle(
                  color: textColor, fontFamily: 'Ginto', fontSize: 14)),
          actions: <Widget>[
            FlatButton(
              child: Text("No",
                  style: TextStyle(
                      color: textColor,
                      fontFamily: 'Ginto',
                      fontSize: 14,
                      fontWeight: FontWeight.w400)),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            Padding(
              padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.02),
              child: FlatButton(
                child: Text(
                  'Yes',
                  style: TextStyle(
                      color: logoColor,
                      fontFamily: 'Ginto',
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
                onPressed: () async {
                  Navigator.pop(context, true);
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => StartPage()),
                      ModalRoute.withName('/'));
                },
              ),
            ),
          ],
        );
      },
    );
  }

  final HttpService httpService = HttpService();
  _AccountPageState({@required this.memberId});
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

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

    final logOutButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: logoColor,
      child: MaterialButton(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        minWidth: width / 1.5,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          alert(context, "Log out", "Are you sure you want to log out?");
        },
        child: RichText(
          text: TextSpan(
            text: 'Log out',
            style: TextStyle(
              fontFamily: 'Ginto',
              color: textColor,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        top: true,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: height / 8),
              child: Hero(
                tag: 'logo',
                child: Material(
                  type: MaterialType.transparency,
                  child: Text('ORG',
                      style: TextStyle(
                          fontFamily: 'Ginto',
                          fontWeight: FontWeight.w600,
                          color: logoColor,
                          fontSize: 48)),
                ),
              ),
            ),
            FutureBuilder<Set<String>>(
                future: httpService.getMemberInfo(memberId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data != null) {
                      return Container(
                        alignment: Alignment.center,
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: height / 10),
                            Text(snapshot.data.first,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Ginto',
                                    fontSize: 22,
                                    color: textColor)),
                            SizedBox(height: height / 30),
                            Text(snapshot.data.last,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Ginto',
                                    fontSize: 18,
                                    color: textColor)),
                          ],
                        ),
                      );
                    } else {
                      return Text("Error fetching user info",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Ginto',
                              fontSize: 20,
                              color: textColor));
                    }
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Ginto',
                            fontSize: 20,
                            color: textColor));
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: height / 10),
                    child: Center(
                        child: CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                logoColor))),
                  );
                }),
          ],
        ),
      ),
      floatingActionButton: logOutButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
