import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'event_open_card_2.dart';
import 'color.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'event_model.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

LightThemeColors colors = LightThemeColors();
Color backgroundColor = colors.getBackgroundColor();
Color textColor = colors.getTextColor();
Color logoColor = colors.getLogoColor();

class EventCard extends StatelessWidget {
  Event event;
  String memberId;
  EventCard({@required this.event, @required this.memberId, @required Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomListItem(
      event: event,
      memberId: memberId,
    );
  }
}

class CustomListItem extends StatelessWidget {
  const CustomListItem({@required this.event, @required this.memberId});
  final Event event;
  final String memberId;

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

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            !Platform.isIOS
                ? PageTransition(
                    duration: Duration(milliseconds: 420),
                    type: PageTransitionType.fade,
                    child: EventOpenCard(
                      event: event,
                      memberId: memberId,
                    ),
                  )
                : CupertinoPageRoute(
                    builder: (context) =>
                        EventOpenCard(event: event, memberId: memberId)));
      },
      child: Padding(
        padding: EdgeInsets.only(top: height / 80),
        child: Stack(children: <Widget>[
          ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                colors: [Colors.transparent, Colors.black, Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(rect);
            },
            blendMode: BlendMode.overlay,
            child: Container(
              height: height / 2,
              decoration: new BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                      topRight: Radius.circular(4),
                      bottomLeft: Radius.circular(4)),
                  color: backgroundColor),
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
                  child: event.image != null
                      ? CachedNetworkImage(
                          imageUrl: event.image,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6)),
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                          placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      logoColor))),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        )
                      : Image.asset("assets/ORG.jpg"),
                )),
          ),
          Positioned.fill(
            top: height / 3.54,
            left: width / 12,
            right: width / 12,
            bottom: height * 0.14,
            child: Text(
              event.title,
              style: TextStyle(
                fontFamily: 'Ginto',
                color: textColor,
                fontWeight: FontWeight.w400,
                fontSize: 22.0,
              ),
            ),
          ),
          Positioned(
            width: width / 1.08,
            top: height / 2.74,
            left: width / 24,
            child: InfoSection(event: event),
          )
        ]),
      ),
    );
  }
}

class InfoSection extends StatelessWidget {
  InfoSection({Key key, this.event}) : super(key: key);

  Event event;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  FeatherIcons.mapPin,
                  color: textColor,
                  size: 18,
                ),
              ),
              Flexible(
                  child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  event.location,
                  style: TextStyle(
                      fontFamily: 'Ginto',
                      color: textColor,
                      fontSize: 12),
                ),
              ))
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    FeatherIcons.calendar,
                    color: event.date.isBefore(DateTime.now())
                        ? Colors.red
                        : textColor,
                    size: 18,
                  ),
                ),
                Flexible(
                    child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    DateFormat('MMMM dd yyyy').format(event.date) + "     ",
                    style: TextStyle(
                        fontFamily: 'Ginto',
                        color: event.date.isBefore(DateTime.now())
                            ? Colors.red
                            : textColor,
                        fontSize: 12),
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    FeatherIcons.clock,
                    color: event.date.isBefore(DateTime.now())
                        ? Colors.red
                        : textColor,
                    size: 18,
                  ),
                ),
                Flexible(
                    child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    event.time,
                    style: TextStyle(
                        fontFamily: 'Ginto',
                        color: event.date.isBefore(DateTime.now())
                            ? Colors.red
                            : textColor,
                        fontSize: 12),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
