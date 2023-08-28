# A Datalog inspired toy database

Source: `lib/toy_datalog.dart`
Examples: `test/toy_datalog_test.dart`
Reference Guide: https://www.instantdb.com/essays/datalogjs


Example usage:

```dart
final result = query(
      (
        find: ["?directorName"],
        where: [
          // Pattern matching
          ("?movieId", "movie/title", "The Terminator"),
          ("?movieId", "movie/director", "?directorId"),
          ("?directorId", "person/name", "?directorName"),
        ],
      ),
      exampleTriples,
    );
print(result); // [["James Cameron"]]
```
