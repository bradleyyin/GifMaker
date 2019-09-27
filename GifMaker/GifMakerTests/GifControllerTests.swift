//
//  GifControllerTests.swift
//  GifMakerTests
//
//  Created by Bradley Yin on 9/25/19.
//  Copyright © 2019 bradleyyin. All rights reserved.
//

import Foundation
import XCTest
@testable import GifMaker

class GifControllerTests: XCTestCase {
    func testInitRunsLoadData() {
        let gifController = GifController()
        XCTAssertTrue(gifController.dataLoaded)
    }
    func testCreateNewGif() {
        let gifController = GifController()
        gifController.gifs = []
        let didFinish = expectation(description: "didfinish")
        gifController.createNewGif(name: "test", fileURL: "testURL", completion: {
            didFinish.fulfill()
        })
        wait(for: [didFinish], timeout: 5)
        
        XCTAssertEqual(1, gifController.gifs.count)
        XCTAssertEqual("test", gifController.gifs[0].name)
    }
    
    func testLoadFromCoreData() {
        let gifController = GifController()
        gifController.gifs = []
        let didFinish = expectation(description: "didfinish")
        gifController.loadFromCoreData(completion: {
            didFinish.fulfill()
        })
        
        wait(for: [didFinish], timeout: 5)
        
        XCTAssertTrue(!gifController.gifs.isEmpty)
    }
    
    func testDeleteGif() {
        let gifController = GifController()
        let didFinish = expectation(description: "didfinish")
        guard !gifController.gifs.isEmpty else { fatalError("Not enough gifs to delete") }
        let gifToDelete = gifController.gifs[0]
        let originalGifsCount = gifController.gifs.count
        gifController.deleteGif(gif: gifToDelete) {
            didFinish.fulfill()
        }
        wait(for: [didFinish], timeout: 5)
        
        XCTAssertEqual(originalGifsCount - 1, gifController.gifs.count)
        XCTAssertTrue(!gifController.gifs.contains(gifToDelete))
    }
}
