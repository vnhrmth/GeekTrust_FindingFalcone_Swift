//
//  DataServicesTests.swift
//  FindingFalconeTests
//
//  Created by Vinay Hiremath on 03/01/21.
//

import XCTest
@testable import FindingFalcone

class DataServicesTests: XCTestCase {
    var dataServices : DataService?
    let api = Api()
    
    //    override init() {
    //        super.init()
    //    }
    
    func testGetPlanetsReturnsNilData(){
        let mockURLSession  = MockURLSession(data: nil, urlResponse: nil, error: nil)
        let dataService = DataService(session: mockURLSession)
        
        var vehicleExpectation :XCTestExpectation? = expectation(description: "is Success")
        var isSuccessful: Bool = false
        
        dataService.getPlanets { (isSuccess, error) in
            isSuccessful = isSuccess
            vehicleExpectation?.fulfill()
            vehicleExpectation = nil
        }
        
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertFalse(isSuccessful)
        }
    }
    
    func testGetPlanetsReturnsSuccessData(){
        let jsonData = """
            [
              {
                  "name": "Donlon",
                  "distance": 100
              },
              {
                  "name": "Enchai",
                  "distance": 200
              },
              {
                  "name": "Jebing",
                  "distance": 300
              },
              {
                  "name": "Sapir",
                  "distance": 400
              },
              {
                  "name": "Lerbin",
                  "distance": 500
              },
              {
                  "name": "Pingasor",
                  "distance": 600
              }
            ]
            """
            .data(using: .utf8)
        
        let response = HTTPURLResponse(url: URL(string: api.getPlanetsUrl)!, statusCode: 200,
                                       httpVersion: nil, headerFields: nil)!

        let mockURLSession  = MockURLSession(data: jsonData, urlResponse: response, error: nil)
        let dataService = DataService(session: mockURLSession)
        
        var vehicleExpectation :XCTestExpectation? = expectation(description: "is Success")
        var isSuccessful: Bool = false
        
        dataService.getPlanets { (isSuccess, error) in
            isSuccessful = isSuccess
            vehicleExpectation?.fulfill()
            vehicleExpectation = nil
        }
        
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertTrue(isSuccessful)
        }
    }
    
    func testGetPlanetsReturnsFailedResponseCode(){
        let jsonData = """
                      [
                        {
                            "name": "Donlon",
                            "distance": 100
                        },
                        {
                            "name": "Enchai",
                            "distance": 200
                        },
                        {
                            "name": "Jebing",
                            "distance": 300
                        },
                        {
                            "name": "Sapir",
                            "distance": 400
                        },
                        {
                            "name": "Lerbin",
                            "distance": 500
                        },
                        {
                            "name": "Pingasor",
                            "distance": 600
                        }
                      ]
            """
            .data(using: .utf8)
        
        let response = HTTPURLResponse(url: URL(string: api.getPlanetsUrl)!, statusCode: 400,
                                       httpVersion: nil, headerFields: nil)!

        let mockURLSession  = MockURLSession(data: jsonData, urlResponse: response, error: nil)
        let dataService = DataService(session: mockURLSession)
        
        var vehicleExpectation :XCTestExpectation? = expectation(description: "is Success")
        var isSuccessful: Bool = false
        
        dataService.getVehicles { (isSuccess, error) in
            isSuccessful = isSuccess
            vehicleExpectation?.fulfill()
            vehicleExpectation = nil
            print(isSuccessful)
        }
        
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertFalse(isSuccessful)
        }
    }
    
    func testGetVehiclesReturnsNilData(){
        let mockURLSession  = MockURLSession(data: nil, urlResponse: nil, error: nil)
        let dataService = DataService(session: mockURLSession)
        
        var vehicleExpectation :XCTestExpectation? = expectation(description: "is Success")
        var isSuccessful: Bool = false
        
        dataService.getVehicles { (isSuccess, error) in
            isSuccessful = isSuccess
            vehicleExpectation?.fulfill()
            vehicleExpectation = nil
        }
        
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertFalse(isSuccessful)
        }
    }
    
    func testGetVehiclesReturnsSuccessData(){
        let jsonData = """
            [
                    {
                        "name": "Space pod",
                        "total_no": 2,
                        "max_distance": 200,
                        "speed": 2
                    },
                    {
                        "name": "Space rocket",
                        "total_no": 1,
                        "max_distance": 300,
                        "speed": 4
                    },
                    {
                        "name": "Space shuttle",
                        "total_no": 1,
                        "max_distance": 400,
                        "speed": 5
                    },
                    {
                        "name": "Space ship",
                        "total_no": 2,
                        "max_distance": 600,
                        "speed": 10
                    }
                ]
            """
            .data(using: .utf8)
        
        let response = HTTPURLResponse(url: URL(string: api.getVehiclesUrl)!, statusCode: 200,
                                       httpVersion: nil, headerFields: nil)!

        let mockURLSession  = MockURLSession(data: jsonData, urlResponse: response, error: nil)
        let dataService = DataService(session: mockURLSession)
        
        var vehicleExpectation :XCTestExpectation? = expectation(description: "is Success")
        var isSuccessful: Bool = false
        
        dataService.getVehicles { (isSuccess, error) in
            isSuccessful = isSuccess
            vehicleExpectation?.fulfill()
            vehicleExpectation = nil
            print(isSuccessful)
        }
        
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertTrue(isSuccessful)
        }
    }
    
    func testGetVehiclesReturnsFailedResponseCode(){
        let jsonData = """
            [
                    {
                        "name": "Space pod",
                        "total_no": 2,
                        "max_distance": 200,
                        "speed": 2
                    },
                    {
                        "name": "Space rocket",
                        "total_no": 1,
                        "max_distance": 300,
                        "speed": 4
                    },
                    {
                        "name": "Space shuttle",
                        "total_no": 1,
                        "max_distance": 400,
                        "speed": 5
                    },
                    {
                        "name": "Space ship",
                        "total_no": 2,
                        "max_distance": 600,
                        "speed": 10
                    }
                ]
            """
            .data(using: .utf8)
        
        let response = HTTPURLResponse(url: URL(string: api.getVehiclesUrl)!, statusCode: 400,
                                       httpVersion: nil, headerFields: nil)!

        let mockURLSession  = MockURLSession(data: jsonData, urlResponse: response, error: nil)
        let dataService = DataService(session: mockURLSession)
        
        var vehicleExpectation :XCTestExpectation? = expectation(description: "is Success")
        var isSuccessful: Bool = false
        
        dataService.getVehicles { (isSuccess, error) in
            isSuccessful = isSuccess
            vehicleExpectation?.fulfill()
            vehicleExpectation = nil
            print(isSuccessful)
        }
        
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertFalse(isSuccessful)
        }
    }
    
