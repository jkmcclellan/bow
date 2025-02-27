import XCTest
@testable import BowLaws
import Bow

class WriterTTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<WriterTPartial<ForId, Int>, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<WriterTPartial<ForId, Int>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<WriterTPartial<ForId, Int>>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<WriterTPartial<ForId, Int>>.check()
    }

    func testMonadLaws() {
        MonadLaws<WriterTPartial<ForId, Int>>.check()
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<WriterTPartial<ForArrayK, Int>>.check()
    }
    
    func testMonoidKLaws() {
        MonoidKLaws<WriterTPartial<ForArrayK, Int>>.check()
    }

    func testFunctorFilterLaws() {
        FunctorFilterLaws<WriterTPartial<ForOption, Int>>.check()
    }
    
    func testMonadFilterLaws() {
        MonadFilterLaws<WriterTPartial<ForOption, Int>>.check()
    }
    
    func testMonadWriterLaws() {
        MonadWriterLaws<WriterTPartial<ForId, Int>>.check()
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<WriterTPartial<EitherPartial<CategoryError>, Int>>.check()
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<WriterTPartial<EitherPartial<CategoryError>, Int>>.check()
    }
}
