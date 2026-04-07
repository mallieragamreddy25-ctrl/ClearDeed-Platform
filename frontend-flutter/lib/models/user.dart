import 'package:json_serializable/json_serializable.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String mobileNumber;
  final String fullName;
  final String email;
  final String city;
  final String profileType; // buyer, seller, investor
  final bool isVerified;

  User({
    required this.id,
    required this.mobileNumber,
    required this.fullName,
    required this.email,
    required this.city,
    required this.profileType,
    required this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
