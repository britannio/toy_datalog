import 'package:collection/collection.dart';

typedef Query = ({List<String> find, List<Triple> where});
typedef Triple = (dynamic, String, dynamic);
typedef Context = Map<String, dynamic>;

void demo() {
  final Query query = (
    find: [],
    where: [],
  );
}

Context? matchPattern(Triple pattern, Triple triple, Context context) {
  final $pattern = [pattern.$1, pattern.$2, pattern.$3];
  // Starting with the original context, compare index 1-3 of the pattern vs
  // triple and build up the context. If there is a failed match then the
  // context becomes empty.
  return $pattern.foldIndexed(context, (index, context, patternPart) {
    final $triple = [triple.$1, triple.$2, triple.$3][index];
    return matchPart(patternPart, $triple, context);
  });
}

bool isVariable(String x) => x.startsWith('?');

Context? matchPart(Object patternPart, Object triplePart, Context? context) {
  if (context == null) return null;
  if (patternPart is String && isVariable(patternPart)) {
    return matchVariable(patternPart, triplePart, context);
  } else {
    // patternPart is a constant
    return patternPart == triplePart ? context : null;
  }
}

Context? matchVariable(String variable, Object triplePart, Context context) {
  if (context.containsKey(variable)) {
    // The variable has a value in the context
    final bound = context[variable];
    // Populate context by now searching with this added restriction
    return matchPart(bound, triplePart, context);
  } else {
    return context..[variable] = triplePart;
  }
}
