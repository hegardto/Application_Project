import 'package:flutter/foundation.dart';

class Event implements Comparable<Event> {
  final String title;
  final String location;
  final String introduction;
  final DateTime date;
  final String time;
  final String id;
  final String image;
  final String introductionTitle;
  final String description;
  final String importantNote;

  Event({
    @required this.introduction,
    @required this.title,
    @required this.location,
    @required this.id,
    @required this.date,
    @required this.time,
    @required this.introductionTitle,
    @required this.description,
    @required this.importantNote,
    this.image,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
        title: json['title'] as String,
        location: json['location'] as String,
        introduction: json['introduction'] as String,
        date: DateTime.parse(json['date'] as String),
        time: json['time'] as String,
        id: json['_id'] as String,
        image: json['image'] as String,
        introductionTitle: json['introductionTitle'] as String,
        description: json['description'] as String,
        importantNote: json['importantNote'] as String);
  }

  @override
  int compareTo(Event other) {
    DateTime now = DateTime.now();
    bool thisIsPassed = this.date.isBefore(now);
    bool otherIsPassed = other.date.isBefore(now);

    if (thisIsPassed && !otherIsPassed) {
      return 1;
    } else if (!thisIsPassed && otherIsPassed) {
      return -1;
    } else if (thisIsPassed && otherIsPassed) {
      return other.date.compareTo(this.date);
    }
    return this.date.compareTo(other.date);
  }
}