//    func testGetVehiclesReturnsNSError(){
//        let jsonData = """
//            [
//                    {
//                        "name": "Space pod",
//                        "total_no": 2,
//                        "max_distance": 200,
//                        "speed": 2
//                    },
//                    {
//                        "name": "Space rocket",
//                        "total_no": 1,
//                        "max_distance": 300,
//                        "speed": 4
//                    },
//                    {
//                        "name": "Space shuttle",
//                        "total_no": 1,
//                        "max_distance": 400,
//                        "speed": 5
//                    },
//                    {
//                        "name": "Space ship",
//                        "total_no": 2,
//                        "max_distance": 600,
//                        "speed": 10
//                    }
//                ]
//            """
//            .data(using: .utf8)
//        
//        let error = NSError(domain: "domain", code: 400, userInfo: nil)
//        
//        let response = HTTPURLResponse(url: URL(string: api.getVehiclesUrl)!, statusCode: 200,
//                                       httpVersion: nil, headerFields: nil)!
//
//        let mockURLSession  = MockURLSession(data: jsonData, urlResponse: response, error: error)
//        let dataService = DataService(session: mockURLSession)
//        
//        var vehicleExpectation :XCTestExpectation? = expectation(description: "is Success")
//        var isSuccessful: Bool = false
//        
//        dataService.getVehicles { (isSuccess, error) in
//            isSuccessful = isSuccess
//            vehicleExpectation?.fulfill()
//            vehicleExpectation = nil
//            print(isSuccessful)
//        }
//        
//        waitForExpectations(timeout: 5) { (error) in
//            XCTAssertFalse(isSuccessful)
//        }
//    }
    
    func testGetTokenWithSuccess(){
        
        let jsonData = """
        {
            "token": "MQGMxbVhdlSJhTNMqwXaVmdOrLHnLsQP"
        }
        """.data(using: .utf8)

        let response = HTTPURLResponse(url: URL(string: api.findFalconeUrl)!, statusCode: 200,
                                       httpVersion: nil, headerFields: nil)!

        let mockURLSession  = MockURLSession(data: jsonData, urlResponse: response, error: nil)
        let dataService = DataService(session: mockURLSession)
        
        var isSuccessExpectation :XCTestExpectation? = expectation(description: "is Success")
        var isSuccessful: Bool = false
        
        dataService.getToken { (isSuccess, token) in
            isSuccessful = isSuccess
            isSuccessExpectation?.fulfill()
            isSuccessExpectation =  nil
        }
        
        waitForExpectations(timeout: 5) { (error) in
            XCTAssertTrue(isSuccessful)
        }
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGetVehiclesWithNoDataReturned(){
        dataServices?.getVehicles { (isSuccess, error) in
            
        }
    }
}
