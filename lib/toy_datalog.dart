import 'package:collection/collection.dart';

typedef Query = ({List<String> find, List<Triple> where});
typedef Triple = (Object, String, Object);
typedef Context = Map<String, Object>;
typedef DbIndex = Map<Object, List<Triple>>;
typedef Database = (
  List<Triple>, {
  DbIndex entityIndex,
  DbIndex attrIndex,
  DbIndex valueIndex
});

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

List<Context> querySingle(Triple pattern, List<Triple> triples, Context ctx) {
  return triples
      .map((t) => matchPattern(pattern, t, ctx))
      .whereNotNull()
      .toList();
}

List<Context> querySingleIndexed(Triple pattern, Database db, Context ctx) {
  return relevantTriples(pattern, db)
      .map((t) => matchPattern(pattern, t, ctx))
      .whereNotNull()
      .toList();
}

List<Triple> relevantTriples(Triple pattern, Database db) {
  final (id, attr, val) = pattern;
  if (id is! String || !isVariable(id)) {
    return db.entityIndex[id]!;
  }
  if (!isVariable(attr)) {
    return db.attrIndex[attr]!;
  }
  if (val is! String || !isVariable(val)) {
    return db.valueIndex[val]!;
  }
  return db.$1;
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

Database createDb(List<Triple> triples) {
  return (
    triples,
    entityIndex: indexBy(triples, (t) => t.$1),
    attrIndex: indexBy(triples, (t) => t.$2),
    valueIndex: indexBy(triples, (t) => t.$3),
  );
}

DbIndex indexBy(List<Triple> triples, Object Function(Triple) tripleAttr) {
  return triples.fold({}, (DbIndex index, Triple triple) {
    // For the given attribute value of the triple, add the whole tuple to
    // the list of triples with the same attribute.
    final k = tripleAttr(triple);
    index[k] = index[k] ?? [];
    index[k]!.add(triple);
    return index;
  });
}
