import XCTest
@testable import AvalancheSwift

final class AvalancheSwiftTests: XCTestCase, AvalancheInitDelegate {
    
    func addressesInitialized() {
        return
    }
    
    func balanceXInitialized() {
        return
    }
    
    func balancePInitialized() {
        return
    }
    
    func delegationInitialized() {
        return
    }
    

    private static let seed = "denial adult elevator below success birth sheriff front acid chef debate start"

    func testGetValidators() throws {
        
        let expectation = self.expectation(description: "Get Validators")

        API.getValidators { list in
            XCTAssertNotNil(list)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 25, handler: nil)
    }
    
    func testInit() {        
        XCTAssertFalse(AvalancheSwift.isInitialized())
        AvalancheSwift.initialization(seed: AvalancheSwiftTests.seed, delegate: self)
        XCTAssertTrue(AvalancheSwift.isInitialized())

    }
    
    func testExportAvax() {
        
        AvalancheSwift.initialization(seed: AvalancheSwiftTests.seed, delegate: self)
        
        let expectation = self.expectation(description: "Export")

        API.exportAvax(from: Constants.chainX, to: Constants.chainP, amount: "0.01") { transaction in
            XCTAssertNotNil(transaction)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 25, handler: nil)

        
    }
    
    
    
}
