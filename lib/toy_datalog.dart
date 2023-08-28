import 'package:collection/collection.dart';

typedef Query = ({List<String> find, List<Triple> where});
typedef Triple = (Object, String, Object);
typedef Context = Map<String, Object>;

extension TripleX on Triple {
  Object operator [](int index) => values[index];

  List<Object> get values => [$1, $2, $3];
}

Context? matchPattern(Triple pattern, Triple triple, Context ctx) {
  // Starting with the original context, compare index 1-3 of the pattern vs
  // triple and build up the context. If there is a failed match then the
  // context becomes empty.

  return pattern.values.foldIndexed(ctx, (index, context, patternPart) {
    return matchPart(patternPart, triple[index], context);
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
    final bound = context[variable]!;
    // Populate context by now searching with this added restriction
    return matchPart(bound, triplePart, context);
  } else {
    return {...context, variable: triplePart};
  }
}

List<Context> querySingle(Triple pattern, List<Triple> db, Context ctx) {
  return db.map((t) => matchPattern(pattern, t, ctx)).whereNotNull().toList();
}

List<Context> queryWhere(List<Triple> patterns, List<Triple> db) {
  return patterns.fold([{}], (contexts, pattern) {
    return contexts
        .map((ctx) => querySingle(pattern, db, ctx))
        .flattened
        .toList();
  });
}

List<Object> query(Query query, List<Triple> db) {
  final List<Context> contexts = queryWhere(query.where, db);
  return contexts.map((ctx) => actualize(ctx, query.find)).toList();
}

List<Object> actualize(Context ctx, List<String> find) {
  // find may contain constants, otherwise the variable is looked up.
  // Can the variable lookup fail?
  return find
      .map((findPart) => isVariable(findPart) ? ctx[findPart]! : findPart)
      .toList();
}
