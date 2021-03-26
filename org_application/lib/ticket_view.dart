import 'color.dart';
import 'http_service.dart';
import 'ticket_card.dart';
import 'ticket_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

LightThemeColors colors = LightThemeColors();
Color backgroundColor = colors.getBackgroundColor();
Color textColor = colors.getTextColor();
Color logoColor = colors.getLogoColor();

class TicketView extends StatefulWidget {
  Key key;
  String memberId;
  TicketView({@required this.memberId, @required this.key});

  @override
  TicketViewState createState() => TicketViewState(memberId: memberId);
}

class TicketViewState extends State<TicketView> {
  final GlobalKey<AnimatedListState> _key = GlobalKey<AnimatedListState>();
  HttpService httpService = HttpService();
  String memberId;
  List<Ticket> tickets;

  TicketViewState({@required this.memberId});

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
    return SafeArea(
      left: false,
      right: false,
      child: Container(
        color: backgroundColor,
        child: Column(children: <Widget>[
          Flexible(
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
                                  padding:
                                      EdgeInsets.only(bottom: height * 0.02),
                                  child: Icon(
                                    AntDesign.frowno,
                                    size: 32,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  'You have no tickets, check out events!',
                                  style: TextStyle(
                                      color: textColor,
                                      fontFamily: 'Ginto'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      tickets = snapshot.data as List<Ticket>;
                      tickets.sort((a, b) => a.compareTo(b));
                      return AnimatedList(
                          key: _key,
                          initialItemCount: tickets.length + 1,
                          itemBuilder: (context, index, animation) {
                            if (index == 0) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    top: height * 0.02, bottom: height * 0.02),
                                child: Text(
                                  "Tickets",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontFamily: 'Ginto',
                                      color: textColor),
                                ),
                              );
                            }
                            index -= 1;

                            return buildItem(tickets[index], animation, index);
                          });
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return Center(
                        child: CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                logoColor)));
                  })),
        ]),
      ),
    );
  }

  Widget buildItem(Ticket ticket, Animation<double> animation, int index) {
    return SizeTransition(
      key: UniqueKey(),
      sizeFactor: animation,
      child: TicketCard(
        memberId: memberId,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        ticket: ticket,
        deleteTicket: () {
          setState(() {
            removeItem(index);
          });
        },
      ),
    );
  }

  void removeItem(int index) {
    Ticket removedItem = tickets.removeAt(index);
    AnimatedListRemovedItemBuilder builder = (context, animation) {
      return buildItem(removedItem, animation, index);
    };
    _key.currentState.removeItem(index, builder);
  }
}
