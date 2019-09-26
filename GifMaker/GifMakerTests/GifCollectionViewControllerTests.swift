//
//  GifCollectionViewControllerTests.swift
//  GifMakerTests
//
//  Created by Bradley Yin on 9/25/19.
//  Copyright © 2019 bradleyyin. All rights reserved.
//

import Foundation
import XCTest
@testable import GifMaker

class GifCollectionViewControllerTests: XCTestCase {
    func testGifControllerSucessfulInit() {
        let gifCollectionViewController = GifsCollectionViewController()
        XCTAssertTrue(gifCollectionViewController.gifController.gifs.count >= 0) 
    }
    
    
   
}
