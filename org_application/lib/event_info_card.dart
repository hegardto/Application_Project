import 'dart:ui';
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
import 'package:flutter/cupertino.dart';

LightThemeColors colors = LightThemeColors();
Color backgroundColor = colors.getBackgroundColor();
Color textColor = colors.getTextColor();
Color logoColor = colors.getLogoColor();

class EventInfoCard extends StatefulWidget {
  Event event;
  String memberId;
  String section;
  String infoText;

  EventInfoCard(
      {Key key,
      @required this.event,
      @required this.memberId,
      @required this.section,
      @required this.infoText})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => EventInfoCardState(
      event: event, memberId: memberId, section: section, infoText: infoText);
}

class EventInfoCardState extends State<EventInfoCard> {
  Event event;
  String memberId;
  String section;
  String infoText;
  HttpService httpService = HttpService();
  TicketStatus ticketStatus;

  EventInfoCardState(
      {@required this.event, @required this.memberId, @required this.section, @required this.infoText});

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
                SizedBox(height: size.height * 0.06),
                makeTextSection(
                    section,
                    infoText,
                    TextStyle(
                      fontFamily: 'Ginto',
                      fontSize: 20,
                      color: textColor,
                    ),
                    TextStyle(
                        fontFamily: 'Ginto', fontSize: 14, color: textColor),
                    backgroundColor,
                    size),
                SizedBox(
                  height: size.height * 0.08,
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
