import XCTest
import Nimble
@testable import BowLaws
import Bow

class EitherTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<EitherPartial<Int>, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<EitherPartial<Int>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<EitherPartial<Int>>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<EitherPartial<Int>>.check()
    }

    func testMonadLaws() {
        MonadLaws<EitherPartial<Int>>.check()
    }

    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<EitherPartial<CategoryError>>.check()
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<EitherPartial<CategoryError>>.check()
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<EitherPartial<Int>>.check()
    }

    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws<Either<Int, Int>>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<EitherPartial<Int>>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<EitherPartial<Int>>.check()
    }
    
    func testSemigroupLaws() {
        SemigroupLaws<Either<Int, Int>>.check()
    }
    
    func testMonoidLaws() {
        MonoidLaws<Either<Int, Int>>.check()
    }
    
    func testCheckers() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        
        expect(left.isLeft).to(beTrue())
        expect(left.isRight).to(beFalse())
        expect(right.isLeft).to(beFalse())
        expect(right.isRight).to(beTrue())
    }
    
    func testSwap() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        
        expect(left.swap()).to(equal(Either<Int, String>.right("Hello")))
        expect(right.swap()).to(equal(Either<Int, String>.left(5)))
    }
    
    func testExists() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        let isPositive = { (x : Int) in x >= 0 }
        
        expect(left.exists(isPositive)).to(beFalse())
        expect(right.exists(isPositive)).to(beTrue())
        expect(right.exists(not <<< isPositive)).to(beFalse())
    }
    
    func testToOption() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)

        expect(left.toOption()).to(equal(Option<Int>.none()))
        expect(right.toOption()).to(equal(Option<Int>.some(5)))
    }
    
    func testGetOrElse() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        
        expect(left.getOrElse(10)).to(be(10))
        expect(right.getOrElse(10)).to(be(5))
    }
    
    func testFilterOrElse() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        let isPositive = { (x : Int) in x >= 0 }
        
        expect(left.filterOrElse(isPositive, "10")).to(equal(Either<String, Int>.left("Hello")))
        expect(right.filterOrElse(isPositive, "10")).to(equal(Either<String, Int>.right(5)))
        expect(right.filterOrElse(not <<< isPositive, "10")).to(equal(Either<String, Int>.left("10")))
    }
    
    func testConversionToString() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        
        expect(left.description).to(equal("Left(Hello)"))
        expect(right.description).to(equal("Right(5)"))
    }
}
