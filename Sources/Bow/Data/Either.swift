import Foundation

/**
 Witness for the `Either<A, B>` data type. To be used in simulated Higher Kinded Types.
 */
public final class ForEither {}

/**
 Parial application of the Either type constructor, omitting the last parameter.

 The following statements are equivalent:

 ```swift
 EitherOf<A, B> == Kind2<ForEither, A, B> == Kind<EitherPartial<A>, B>
 ```
 */
public final class EitherPartial<L>: Kind<ForEither, L> {}

/**
 Higher Kinded Type alias to improve readability over `Kind2<ForEither, A, B>`
 */
public typealias EitherOf<A, B> = Kind<EitherPartial<A>, B>

/**
 Sum type of types `A` and `B`. Represents a value of either one of those types, but not both at the same time. Values of type `A` are called `left`; values of type `B` are called right.
 */
public class Either<A, B> : EitherOf<A, B> {
    /**
     Constructs a left value given an instance of `A`.
     */
    public static func left(_ a : A) -> Either<A, B> {
        return Left<A, B>(a)
    }
    
    /**
     Constructs a right value given an instance of `B`.
     */
    public static func right(_ b : B) -> Either<A, B> {
        return Right<A, B>(b)
    }

    /**
     Safe downcast to `Either<A, B>`.
     */
    public static func fix(_ fa : EitherOf<A, B>) -> Either<A, B> {
        return fa as! Either<A, B>
    }
    
    /**
     Applies the provided closures based on the content of this `Either` value.
     
     - parameter fa: Closure to apply if the contained value in this `Either` is of type `A`.
     - parameter fb: Closure to apply if the contained value in this `Either` is of type `B`.
     - returns: Result of applying the corresponding closure to this value.
     */
    public func fold<C>(_ fa : (A) -> C, _ fb : (B) -> C) -> C {
        switch self {
            case let left as Left<A, B>:
                return fa(left.a)
            case let right as Right<A, B>:
                return fb(right.b)
            default:
                fatalError("Either must only have left and right cases")
        }
    }
    
    /**
     Checks if this value belongs to the left type.
     */
    public var isLeft : Bool {
        return fold(constant(true), constant(false))
    }
    
    /**
     Checks if this value belongs to the right type.
     */
    public var isRight : Bool {
        return !isLeft
    }
    
    /**
     Attempts to obtain a value of the left type.
     
     This propery is unsafe and can cause fatal errors if it is invoked on a right value.
     */
    public var leftValue : A {
        return fold(id, { _ in fatalError("Attempted to obtain leftValue on a right instance") })
    }
    
    /**
     Attempts to obtain a value of the right type.
     
     This property is unsafe and can cause fatal errors if it is invoked on a left value.
     */
    public var rightValue : B {
        return fold({ _ in fatalError("Attempted to obtain rightValue on a left instance") }, id)
    }
    
    /**
     Reverses the types of this either. Left values become right values and vice versa.
     */
    public func swap() -> Either<B, A> {
        return fold(Either<B, A>.right, Either<B, A>.left)
    }
    
    /**
     Transforms both type parameters, preserving its structure.
     
     - parameter fa: Closure to be applied when there is a left value.
     - parameter fb: Closure to be applied when there is a right value.
     */
    public func bimap<C, D>(_ fa : (A) -> C, _ fb : (B) -> D) -> Either<C, D> {
        return fold({ a in Either<C, D>.left(fa(a)) },
                    { b in Either<C, D>.right(fb(b)) })
    }

    /**
     Converts this `Either` to an `Option`.
     
     This conversion is lossy. Left values are mapped to `Option.none()` and right values to `Option.some()`. The original `Either cannot be reconstructed from the output of this conversion.
     */
    public func toOption() -> Option<B> {
        return fold(constant(Option<B>.none()), Option<B>.some)
    }
    
    /**
     Obtains the value wrapped if it is a right value, or the default value provided as an argument.
     */
    public func getOrElse(_ defaultValue : B) -> B {
        return fold(constant(defaultValue), id)
    }
    
    /**
     Filters the right values, providing a default left value if the do not match the provided predicate.
     */
    public func filterOrElse(_ predicate : @escaping (B) -> Bool, _ defaultValue : A) -> Either<A, B> {
        return fold(Either<A, B>.left,
                    { b in predicate(b) ?
                        Either<A, B>.right(b) :
                        Either<A, B>.left(defaultValue) })
    }
}

