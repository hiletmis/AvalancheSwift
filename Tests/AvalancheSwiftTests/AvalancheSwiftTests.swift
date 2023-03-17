import XCTest
@testable import AvalancheSwift

final class AvalancheSwiftTests: XCTestCase, AvalancheInitDelegate {
    func addressesInitialized() {
        return
    }
    
    func balanceInitialized(chain: Chain) {
        return
    }
    
    func delegationInitialized(chain: Chain) {
        return
    }
    
    
    private static let seed = "denial adult elevator below success birth sheriff front acid chef debate start"

    func testGetValidators() throws {
        
        let expectation = self.expectation(description: "Get Validators")

        API.shared.getValidators { list in
            XCTAssertNotNil(list)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 25, handler: nil)
    }
    
    func testInit() {        
        XCTAssertFalse(AvalancheSwift.isInitialized())
        AvalancheSwift.initialization(seed: AvalancheSwiftTests.seed, delegate: self)
        XCTAssertTrue(AvalancheSwift.isInitialized())
        
        let expectation = self.expectation(description: "Get Validators")

        API.shared.getValidators { list in
            XCTAssertNotNil(list)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 25, handler: nil)

    }
    
    func testExportAvax() {
        
        AvalancheSwift.initialization(seed: AvalancheSwiftTests.seed, delegate: self)
        
        let expectation = self.expectation(description: "Export")

        API.shared.exportAvax(from: Constants.chainX, to: Constants.chainP, amount: "0.01") { transaction in
            XCTAssertNotNil(transaction)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 25, handler: nil)

        
    }
    
    
    
}
