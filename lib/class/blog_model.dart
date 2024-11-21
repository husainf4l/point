class Blog {
  final String title;
  final String description;
  final String image;
  final List<BlogSection> sections;

  Blog({
    required this.title,
    required this.description,
    required this.sections,
    required this.image,
  });
}

class BlogSection {
  final String heading;
  final String content;
  final List<String>? bulletPoints;

  BlogSection({
    required this.heading,
    required this.content,
    this.bulletPoints,
  });
}
