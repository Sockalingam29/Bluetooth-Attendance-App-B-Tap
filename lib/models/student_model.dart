class StudentModel {
  final String? id;
  final String name;
  final String email;
  final String phoneNo;
  final String password;

  const StudentModel({
    this.id,
    required this.email,
    required this.name,
    required this.phoneNo,
    required this.password,
  });

  toJson() {
    return {
      "Name": name,
      "Email": email,
      "Phone Number": phoneNo,
      "Password": password,
    };
  }
}
