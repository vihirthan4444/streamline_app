import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:streamline_app/core/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

// Generate mocks
@GenerateMocks([http.Client])
import 'auth_service_test.mocks.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockClient mockClient;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      // Mock Secure Storage
      FlutterSecureStorage.setMockInitialValues({});

      mockClient = MockClient();
      authService = AuthService(client: mockClient);
    });

    test('Login returns token on 200 success', () async {
      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer(
        (_) async =>
            http.Response(jsonEncode({'access_token': 'fake_token'}), 200),
      );

      final token = await authService.login('test@example.com', 'password');
      expect(token, 'fake_token');
    });

    test('Login throws exception on 401 failure', () async {
      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(jsonEncode({'detail': 'Unauthorized'}), 401),
      );

      expect(
        () => authService.login('test@example.com', 'wrong_pass'),
        throwsException,
      );
    });

    test('Register returns token on 200 success', () async {
      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer(
        (_) async =>
            http.Response(jsonEncode({'access_token': 'new_token'}), 200),
      );

      final token = await authService.register('new@example.com', 'password');
      expect(token, 'new_token');
    });

    test('Register throws exception on 500 failure', () async {
      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response('Internal Server Error', 500));

      expect(
        () => authService.register('new@example.com', 'password'),
        throwsException,
      );
    });
  });
}
