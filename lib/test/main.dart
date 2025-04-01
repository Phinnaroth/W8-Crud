import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = 'https://w8-restapi-default-rtdb.asia-southeast1.firebasedatabase.app';
  const String students = "students";
  const String allStudent = '$baseUrl/$students.json';
 
  // Uri uri = Uri.parse(allStudent);
  // final http.Response response = await http.get(uri);
  Future<void> getStudents() async {
    final Uri uri = Uri.parse(allStudent);
    final http.Response response = await http.get(uri);
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to load');
    }
  }
  Future<void> createStudent(String name, int age) async {
    final Uri uri = Uri.parse(allStudent);
    final http.Response response = await http.post(uri, body: json.encode({'name': name, 'age': age}));
    if (response.statusCode != HttpStatus.ok && response.statusCode != HttpStatus.created) {
      throw Exception('Failed to load');
    }
  }

  Future<void> deleteStudent(String id) async {
    final Uri uri = Uri.parse(allStudent);
    final http.Response responseDelete = await http.delete(uri);
    if (responseDelete.statusCode != HttpStatus.ok) {
      throw Exception('Failed to delete');
    }
  }

  await createStudent('Nezha', 3);
  // await deleteStudent('001');
  await getStudents();
  List<Student> result = [];
  print(result);
}

class StudentDto {
  static Student fromJson(String id, Map<String, dynamic> json) {
    return Student(id: id, age: json['age'], name: json['name']);
  }
}

class Student {
  final String id;
  final int age;
  final String name;

  Student({required this.id, required this.age, required this.name});

  String toString() {
    return 'Student{id: $id, age: $age, name: $name}';
  }
}