import 'package:toy_datalog/toy_datalog.dart';
import 'package:test/test.dart';

void main() {
  test('matchPattern positive', () {
    expect(
      matchPattern(
        ("?movieId", "movie/director", "?directorId"),
        (200, "movie/director", 100),
        {"?movieId": 200},
      ),
      {"?movieId": 200, "?directorId": 100},
    );
  });

  test('matchPattern() negative', () {
    expect(
      matchPattern(
        ("?movieId", "movie/director", "?directorId"),
        (200, "movie/director", 100),
        {"?movieId": 202},
      ),
      isNull,
    );
  });
}
