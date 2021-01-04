//
//  MockUrlSession.swift
//  FindingFalconeTests
//
//  Created by Vinay Hiremath on 03/01/21.
//

import XCTest
@testable import FindingFalcone

class MockTask: URLSessionDataTask {
    private let data: Data?
    private let urlResponse: URLResponse?
    
    private let _error: Error?
    override var error: Error? {
        return _error
    }

    var completionHandler: ((Data?, URLResponse?, Error?) -> Void)!

    init(data: Data?, urlResponse: URLResponse?, error: Error?) {
        self.data = data
        self.urlResponse = urlResponse
        self._error = error
    }

    override func resume() {
        DispatchQueue.main.async {
            self.completionHandler(self.data, self.urlResponse, self.error)
        }
    }
}

class MockURLSession: URLSession {
   private let mockTask: MockTask
   var cachedUrl: URL?
    var request:URLRequest?

    init(data: Data?, urlResponse: URLResponse?, error: Error?) {
        mockTask = MockTask(data: data, urlResponse: urlResponse, error:
            error)
    }

    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {

        self.cachedUrl = url
        mockTask.completionHandler = completionHandler
        return mockTask
    }
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.request = request
        mockTask.completionHandler = completionHandler
        return mockTask
    }
}


//class MockURLSession: URLSession {
//    var cachedUrl: URL?
//  override func dataTask(with url: URL, completionHandler:@escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
//    self.cachedUrl = url
//    print(self.cachedUrl!)
//    return URLSessionDataTask()
////    return URLSessionDataTask()
////    return dataTask(with: self.cachedUrl!)
//  }
//}
