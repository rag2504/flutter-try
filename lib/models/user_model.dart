class User {
  int? id;
  String name;
  String email;
  String mobile;
  int age;
  String city;
  String gender;
  bool isFavorite;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.age,
    required this.city,
    required this.gender,
    this.isFavorite = false,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      mobile: map['mobile'],
      age: map['age'],
      city: map['city'],
      gender: map['gender'],
      isFavorite: (map['isFavorite'] ?? 0) == 1, // Ensures null safety
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'age': age,
      'city': city,
      'gender': gender,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }
}