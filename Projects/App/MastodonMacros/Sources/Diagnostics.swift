struct MacroError: Error, CustomStringConvertible {
  init(_ message: String) {
    self.message = message
  }

  var message: String
  var description: String { message }
}
