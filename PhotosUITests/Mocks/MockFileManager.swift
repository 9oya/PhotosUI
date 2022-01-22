//
//  MockFileManager.swift
//  PhotosUITests
//
//  Created by Eido Goya on 2022/01/22.
//

import Foundation

class MockFileManager: FileManager {
    
    var cachedDict: [String: Data] = [:]
    var path: String = ""
    var contents: Data?
    var attributes: [FileAttributeKey : Any]?
    
    override func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]?) -> Bool {
        self.path = path
        self.contents = data
        self.attributes = attr
        self.cachedDict[path] = data
        return true
    }
    
    override func fileExists(atPath path: String) -> Bool {
        self.path = path
        if cachedDict[path] != nil {
            return true
        }
        return false
    }
}
