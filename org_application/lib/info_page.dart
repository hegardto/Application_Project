import 'aboutpage_model.dart';
import 'color.dart';
import 'sponsor_card.dart';
import 'sponsors_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'http_service.dart';

LightThemeColors colors = LightThemeColors();
Color backgroundColor = colors.getBackgroundColor();
Color textColor = colors.getTextColor();
Color logoColor = colors.getLogoColor();

class InfoPage extends StatefulWidget {
  final String memberId;

  InfoPage({Key key, @required this.memberId}) : super(key: key);

  _InfoPageState createState() {
    return _InfoPageState(memberId: memberId);
  }
}

class _InfoPageState extends State<InfoPage>
    with AutomaticKeepAliveClientMixin {
  final HttpService httpService = HttpService();
  AboutPage aboutPageText;
  List<Sponsor> sponsors = [];
  final controller = PageController(viewportFraction: 0.8);
  String memberId;

  _InfoPageState({@required this.memberId});

  @override
  void initState() {
    super.initState();
    httpService.getAboutPageText().then((result) {
      if (result != null) {
        aboutPageText = result;
        if (this.mounted) {
          setState(() {});
        }
      }
    }).catchError((e) {
      print("inside catchError for AboutPageText");
      print(e.error);
    });
    httpService.getSponsors().then((result) {
      sponsors = result;
      if (this.mounted) {
        setState(() {});
      }
    }).catchError((e) {
      print("inside catchError for Sponsors");
      print(e.error);
    });
  }

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

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return LayoutBuilder(builder: (context, constraint) {
      return aboutPageText == null
          ? Center(
              child: CircularProgressIndicator(
                  valueColor:
                      new AlwaysStoppedAnimation<Color>(logoColor)))
          : SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraint.maxHeight),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              top: height * 0.02,
                              left: width / 12,
                              right: width / 12),
                        ),
                        Text(
                          'About us',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Ginto',
                              color: textColor),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: height / 18,
                              left: width / 12,
                              right: width / 12),
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: width / 12, right: width / 12),
                            child: Text(
                              aboutPageText.about,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: 'Ginto',
                                color: textColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: height / 20,
                              left: width / 12,
                              right: width / 12),
                        ),
                        Flexible(
                            fit: FlexFit.loose,
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: sponsors.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    // return the header
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          top: height * 0.02,
                                          bottom: height * 0.02),
                                      child: Text(
                                        "Sponsored by",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 22,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: logoColor,
                                            decorationThickness: 3,
                                            fontFamily: 'Ginto',
                                            color: textColor),
                                      ),
                                    );
                                  }
                                  index -= 1;
                                  return SponsorCard(
                                    sponsor: sponsors[index],
                                    key: UniqueKey(),
                                  );
                                })),
                      ]),
                ),
              ),
            );
    });
  }

  @override
  bool get wantKeepAlive => true;
}
