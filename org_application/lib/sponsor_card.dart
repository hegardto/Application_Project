import 'package:cached_network_image/cached_network_image.dart';
import 'package:cwa_application/sponsors_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'color.dart';

LightThemeColors colors = LightThemeColors();
Color backgroundColor = colors.getBackgroundColor();
Color textColor = colors.getTextColor();
Color logoColor = colors.getLogoColor();

class SponsorCard extends StatefulWidget {
  final Sponsor sponsor;
  SponsorCard({@required this.sponsor, @required key}) : super(key: key);
  @override
  _SponsorCardState createState() {
    return _SponsorCardState(sponsor: sponsor);
  }
}

class _SponsorCardState extends State<SponsorCard> {
  Sponsor sponsor;

  _SponsorCardState({@required this.sponsor});
  @override
  Widget build(BuildContext context) {
    return CustomListItem(
      sponsor: sponsor,
    );
  }
}

class CustomListItem extends StatelessWidget {
  const CustomListItem({@required this.sponsor});
  final Sponsor sponsor;

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
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 80),
      child: Hero(
        tag: sponsor.sponsor,
        child: Material(
          type: MaterialType.transparency,
          child: Stack(children: <Widget>[
            Container(
              height: height / 2,
              decoration: new BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                      topRight: Radius.circular(4),
                      bottomLeft: Radius.circular(4)),
                  color: backgroundColor),
            ),
            Positioned.fill(
              top: height / 3.54,
              left: width / 12,
              right: width / 12,
              bottom: height * 0.14,
              child: Text(
                sponsor.sponsor,
                style: TextStyle(
                  fontFamily: 'Ginto',
                  color: textColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 22.0,
                ),
              ),
            ),
            Positioned(
              top: height / 40,
              left: width / 24,
              right: width / 24,
              child: ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      colors: [Colors.black, Colors.transparent],
                      begin: FractionalOffset.topCenter,
                      end: FractionalOffset.bottomCenter,
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Container(
                    alignment: Alignment.topCenter,
                    height: (height / 3).ceil().toDouble() + 1,
                    width: width / 1.08,
                    child: sponsor.logo != null
                        ? CachedNetworkImage(
                            imageUrl: sponsor.logo,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)),
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.contain),
                              ),
                            ),
                            placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            logoColor))),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          )
                        : Image.asset("assets/ORG.jpg"),
                  )),
            ),
          ]),
        ),
      ),
    );
  }
}
