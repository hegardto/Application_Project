import 'package:flutter/foundation.dart';

class Sponsor {
  final String sponsor;
  final String logo;

  Sponsor({
    @required this.sponsor,
    @required this.logo,
  });

  factory Sponsor.fromJson(Map<String, dynamic> json) {
    return Sponsor(
      sponsor: json['title'] as String,
      logo: json['logo'] as String,
    );
  }
}
