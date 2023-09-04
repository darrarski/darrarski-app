/// Returns a function from `A` to `A`, given a function that takes in-out `A` and returns nothing.
///
/// Use to convert function `(inout A) -> Void` into `(A) -> A`.
///
/// Can be used with `.map` operator for convenient value mutations:
///
/// ```swift
/// [1, 2, 3].map(makeUpdate {
///   $0 *= 2
/// }) // => [2, 4, 6]
/// ```
///
/// ```swift
/// users.map(makeUpdate {
///   $0.updatedAt = Date()
/// }) // => updated users
/// ```
///
/// - Parameter modify: Function `(inout A) -> Void`
/// - Returns: Function `(A) -> A`
public func makeUpdate<A>(_ modify: @escaping (inout A) -> Void) -> (A) -> A {
  {
    var a = $0
    modify(&a)
    return a
  }
}