class Left<A, B> : Either<A, B> {
    let a : A
    
    init(_ a : A) {
        self.a = a
    }
}

class Right<A, B> : Either<A, B> {
    let b : B
    
    init(_ b : B) {
        self.b = b
    }
}

// MARK: Protocol conformances

/// Conformance of `Either` to `CustomStringConvertible`
extension Either: CustomStringConvertible {
    public var description: String {
        return fold({ a in "Left(\(a))"},
                    { b in "Right(\(b))"})
    }
}

/// Conformance of `Either` to `CustomDebugStringConvertible`, provided that both of its type arguments conform to `CustomDebugStringConvertible`.
extension Either: CustomDebugStringConvertible where A: CustomDebugStringConvertible, B: CustomDebugStringConvertible {
    public var debugDescription: String {
        return fold({ a in "Left(\(a.debugDescription)"},
                    { b in "Right(\(b.debugDescription))"})
    }
}

extension EitherPartial: EquatableK where L: Equatable {
    public static func eq<A>(_ lhs: Kind<EitherPartial<L>, A>, _ rhs: Kind<EitherPartial<L>, A>) -> Bool where A : Equatable {
        let el = Either.fix(lhs)
        let er = Either.fix(rhs)
        return el.fold({ la in er.fold({ lb in la == lb }, constant(false)) },
                       { ra in er.fold(constant(false), { rb in ra == rb })})
    }
}

extension EitherPartial: Functor {
    public static func map<A, B>(_ fa: Kind<EitherPartial<L>, A>, _ f: @escaping (A) -> B) -> Kind<EitherPartial<L>, B> {
        return Either.fix(fa).fold(Either.left, Either.right <<< f)
    }
}

extension EitherPartial: Applicative {
    public static func pure<A>(_ a: A) -> Kind<EitherPartial<L>, A> {
        return Either.right(a)
    }
}

extension EitherPartial: Monad {
    public static func flatMap<A, B>(_ fa: Kind<EitherPartial<L>, A>, _ f: @escaping (A) -> Kind<EitherPartial<L>, B>) -> Kind<EitherPartial<L>, B> {
        return Either.fix(fa).fold(Either.left, f)
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<EitherPartial<L>, Either<A, B>>) -> Kind<EitherPartial<L>, B> {
        return Either.fix(f(a)).fold(Either<L, B>.left,
                  { either in
                    either.fold({ left in tailRecM(left, f)},
                                Either<L, B>.right)
        })
    }
}

extension EitherPartial: ApplicativeError {
    public typealias E = L

    public static func raiseError<A>(_ e: L) -> Kind<EitherPartial<L>, A> {
        return Either.left(e)
    }

    public static func handleErrorWith<A>(_ fa: Kind<EitherPartial<L>, A>, _ f: @escaping (L) -> Kind<EitherPartial<L>, A>) -> Kind<EitherPartial<L>, A> {
        return Either.fix(fa).fold(f, constant(Either.fix(fa)))
    }
}

extension EitherPartial: MonadError {}

extension EitherPartial: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<EitherPartial<L>, A>, _ c: B, _ f: @escaping (B, A) -> B) -> B {
        return Either.fix(fa).fold(constant(c), { b in f(c, b) })
    }

    public static func foldRight<A, B>(_ fa: Kind<EitherPartial<L>, A>, _ c: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return Either.fix(fa).fold(constant(c), { b in f(b, c) })
    }
}

extension EitherPartial: Traverse {
    public static func traverse<G: Applicative, A, B>(_ fa: Kind<EitherPartial<L>, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<EitherPartial<L>, B>> {
        return Either.fix(fa).fold({ a in G.pure(Either.left(a)) },
                                   { b in G.map(f(b), { c in Either.right(c) }) })
    }
}

extension EitherPartial: SemigroupK {
    public static func combineK<A>(_ x: Kind<EitherPartial<L>, A>, _ y: Kind<EitherPartial<L>, A>) -> Kind<EitherPartial<L>, A> {
        return Either.fix(x).fold(constant(Either.fix(y)), Either.right)
    }
}
