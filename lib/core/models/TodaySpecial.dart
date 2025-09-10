// Create a new file: models/today_special.dart
class TodaySpecial {
  final String id;
  final String masterAppId;
  final String categoryId;
  final String? specialDayId;
  final int? topDefNum;
  final int? selfDefNum;
  final int? bottomDefNum;
  final String poster;
  final String? videoThumb;
  final String date;
  final String status;
  final int downloadCount;
  final String position;
  final String createdAt;

  TodaySpecial({
    required this.id,
    required this.masterAppId,
    required this.categoryId,
    this.specialDayId,
    this.topDefNum,
    this.selfDefNum,
    this.bottomDefNum,
    required this.poster,
    this.videoThumb,
    required this.date,
    required this.status,
    required this.downloadCount,
    required this.position,
    required this.createdAt,
  });

  factory TodaySpecial.fromJson(Map<String, dynamic> json) {
    return TodaySpecial(
      id: json['id'] ?? '',
      masterAppId: json['masterAppId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      specialDayId: json['specialDayId'],
      topDefNum: json['topDefNum'],
      selfDefNum: json['selfDefNum'],
      bottomDefNum: json['bottomDefNum'],
      poster: json['poster'] ?? '',
      videoThumb: json['videoThumb'],
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      downloadCount: json['downloadCount'] ?? 0,
      position: json['position'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}