class ReturnException extends Error {
  final Object? value;
  ReturnException(this.value);
}
