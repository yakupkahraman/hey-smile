class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final DateTime dateOfBirth;
  final String? profilePhotoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.dateOfBirth,
    this.profilePhotoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON'dan User objesi oluştur
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      dateOfBirth: _parseDate(json['dateOfBirth']),
      profilePhotoUrl:
          json['profileImageUrl']?.toString() ??
          json['profilePhotoUrl']?.toString(),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  // Tarih parsing helper metodu
  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    try {
      if (dateValue is String) {
        // "2005-01-28" formatı için
        if (dateValue.length == 10 && !dateValue.contains('T')) {
          return DateTime.parse('${dateValue}T00:00:00');
        }
        return DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        return dateValue;
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  // User objesini JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'profilePhotoUrl': profilePhotoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Full name getter
  String get fullName => '$firstName $lastName';

  // Copy with method - User nesnesinin bir kopyasını oluştur
  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? profilePhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
