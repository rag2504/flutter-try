class User {
  int? id;
  String name;
  String email;
  String mobile;
  int age;
  String city;
  String gender;
  String password; // Added password field
  bool isFavorite;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.age,
    required this.city,
    required this.gender,
    required this.password, // Ensure password is required
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'age': age,
      'city': city,
      'gender': gender,
      'password': password, // Ensure password is saved
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      mobile: map['mobile'],
      age: map['age'],
      city: map['city'],
      gender: map['gender'],
      password: map['password'], // Retrieve password
      isFavorite: map['isFavorite'] == 1,
    );
  }
}
