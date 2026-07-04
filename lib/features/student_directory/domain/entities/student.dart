class Student {
  final String name;
  final String username;
  final String bio;
  final List<String> tags;
  final String avatarUrl;
  final bool isVerified;

  const Student({
    required this.name,
    required this.username,
    required this.bio,
    required this.tags,
    required this.avatarUrl,
    this.isVerified = true,
  });
}
