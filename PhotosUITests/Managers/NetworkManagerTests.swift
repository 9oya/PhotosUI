//
//  NetworkManagerTests.swift
//  PhotosUITests
//
//  Created by Eido Goya on 2022/01/20.
//

import XCTest
@testable import PhotosUI

class NetworkManagerTests: XCTestCase {
    
    var session: MockURLSession!
    var manager: NetworkManagerProtocol!

    override func setUpWithError() throws {
        session = MockURLSession()
        manager = NetworkManager(session: session)
    }

    override func tearDownWithError() throws {
        manager = nil
        session = nil
    }

    func testNetworkManager_dataTaskWithURL() {
        // given
        guard let url = URL(string: "https://itbook.store/img/books/9781617294136.png") else {
            fatalError()
        }
        
        // when
        manager.dataTask(request: url) { _ in
        }
        
        // then
        XCTAssertEqual(url, session.url)
    }
    
    func testNetworkManager_dataTaskWithURLRequest() {
        let urlRequest = APIRouter.getPhotos(clientId: "", page: 0).asURLRequest()
        
        manager.dataTask(request: urlRequest) { _ in
        }
        
        XCTAssertEqual(urlRequest, session.request)
    }
    
}
