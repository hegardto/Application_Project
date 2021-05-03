import 'dart:ui';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'color.dart';
import 'http_service.dart';
import 'ticket_model.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'event_model.dart';
import 'package:flash/flash.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/cupertino.dart';
import 'event_info_card.dart';

LightThemeColors colors = LightThemeColors();
Color backgroundColor = colors.getBackgroundColor();
Color textColor = colors.getTextColor();
Color logoColor = colors.getLogoColor();

class EventOpenCard extends StatefulWidget {
  Event event;
  String memberId;

  EventOpenCard({Key key, @required this.event, @required this.memberId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      EventOpenCardState(event: event, memberId: memberId);
}

class EventOpenCardState extends State<EventOpenCard> {
  Event event;
  String memberId;
  HttpService httpService = HttpService();
  TicketStatus ticketStatus;

  EventOpenCardState({@required this.event, @required this.memberId});

  Container makeTextSection(String title, String text, TextStyle textStyleTitle,
      TextStyle textStyleText, Color backgroundColor, Size size) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              title,
              style: textStyleTitle,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Padding(
            padding:
                EdgeInsets.only(left: size.width / 12, right: size.width / 12),
            child: Text(
              text,
              style: textStyleText,
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),
        ],
      ),
    );
  }

  Future<void> alert(BuildContext context, String title, String message,
      String performActionText, Color performActionColor, bool addTicket) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        var brightness = MediaQuery.of(context).platformBrightness;
        bool darkModeOn = brightness == Brightness.dark;

        if (darkModeOn) {
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

        ProgressDialog progressDialog = ProgressDialog(
          context,
          type: ProgressDialogType.Normal,
          isDismissible: false,
        );

        progressDialog.style(
          insetAnimCurve: Curves.elasticInOut,
          progressWidget: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(logoColor)),
          backgroundColor: backgroundColor,
          messageTextStyle: TextStyle(color: textColor, fontFamily: 'Ginto'),
        );

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
              child: Text("Cancel",
                  style: TextStyle(
                      color: textColor,
                      fontFamily: 'Ginto',
                      fontSize: 14,
                      fontWeight: FontWeight.w400)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Padding(
              padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.02),
              child: FlatButton(
                  child: Text(
                    performActionText,
                    style: TextStyle(
                        color: performActionColor,
                        fontFamily: 'Ginto',
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                  onPressed: addTicket
                      ? () async {
                          Navigator.of(context).pop();
                          progressDialog.show();
                          Ticket ticket =
                              await httpService.addTicket(event.id, memberId);

                          if (this.mounted) {
                            setState(() {});
                          }
                          if (ticket != null) {
                            _showCenterFlash(
                                position: FlashPosition.top,
                                style: FlashStyle.floating,
                                text: "Ticket added");
                          } else {
                            _showCenterFlash(
                                position: FlashPosition.top,
                                style: FlashStyle.floating,
                                text: "Error adding ticket");
                          }

                          await progressDialog.hide();
                        }
                      : () async {
                          Navigator.of(context).pop();
                          progressDialog.show();
                          bool deleted = await httpService.deleteTicket(
                              event.id, memberId);
                          if (deleted) {
                            if (this.mounted) {
                              setState(() {});
                            }
                            _showCenterFlash(
                                position: FlashPosition.top,
                                style: FlashStyle.floating,
                                text: "Ticket deleted");
                          } else {
                            _showCenterFlash(
                                position: FlashPosition.top,
                                style: FlashStyle.floating,
                                text: "Error deleting the ticket");
                          }
                          await progressDialog.hide();
                        }),
            ),
          ],
        );
      },
    );
  }

  void _showCenterFlash(
      {FlashPosition position,
      FlashStyle style,
      Alignment alignment,
      String text}) {
    showFlash(
      context: context,
      duration: Duration(seconds: 2),
      builder: (_, controller) {
        return Flash(
          controller: controller,
          backgroundColor: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
          borderColor: logoColor,
          position: position,
          style: style,
          alignment: alignment,
          enableDrag: false,
          onTap: () => controller.dismiss(),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: DefaultTextStyle(
              style: TextStyle(color: textColor, fontFamily: 'Ginto'),
              child: Text(
                text,
              ),
            ),
          ),
        );
      },
    ).then((_) {
      if (_ != null) {
        _showMessage(_.toString());
      }
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    showFlash(
        context: context,
        duration: Duration(seconds: 3),
        builder: (_, controller) {
          return Flash(
            controller: controller,
            position: FlashPosition.top,
            style: FlashStyle.grounded,
            child: FlashBar(
              icon: Icon(
                Icons.face,
                size: 36.0,
                color: backgroundColor,
              ),
              message: Text(message),
            ),
          );
        });
  }

  CircularProgressIndicator progressIndicator() {
    return CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(logoColor));
  }

  Material attendButton(String buttonText, Color color) {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: color,
      child: MaterialButton(
        //disabledColor: Colors.black,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        minWidth: MediaQuery.of(context).size.width / 1.5,
        onPressed: ticketStatus == TicketStatus.available
            ? () async {
                alert(
                    context,
                    "Get ticket",
                    "NOTE! You can not cancel or remove your ticket if/when it is less than 24h left before the event. Check the important note section if there will be a fee for not showing up!",
                    "Proceed",
                    logoColor,
                    true);
              }
            : ticketStatus == TicketStatus.owned_throwable
                ? () async {
                    alert(
                        context,
                        "Delete ticket",
                        "Are you sure you want to delete your ticket?",
                        "Proceed",
                        Colors.red,
                        false);
                  }
                : null,
        child: RichText(
          text: TextSpan(
            text: buttonText,
            style: TextStyle(
              fontFamily: 'Ginto',
              color: textColor,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  Material infoButton(BuildContext context, Event event, String memberId,
      String section, String infoText) {
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(30.0),
      borderOnForeground: false,
      color: textColor,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: RaisedButton(
          color: textColor,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: textColor, width: 2),
              borderRadius: BorderRadius.circular(30)),
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          onPressed: () {
            Navigator.push(
                context,
                !Platform.isIOS
                    ? PageTransition(
                        duration: Duration(milliseconds: 420),
                        type: PageTransitionType.fade,
                        child: EventInfoCard(
                            event: event,
                            memberId: memberId,
                            section: section,
                            infoText: infoText),
                      )
                    : CupertinoPageRoute(
                        builder: (context) => EventInfoCard(
                            event: event,
                            memberId: memberId,
                            section: section,
                            infoText: infoText),
                      ));
          },
          child: RichText(
            text: TextSpan(
              text: section,
              style: TextStyle(
                fontFamily: 'Ginto',
                color: backgroundColor,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;

    if (darkModeOn) {
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

    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              backgroundColor: logoColor,
              expandedHeight: MediaQuery.of(context).size.height * 0.32,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  event.title,
                  style: TextStyle(
                      color: textColor,
                      fontFamily: 'Ginto',
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
                background: Stack(children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.32,
                    decoration: new BoxDecoration(color: backgroundColor),
                  ),
                  Positioned(
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        return LinearGradient(
                          colors: [backgroundColor, Colors.transparent],
                          begin: FractionalOffset.topCenter,
                          end: FractionalOffset.bottomCenter,
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.dstIn,
                      child: Container(
                        alignment: Alignment.topCenter,
                        height: (MediaQuery.of(context).size.height * 0.32)
                            .floor()
                            .toDouble(),
                        width: MediaQuery.of(context).size.width,
                        child: event.image != null
                            ? CachedNetworkImage(
                                imageUrl: event.image,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover),
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
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            SliverList(
                delegate: SliverChildListDelegate(
              [
                SizedBox(height: size.height * 0.04),
                Padding(
                  padding: EdgeInsets.only(
                      left: size.width / 12, right: size.width / 12),
                  child: Container(
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
                                  DateFormat('MMMM dd yyyy')
                                          .format(event.date) +
                                      "     ",
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
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                makeTextSection(
                    event.introductionTitle,
                    event.introduction,
                    TextStyle(
                      fontFamily: 'Ginto',
                      fontSize: 20,
                      color: textColor,
                    ),
                    TextStyle(
                        fontFamily: 'Ginto', fontSize: 14, color: textColor),
                    backgroundColor,
                    size),
                SizedBox(height: size.height * 0.01),
                infoButton(context, event, memberId, "About the event",
                    event.description),
                SizedBox(height: size.height * 0.01),
                infoButton(context, event, memberId, "Important note",
                    event.importantNote),
                SizedBox(height: size.height * 0.01),
                infoButton(context, event, memberId, "Members",
                    "Todo: Add this feature"),
                SizedBox(height: size.height * 0.01),
                infoButton(context, event, memberId, "Dresscode",
                    "Todo: Add this feature"),
                SizedBox(height: size.height * 0.01),
                infoButton(context, event, memberId, "Location",
                    "Todo: Add this feature"),
                SizedBox(
                  height: size.height * 0.08,
                )
              ],
            ))
          ],
        ),
        floatingActionButton: FutureBuilder<TicketStatus>(
            future: httpService.getTicketStatus(event.id, memberId),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                ticketStatus = snapshot.data;
                if (ticketStatus == TicketStatus.available) {
                  return SafeArea(child: attendButton("Join event", logoColor));
                } else if (ticketStatus == TicketStatus.event_full) {
                  return SafeArea(
                      child: attendButton("Event full", backgroundColor));
                } else if (ticketStatus == TicketStatus.event_outdated) {
                  return SafeArea(
                      child: attendButton("Event outdated", backgroundColor));
                } else if (ticketStatus == TicketStatus.owned_throwable) {
                  return SafeArea(
                      child: attendButton("Leave event", Colors.red));
                } else if (ticketStatus == TicketStatus.owned_not_throwable) {
                  return SafeArea(
                      child:
                          attendButton("Less than 24h left", backgroundColor));
                }
              } else if (snapshot.hasError) {
                return Text("Error getting ticket status from server",
                    style: TextStyle(
                        fontFamily: 'Ginto', fontSize: 22, color: Colors.red));
              }
              return progressIndicator();
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
