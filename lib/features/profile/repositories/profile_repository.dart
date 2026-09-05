import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/dio_exception_mapper.dart';
import '../../auth/models/user_model.dart';
import '../data/user_api.dart';

class ProfileRepository {
  ProfileRepository(this._api);

  final UserApi _api;

  Future<UserModel> getMe() async {
    try {
      final data = await _api.getMe();
      return UserModel.fromJson(data["user"] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<UserModel> updateMe(Map<String, dynamic> updates) async {
    try {
      final data = await _api.updateMe(updates);
      return UserModel.fromJson(data["user"] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<UserModel> uploadProfileImage({required List<int> bytes, required String filename}) async {
    try {
      final data = await _api.uploadProfileImage(bytes: bytes, filename: filename);
      return UserModel.fromJson(data["user"] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<UserModel> uploadResume({required List<int> bytes, required String filename}) async {
    try {
      final data = await _api.uploadResume(bytes: bytes, filename: filename);
      return UserModel.fromJson(data["user"] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<UserModel> uploadCompanyLogo({required List<int> bytes, required String filename}) async {
    try {
      final data = await _api.uploadCompanyLogo(bytes: bytes, filename: filename);
      return UserModel.fromJson(data["user"] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(UserApi(ref.watch(dioClientProvider)));
});
