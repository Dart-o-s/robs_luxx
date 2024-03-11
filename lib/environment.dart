class Environment {
  final Map<String, Object?> vars = {};

  void declare(String key, Object? value) {
    vars[key] = value;
  }

  Object? lookup(String key) {
    if (vars.containsKey(key)) {
      return vars[key];
    }

    throw Exception('Var does not exists');
  }
}
