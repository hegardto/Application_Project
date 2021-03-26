import 'color.dart';
import 'http_service.dart';
import 'ticket_model.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flash/flash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

LightThemeColors colors = LightThemeColors();
Color backgroundColor = colors.getBackgroundColor();
Color textColor = colors.getTextColor();
Color logoColor = colors.getLogoColor();

class TicketCard extends StatefulWidget {
  Ticket ticket;
  double height;
  double width;
  Function deleteTicket;
  String memberId;

  TicketCard(
      {@required this.ticket,
      @required this.height,
      @required this.width,
      @required this.deleteTicket,
      @required this.memberId});

  @override
  _TicketState createState() {
    return _TicketState(
        ticket: ticket,
        height: height,
        width: width,
        deleteTicket: deleteTicket,
        memberId: memberId);
  }
}

class _TicketState extends State<TicketCard> {
  Ticket ticket;
  String memberId;
  double height;
  double width;
  Function deleteTicket;
  final HttpService httpService = HttpService();

  _TicketState(
      {@required this.ticket,
      @required this.height,
      @required this.width,
      @required this.deleteTicket,
      @required this.memberId});
  @override
  bool _isExpanded = false;
  Widget middleWidget;
  double animatedHeight;

  @override
  void initState() {
    super.initState();
    middleWidget = Divider(
      color: logoColor,
      thickness: 2,
      indent: width * 0.06,
      endIndent: width * 0.06,
    );
    animatedHeight = height * 0.16;
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

    double fullWidth = MediaQuery.of(context).size.width;
    double fullHeight = MediaQuery.of(context).size.height;

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
                    fontSize: 18,
                    fontFamily: 'Ginto',
                    color: textColor)),
            content: Text(message,
                style: TextStyle(
                    color: textColor,
                    fontFamily: 'Ginto',
                    fontSize: 14)),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel",
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
                padding: EdgeInsets.only(right: width * 0.02),
                child: FlatButton(
                    child: Text(
                      'Delete',
                      style: TextStyle(
                          color: Color(0xFFFB6940),
                          fontFamily: 'Ginto',
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                    onPressed: () async {
                      Navigator.pop(context, true);
                      TicketStatus ticketStatus = await httpService
                          .getTicketStatus(ticket.event.id, memberId);

                      if (ticketStatus == TicketStatus.event_outdated) {
                        _showCenterFlash(
                            position: FlashPosition.top,
                            style: FlashStyle.floating,
                            text: "Event is outdated");
                      } else if (ticketStatus ==
                          TicketStatus.owned_not_throwable) {
                        _showCenterFlash(
                            position: FlashPosition.top,
                            style: FlashStyle.floating,
                            text:
                                "Can not delete a ticket when it's less than 24h left");
                      } else if (ticketStatus == TicketStatus.owned_throwable) {
                        bool deleted = await httpService.deleteTicket(
                            ticket.event.id, memberId);
                        if (deleted) {
                          deleteTicket
                              .call(); //OBS Deletes the ticket from AnimatedList in TicketView via callBack function deleteTicket
                          _showCenterFlash(
                              position: FlashPosition.top,
                              style: FlashStyle.floating,
                              text: "Ticket deleted");
                        }
                      } else {
                        _showCenterFlash(
                            position: FlashPosition.top,
                            style: FlashStyle.floating,
                            text: "Error deleting the ticket");
                      }
                    }),
              ),
            ],
          );
        },
      );
    }

    return Padding(
      padding: EdgeInsets.only(
          left: fullWidth * 0.02,
          right: fullWidth * 0.02,
          bottom: fullHeight * 0.01),
      child: GestureDetector(
        onTap: (() => {
              setState(() {
                _isExpanded = !_isExpanded;

                if (_isExpanded) {
                  animatedHeight = fullHeight * 0.4;
                  middleWidget = Center(
                      child: Padding(
                          padding: EdgeInsets.all(height * 0.04),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(14),
                                    bottomRight: Radius.circular(14)),
                                border: Border.all(
                                    color: logoColor, width: 2)),
                            child: Image.asset("assets/tickets.png"),
                          )));
                } else {
                  animatedHeight = height * 0.16;
                  middleWidget = Divider(
                    color: logoColor,
                    thickness: 2,
                    indent: fullWidth * 0.06,
                    endIndent: fullWidth * 0.06,
                  );
                }
              })
            }),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          height: animatedHeight,
          width: fullWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: backgroundColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 10,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: fullWidth * 0.06,
                          bottom: fullHeight * 0.01,
                          top: fullHeight * 0.02),
                      child: Text(
                        ticket.event.title,
                        style: TextStyle(
                            color: textColor,
                            fontFamily: 'Ginto',
                            fontSize: 18),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: fullWidth * 0.06,
                          ),
                          child: AnimatedOpacity(
                              opacity: _isExpanded ? 1 : 0,
                              duration: Duration(milliseconds: 200),
                              child: GestureDetector(
                                  onTap: (() async {
                                    if (_isExpanded) {
                                      alert(context, "Delete ticket",
                                          "Are you sure you want to delete ticket?");
                                    } else {
                                      setState(() {
                                        _isExpanded = !_isExpanded;

                                        if (_isExpanded) {
                                          animatedHeight = fullHeight * 0.4;
                                          middleWidget = Center(
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.all(height * 0.04),
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft: Radius
                                                                .circular(14),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    14)),
                                                    border: Border.all(
                                                        color:
                                                            logoColor,
                                                        width: 2)),
                                              ),
                                            ),
                                          );
                                        } else {
                                          animatedHeight = height * 0.16;
                                          middleWidget = Divider(
                                            color: logoColor,
                                            thickness: 2,
                                            indent: fullWidth * 0.06,
                                            endIndent: fullWidth * 0.06,
                                          );
                                        }
                                      });
                                    }
                                  }),
                                  child: Icon(FeatherIcons.trash2,
                                      color: textColor, size: 20))),
                        )),
                  )
                ],
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  child: middleWidget,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(child: child, scale: animation);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: fullWidth * 0.06,
                    top: fullHeight * 0.01,
                    bottom: fullHeight * 0.02),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(
                        FeatherIcons.calendar,
                        color: ticket.event.date.isBefore(DateTime.now())
                            ? Colors.red
                            : textColor,
                        size: 18,
                      ),
                    ),
                    Flexible(
                        child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        DateFormat('MMMM dd yyyy').format(ticket.event.date) +
                            "     ",
                        style: TextStyle(
                            fontFamily: 'Ginto',
                            color: ticket.event.date.isBefore(DateTime.now())
                                ? Colors.red
                                : textColor,
                            fontSize: 12),
                      ),
                    )),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(
                        FeatherIcons.clock,
                        color: ticket.event.date.isBefore(DateTime.now())
                            ? Colors.red
                            : textColor,
                        size: 18,
                      ),
                    ),
                    Flexible(
                        child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        ticket.event.time,
                        style: TextStyle(
                            fontFamily: 'Ginto',
                            color: ticket.event.date.isBefore(DateTime.now())
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
    );
  }
}
