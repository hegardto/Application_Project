import 'package:flutter/foundation.dart';

class AboutPage {
  final String about;

  AboutPage({
    @required this.about,
  });

  factory AboutPage.fromJson(Map<String, dynamic> json) {
    return AboutPage(about: json['title'] as String);
  }
}
