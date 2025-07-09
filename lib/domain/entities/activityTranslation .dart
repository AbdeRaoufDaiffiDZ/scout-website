class ActivityTranslation {
  final String title;
  final String description;

  ActivityTranslation({required this.title, required this.description});

  factory ActivityTranslation.fromJson(Map<String, dynamic> json) {
    return ActivityTranslation(
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description};
  }
}
