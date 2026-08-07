import 'dart:convert';
import 'package:enki/features/enki/domain/usecases/update_user.dart';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../models/course_model.dart';
import '../models/user_model.dart';

abstract interface class EnkiRemoteDataSource {
  Future<List<CourseModel>> getTopCourses();
  Future<List<CourseModel>> getBeginnerCourses();
  Future<List<CourseModel>> searchCourses({
    required String query,
    String? category,
  });
  Future<List<UserModel>> searchUsers({required String query});
  Future<UserModel> getOrCreateUser({required String userid});
  Future<List<CourseModel>> getUserWatchedCourses({required String userid});

  // ── progress ──────────────────────────────────────────────────
  Future<List<String>> getCourseProgress({
    required String userid,
    required String courseid,
  });
  Future<void> markLectureFinished({
    required String userid,
    required String courseid,
    required String moduleid,
    required String lectureid,
    required bool isFinished,
  });

  // ── user ──────────────────────────────────────────────────────
  Future<UserModel> updateUser({required UpdateUserParams params});
  Future<void> enrollUser({
    required String userid,
    required String courseid,
  });
  Future<String> uploadProfilePicture({
    required String userid,
    required List<int> imageBytes,
    required String filename,
  });
}

class EnkiRemoteDataSourceImpl implements EnkiRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  const EnkiRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  // ── private helpers ────────────────────────────────────────────
  Future<dynamic> _get(String path) async {
    final uri = Uri.parse('$baseUrl/api/v1$path');
    final response = await client.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw ServerException(
      'GET $path failed with status ${response.statusCode}',
    );
  }

  Future<dynamic> _post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl/api/v1$path');
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body != null ? jsonEncode(body) : null,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw ServerException(
      'POST $path failed with status ${response.statusCode}',
    );
  }

  Future<dynamic> _put(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/api/v1$path');
    final response = await client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw ServerException(
      'PUT $path failed with status ${response.statusCode}',
    );
  }

  // ── courses ────────────────────────────────────────────────────
  @override
  Future<List<CourseModel>> getTopCourses() async {
    final data = await _get('/courses/top') as List<dynamic>;
    return data
        .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CourseModel>> getBeginnerCourses() async {
    final data = await _get('/courses/beginner/top') as List<dynamic>;
    return data
        .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CourseModel>> searchCourses({
    required String query,
    String? category,
  }) async {
    final params = StringBuffer('?q=${Uri.encodeComponent(query)}');
    if (category != null && category.isNotEmpty) {
      params.write('&category=${Uri.encodeComponent(category)}');
    }
    final data = await _get('/courses/search$params') as List<dynamic>;
    return data
        .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── users ──────────────────────────────────────────────────────
  @override
  Future<List<UserModel>> searchUsers({required String query}) async {
    final data = await _get(
      '/users/search?q=${Uri.encodeComponent(query)}',
    ) as List<dynamic>;
    return data
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<UserModel> getOrCreateUser({required String userid}) async {
    final data = await _post('/users/$userid') as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  @override
  Future<List<CourseModel>> getUserWatchedCourses({
    required String userid,
  }) async {
    final data =
        await _get('/users/$userid/courses/watched') as List<dynamic>;
    return data
        .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<UserModel> updateUser({required UpdateUserParams params}) async {
    final data = await _put('/users/${params.userid}', {
      if (params.fullName != null) 'fullname': params.fullName,
      if (params.workAt != null) 'workat': params.workAt,
      if (params.age != null) 'age': params.age,
      if (params.description != null) 'userdescription': params.description,
      if (params.speciality != null) 'speciality': params.speciality,
      if (params.profilePicturePath != null)
        'profilepicturepath': params.profilePicturePath,
    }) as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  @override
  Future<void> enrollUser({
    required String userid,
    required String courseid,
  }) async {
    await _post('/users/$userid/enroll/$courseid');
  }

  @override
  Future<String> uploadProfilePicture({
    required String userid,
    required List<int> imageBytes,
    required String filename,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/upload/image');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: filename,
    ));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['filename'] as String;
    }
    throw ServerException('Image upload failed ${response.statusCode}');
  }

  // ── progress ───────────────────────────────────────────────────
  @override
  Future<List<String>> getCourseProgress({
    required String userid,
    required String courseid,
  }) async {
    final data = await _get('/progress/$userid/$courseid')
        as Map<String, dynamic>;
    return List<String>.from(
      data['finished_lecture_ids'] as List<dynamic>,
    );
  }

  @override
  Future<void> markLectureFinished({
    required String userid,
    required String courseid,
    required String moduleid,
    required String lectureid,
    required bool isFinished,
  }) async {
    await _post('/progress/mark', body: {
      'userid': userid,
      'courseid': courseid,
      'moduleid': moduleid,
      'lectureid': lectureid,
      'isfinished': isFinished,
    });
  }
}
