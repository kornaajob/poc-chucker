import 'package:flutter/foundation.dart';
import '../model/user.dart';
import '../service/api_service.dart';

class UserViewModel extends ChangeNotifier {
  final ApiService _apiService;
  List<User> _users = [];
  bool _isLoading = false;
  String _error = '';

  UserViewModel(this._apiService);

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _users = await _apiService.getUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
