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
    
    private static let xPub = "xpub6DfraEiwmoaDgKamZCKcraHHwkcYLxDXU2xjjwJ7mS7Qa7AD5jusSyS5Vr21A7ewymavUeMTpLoa16oMYpkTWhbmyU7cc7jAHnaUiAGneNT"
    
    private static let xAddress = [
        "avax19hwrurj35x2jdxja4k429m7296la6yu5mvhum9",
        "avax1py5xak5rzsnxq597fml9k3fm925g2dfg859ecj",
        "avax1yxrpndr8px88srwln9zjrl3j92x7e9fdqk2j7l",
        "avax1esajjkmav7c83vn05nc5zdxms63jj8fqgyaeq0",
        "avax1ka33nj6kttv7dwsnlkdwvvckp5np4c6a0ulm6z",
        "avax1kzjpzqegly4tjk5a90fc4jr8vm9zz6mt5q2aqm",
        "avax1rgk2ws5zxnd4wxeu48djzle42gvmn2hftg4dmm",
        "avax14w0dcukpwenflmt77gd4ygcr5a9w5f9asge9zy",
        "avax1a6hjlx6vl850s9daajyq8hng6xpqk4866cwt9u",
        "avax15wrtcrs399fty0cr2mwzp6fsv7y4ntlzyylzd6",
         "avax1a9cc84gvs5ctmu98fdfn3exggd852ec8avuzv0",
         "avax1xza2t7lewyffyrd5tngmuw5ywu2qpuh5mulep8",
         "avax1vjww2yeql8z5j0zdme4vefjchv9dtwsrvfz7mf",
         "avax14phup4a2eyrf78nsyjzmlnnqtkfe35grrz3t2e",
         "avax1vgkcwzyk23hwppuf00v5859tna2fltkcuwgvjy",
         "avax1smhts5z7zl950dkslzpz3dl9hjd87pmh3v0rt5",
         "avax1ps5luhq0tuf06t83n49ry3m79ahvqtpsyy3nl3",
         "avax15n2jfht4m2uaqad7968g7ujphzvwz9ufwkx8rx",
         "avax1c20m6lwqc8czf0de3f02j6cpgrthscwgp9shgq",
         "avax12x54fg3tqnkv4vndvt2s2v53tuwjjfmj77wpum",
         "avax17fsrp0yafjk54gjahrpakhpu0gwyw57wpuenhl",
         "avax1z7uec457kdan6ld7z56x0aqe4euu4kqj9m6fes",
         "avax1herlccqnkqpnuvqykgmmu4luadng7vpfes07vu",
         "avax1j30r5l6uf08lzt6adgq8dtap98z732jkga6jrx",
         "avax125ne62gcvf33s8d94p90ux9rtl9d3xrv6spu93",
         "avax1ghzpwrkn4tm9wdz47upmp5qjnmawd9m3khc4nj",
         "avax1323axwxjxef9jdevwf2eywzqw57wmgg3zm3gw9",
         "avax1jk05yr5sapxgrvldevd6d7jpzt7ka2f2xsgx5e",
         "avax1qt84q45azaufc3k64c7vzpdvz4u8prcsu524qn",
         "avax1pku0hghhsus3378qsdsumkhapu4aykql5u5cf2",
         "avax1s26t62s5r80u8djy3rgx827jh0zk9sgtl8vpx0",
         "avax1jc40mychd9y2kyqp8l97yemaxhm2v42cye4mp9",
         "avax1v5zqy43a29lymudv4qvvynhmf6fh75f2jjafuu",
         "avax1d2pq8n32qxq7hlv39mcv0yrju36k8hr7t95xvn",
         "avax1j7y0p9926hhkarvr2szxq4gvsfyrt8n4chmhkz",
         "avax16rhqnu2ps77sl373d0gq6wjzvl3utfgxm34hu8",
         "avax1xc3l7qnu3gjynvrprehqczs0kx34ls9zwvlz74",
         "avax1j20l6eglfkfzqp37nfa2g6plr3wkm7mlv4cseg",
         "avax1zlh53ghyvs69jrk0j8fvp04dfxvfru6vz59vxn",
         "avax17ynrhflfahe565ed0c38fyuddsyh8v02e509jj",
         "avax1qw6y97x96lmz2a63axymh8dfnvrt6wnppr46y0",
         "avax1cwjq3uwvadeuuwfwlqnxva9gt3l89yufutje22",
         "avax1kdyeamney7mrmp0s9nnkjnzqgvqs4v75vcwqqy",
         "avax1vgsv43hf4pmf2qlkpt3uktn8ft8pv8ar6qvkds",
         "avax1mr9shx3j0d7j35uhs3np0d55uzrp9lwsq3f4c4",
         "avax1s4ww3p86rp0lf6zxvn9899zjr82cglc3rwwz9e",
         "avax1wsvd7zvq8r59fyajpxmktjezyuxg8n6sylz27w",
         "avax170rydlmd0awlplp6tqpfz8esuuj6q8a0mvqqyn",
         "avax1c6qq2z6lhkeyn2mg8zkgwqvgfkzmscnafj4un8",
         "avax1lqud4lnyff86kwdg7n3d45gegudu6h2xucv99a"
    ]

    func testGetValidators() throws {
         
    }
    
    func testInit() {        
        AvalancheSwift.initialize(seed: AvalancheSwiftTests.seed)

        let expectation = self.expectation(description: "Get Validators")

        AvalancheSwift.shared.exportAvax(from: "X", to: "P", amount: "0.01") { transaction in
            expectation.fulfill()
            XCTAssertTrue(true)
        }
        waitForExpectations(timeout: 25, handler: nil)

    }
    
    func testBalance() {
        let expectation = self.expectation(description: "Check Balance")

        AvaxAPI.initializeAddresses(wallet: AvalancheSwiftTests.xAddress, intX: AvalancheSwiftTests.xAddress)
        AvaxAPI.checkState(delegate: self)
        
        waitForExpectations(timeout: 90, handler: nil)


        
    }
    
    
    
}
