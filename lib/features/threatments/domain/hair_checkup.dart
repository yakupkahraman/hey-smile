class HairCheckup {
  final String id;
  final String date;
  final String userNotes;
  final String? doctorComment;
  final int graft;
  final String imageFrontUrl;
  final String imageBackUrl;
  final String imageLeftUrl;
  final String imageRightUrl;
  final String imageTopUrl;

  HairCheckup({
    required this.id,
    required this.date,
    required this.userNotes,
    this.doctorComment,
    required this.graft,
    required this.imageFrontUrl,
    required this.imageBackUrl,
    required this.imageLeftUrl,
    required this.imageRightUrl,
    required this.imageTopUrl,
  });

  factory HairCheckup.fromJson(Map<String, dynamic> json) {
    return HairCheckup(
      id: json['id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      userNotes: json['userNotes']?.toString() ?? '',
      doctorComment: json['doctorComment']?.toString(),
      graft: json['graft'] is int ? json['graft'] as int : 0,
      imageFrontUrl: json['imageFrontUrl']?.toString() ?? '',
      imageBackUrl: json['imageBackUrl']?.toString() ?? '',
      imageLeftUrl: json['imageLeftUrl']?.toString() ?? '',
      imageRightUrl: json['imageRightUrl']?.toString() ?? '',
      imageTopUrl: json['imageTopUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'userNotes': userNotes,
      'doctorComment': doctorComment,
      'graft': graft,
      'imageFrontUrl': imageFrontUrl,
      'imageBackUrl': imageBackUrl,
      'imageLeftUrl': imageLeftUrl,
      'imageRightUrl': imageRightUrl,
      'imageTopUrl': imageTopUrl,
    };
  }
}
