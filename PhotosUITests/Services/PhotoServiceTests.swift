//
//  PhotoServiceTests.swift
//  PhotosUITests
//
//  Created by Eido Goya on 2022/01/20.
//

import XCTest
@testable import PhotosUI

class PhotoServiceTests: XCTestCase {
    
    var provider: ManagerProviderProtocol!
    var manager: MockNetworkManager!
    var service: PhotoServiceProtocol!

    override func setUpWithError() throws {
        provider = MockManagerProvider.stubs()
        manager = provider.networkManager as? MockNetworkManager
        service = PhotoService(provider: provider,
                               decoder: JSONDecoder())
    }

    override func tearDownWithError() throws {
        service = nil
        provider = nil
    }

    func test_photos() {
        // given
        let page = 1
        let clientId = "testId"
        
        // when
        _ = service.photos(page: page, clientId: clientId)
            .sink { _ in
            } receiveValue: { _ in
            }
        
        // then
        let expectedReq = APIRouter.getPhotos(
            clientId: clientId,
            page: page).asURLRequest()
        XCTAssertEqual(expectedReq, manager.urlRequest)
    }
    
    func test_download() {
        let urlStr = "TestUrlStr"
        
        _ = service.download(urlStr: urlStr)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { _ in
            })
        
        guard let url = URL(string: urlStr) else {
            fatalError()
        }
        XCTAssertEqual(url, manager.url)
    }
}
