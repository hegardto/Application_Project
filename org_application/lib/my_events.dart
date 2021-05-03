import 'color.dart';
import 'http_service.dart';
import 'event_model.dart';
import 'event_card.dart';
import 'ticket_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

LightThemeColors colors = LightThemeColors();
Color backgroundColor = colors.getBackgroundColor();
Color textColor = colors.getTextColor();
Color logoColor = colors.getLogoColor();

class MyEventsView extends StatefulWidget {
  Key key;
  String memberId;
  MyEventsView({@required this.memberId, @required this.key});

  @override
  MyEventsViewState createState() => MyEventsViewState(memberId: memberId);
}

class MyEventsViewState extends State<MyEventsView> {
  final GlobalKey<AnimatedListState> _key = GlobalKey<AnimatedListState>();
  HttpService httpService = HttpService();
  String memberId;
  List<Ticket> tickets;
  List<Event> events = [];

  MyEventsViewState({@required this.memberId});

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

    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      left: false,
      right: false,
      child: FutureBuilder(
          future: httpService.getTickets(memberId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: height * 0.02),
                          child: Icon(
                            AntDesign.frowno,
                            size: 32,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'You have no tickets, check out events!',
                          style:
                              TextStyle(color: textColor, fontFamily: 'Ginto'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              tickets = snapshot.data as List<Ticket>;
              for (Ticket ticket in tickets) {
                events.add(ticket.event);
              }
              events.sort((a, b) => a.compareTo(b));

              return Column(children: <Widget>[
                Expanded(
                    child: RefreshIndicator(
                  color: logoColor,
                  backgroundColor: backgroundColor,
                  child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: events.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.02,
                                bottom:
                                    MediaQuery.of(context).size.height * 0.02),
                            child: Text(
                              "My events",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: 'Ginto',
                                  color: textColor),
                            ),
                          );
                        }
                        index -= 1;

                        return EventCard(
                          memberId: memberId,
                          event: events[index],
                          key: UniqueKey(),
                        );
                      }),
                  onRefresh: () async {
                    events = [];
                    tickets = await httpService.getTickets(memberId);
                    for (Ticket ticket in tickets) {
                      events.add(ticket.event);
                    }
                    events.sort((a, b) => a.compareTo(b));
                    if (this.mounted) {
                      setState(() {});
                    }
                    return null;
                  },
                ))
              ]);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Center(
                child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(logoColor)));
          }),
    );
  }
}
