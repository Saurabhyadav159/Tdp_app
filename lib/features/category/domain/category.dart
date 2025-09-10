class Category {
  final String id;
  final String name;
  final List<Poster> posters;

  Category({required this.id, required this.name, required this.posters});
}

class Poster {
  final String id;
  final String posterUrl;
  final SpecialDay? specialDay;
  final String? videoThumb;
  final bool isVideo;
  final String? date;
  final String? position;
  final int? topDefNum;
  final int? selfDefNum;
  final int? bottomDefNum;

  Poster({
    required this.id,
    required this.posterUrl,
    this.specialDay,
    this.videoThumb,
    required this.isVideo,
    this.date,
    this.position,
    this.topDefNum,
    this.selfDefNum,
    this.bottomDefNum,
  });

}

class SpecialDay {
  final String name;
  final String month;
  final String day;

  SpecialDay({required this.name, required this.month, required this.day});
}
