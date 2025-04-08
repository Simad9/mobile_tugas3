class EduWebModel {
  String name;
  String developer;
  String category;
  List<String> topics;
  double rating;
  String description;
  String logoUrl;
  String siteUrl;
  bool isFavorite = false;

  EduWebModel({
    required this.name,
    required this.developer,
    required this.category,
    required this.topics,
    required this.rating,
    required this.description,
    required this.logoUrl,
    required this.siteUrl,
  });
}
