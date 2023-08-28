import 'package:toy_datalog/example_triples.dart';
import 'package:toy_datalog/toy_datalog.dart';
import 'package:test/test.dart';

void main() {
  test('matchPattern() positive', () {
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

  test('querySingle()', () {
    expect(
      querySingle(("?movieId", "movie/year", 1987), exampleTriples, {}),
      [
        {"?movieId": 202},
        {"?movieId": 203},
        {"?movieId": 204}
      ],
    );
  });

  test('queryWhere()', () {
    expect(
      queryWhere(
        [
          ("?movieId", "movie/title", "The Terminator"),
          ("?movieId", "movie/director", "?directorId"),
          ("?directorId", "person/name", "?directorName"),
        ],
        exampleTriples,
      ),
      [
        {"?movieId": 200, "?directorId": 100, "?directorName": "James Cameron"},
      ],
    );
  });

  test('where & find', () {
    expect(
        query(
          (
            find: ["?directorName"],
            where: [
              ("?movieId", "movie/title", "The Terminator"),
              ("?movieId", "movie/director", "?directorId"),
              ("?directorId", "person/name", "?directorName"),
            ],
          ),
          exampleTriples,
        ),
        [
          ["James Cameron"]
        ]);
  });
}
