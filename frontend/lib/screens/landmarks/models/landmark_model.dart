// ─── Landmark models ──────────────────────────────────────────────────────────

/// Lightweight model returned by [LandmarkApi.getChecklist].
///
/// Only contains fields safe to show before a student visits the landmark.
/// Use [LandmarkDetail] once the QR code has been scanned.
class LandmarkSummary {
  final int landmarkId;
  final String name;
  final String? imgPath;
  final bool isVisited;

  const LandmarkSummary({
    required this.landmarkId,
    required this.name,
    required this.isVisited,
    this.imgPath,
  });

  factory LandmarkSummary.fromJson(Map<String, dynamic> json) {
    return LandmarkSummary(
      landmarkId: json['landmark_id'] as int,
      name: json['name'] as String,
      imgPath: json['img_path'] as String?,
      isVisited: json['is_visited'] as bool,
    );
  }
}

// ─── Landmark detail ──────────────────────────────────────────────────────────

/// Full model returned by [LandmarkApi.getLandmark].
///
/// Only accessible after the student has scanned the landmark's QR code.
/// The API will throw if the landmark has not been visited yet.
class LandmarkDetail {
  final int landmarkId;
  final String name;
  final String? imgPath;
  final String description;
  final String funFact;

  const LandmarkDetail({
    required this.landmarkId,
    required this.name,
    required this.description,
    required this.funFact,
    this.imgPath,
  });

  factory LandmarkDetail.fromJson(Map<String, dynamic> json) {
    return LandmarkDetail(
      landmarkId: json['landmark_id'] as int,
      name: json['name'] as String,
      imgPath: json['img_path'] as String?,
      description: json['description'] as String,
      funFact: json['fun_fact'] as String,
    );
  }
}
