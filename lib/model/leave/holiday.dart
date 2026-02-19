
// class Holiday {
//   final String name;
//   final String date;
//   final RxBool isClick;
//
//   Holiday({required this.name, required this.date, required bool initialIsClick})
//       : isClick = RxBool(initialIsClick);
//
//   factory Holiday.fromJson(Map<String, dynamic> json) {
//     return Holiday(
//       name: json['name'],
//       date: json['date']['iso'],
//       initialIsClick: false,
//     );
//   }
// }
class Holiday {
  final String name;
  final String date;
  bool isClick;

  Holiday({required this.name, required this.date, required this.isClick});

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      name: json['reason'],
      date: json['date'],
      isClick: false,
    );
  }
}

class Holidays {
  final String name;
  final String date;
  bool isClick;

  Holidays({required this.name, required this.date, this.isClick = false});

  // Updated fromJson to handle both iso and datetime fields
  factory Holidays.fromJson(Map<String, dynamic> json) {
    // Assuming 'iso' is what you want to store as the date
    String holidayDate = json['date']['iso'];  // Accessing iso field

    return Holidays(
      name: json['name'], // Name of the holiday from API
      date: holidayDate,  // Store iso date here
      isClick: false,     // Initial click state is false
    );
  }
}
